# Set directories

bootstrap_dir := "/tmp/nixos-bootstrap"
sops_dir := "sops"
hosts_dir := "hosts"
global_secrets := "secrets/secrets.yaml"

default:
    @just --list

gitleaks-secrets:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "🔍 Scanning for secrets with gitleaks... Writing line by line redactions to /tmp/secrets.txt"
    gitleaks git -f json -r - --no-banner -l fatal | jq '.[].Secret' -r > /tmp/secrets.txt || true

gitleaks-cleanup:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ -f "/tmp/secrets.txt" ]]; then
        echo "🧹 Cleaning up gitleaks secrets file..."
        rm -f /tmp/secrets.txt
        echo "✅ Cleanup complete."
    else
        echo "⚠️  No gitleaks secrets file found to clean."
    fi

# ----------------------------------------------------------------------
# 1. SETUP COMMANDS (Run these once to initialize your environment)
# ----------------------------------------------------------------------

# Creates the central Cluster Key and your Maintainer Key registration.
init-cluster:
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p sops secrets

    # 1. Ask for maintainer key if not configured
    if [[ ! -f "sops/keys.json" ]] || ! grep -q "maintainer" "sops/keys.json"; then
        echo "🔑 Enter your personal Maintainer AGE Public Key (age1...):"
        read MAINTAINER_KEY
        echo "{ \"maintainer\": \"$MAINTAINER_KEY\" }" > sops/keys.json
    else
        echo "✅ Maintainer key already exists."
    fi

    # 2. Check if cluster key already generated
    if grep -q "cluster-key" "sops/keys.json"; then
        echo "✅ Cluster key already exists."
        exit 0
    fi

    echo "⚙️  Generating new Cluster Key..."
    CLUSTER_OUTPUT=$(nix shell nixpkgs#age -c age-keygen)
    CLUSTER_PRIV=$(echo "$CLUSTER_OUTPUT" | grep "^AGE-SECRET-KEY")
    CLUSTER_PUB=$(echo "$CLUSTER_OUTPUT" | grep "public key:" | awk '{print $4}')

    # 3. Add Cluster Public Key to sops/keys.json using jq
    tmp=$(mktemp)
    nix run nixpkgs#jq -- --arg ck "$CLUSTER_PUB" '.["cluster-key"] = $ck' sops/keys.json > "$tmp"
    mv "$tmp" sops/keys.json

    # 4. Save the private key to unencrypted file temporarily
    echo "cluster_private_key: \"$CLUSTER_PRIV\"" > secrets/secrets.yaml

    # 5. Build rules and encrypt!
    just regenerate-sops
    nix run nixpkgs#sops -- -e -i secrets/secrets.yaml
    echo "🔒 Cluster key safely encrypted into secrets/secrets.yaml"

# ----------------------------------------------------------------------
# 2. SOPS MANAGEMENT
# ----------------------------------------------------------------------

# Rebuilds .sops.yaml based on keys.json and all hosts
regenerate-sops:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "sops/keys.json" ]; then
        echo "❌ missing sops/keys.json. Run 'just init-cluster' first!"
        exit 1
    fi

    MAINTAINER=$(nix run nixpkgs#jq -- -r '.maintainer' sops/keys.json)
    CLUSTER=$(nix run nixpkgs#jq -- -r '.["cluster-key"]' sops/keys.json)

    echo "⚙️ Regenerating .sops.yaml..."

    # Write top of .sops.yaml (Global & Shared Rules) sequentially
    echo "creation_rules:" > .sops.yaml
    echo "  # Rule 1: Global Secrets" >> .sops.yaml
    echo "  - path_regex: ^secrets/secrets\.yaml$" >> .sops.yaml
    echo "    key_groups:" >> .sops.yaml
    echo "      - age:" >> .sops.yaml
    echo "        - $MAINTAINER" >> .sops.yaml
    echo "        - $CLUSTER" >> .sops.yaml
    echo "" >> .sops.yaml
    echo "  # Rule 2: Shared Host Secrets" >> .sops.yaml
    echo "  - path_regex: ^hosts/[^/]+/secrets/shared\.secrets\.yaml$" >> .sops.yaml
    echo "    key_groups:" >> .sops.yaml
    echo "      - age:" >> .sops.yaml
    echo "        - $MAINTAINER" >> .sops.yaml
    echo "        - $CLUSTER" >> .sops.yaml

    # Write rules for specific hosts
    for keyfile in hosts/*/secrets/keys.json; do
        [ -f "$keyfile" ] || continue
        # Extract host directory name
        HOST=$(basename $(dirname $(dirname "$keyfile")))
        HOST_KEY=$(nix run nixpkgs#jq -- -r '.age' "$keyfile")

        echo "" >> .sops.yaml
        echo "  # Rule 3: Node-Specific Secrets for $HOST" >> .sops.yaml
        echo "  - path_regex: ^hosts/$HOST/secrets/secrets\.yaml$" >> .sops.yaml
        echo "    key_groups:" >> .sops.yaml
        echo "      - age:" >> .sops.yaml
        echo "        - $MAINTAINER" >> .sops.yaml
        echo "        - $HOST_KEY" >> .sops.yaml
    done

    # Fallback Rule for uninitialized host secrets files
    echo "" >> .sops.yaml
    echo "  # Rule 4: Fallback for any other secrets.yaml (Maintainer only)" >> .sops.yaml
    echo "  - path_regex: ^hosts/[^/]+/secrets/.*secrets\.yaml$" >> .sops.yaml
    echo "    key_groups:" >> .sops.yaml
    echo "      - age:" >> .sops.yaml
    echo "        - $MAINTAINER" >> .sops.yaml

    echo "✅ .sops.yaml successfully generated."

# Loops through all YAML files in secrets directories and securely re-keys them.
rekey-secrets:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "🔄 Re-keying existing SOPS valid targets..."
    # Find all yaml files in target dirs, check if they are encrypted
    find secrets hosts -type f -name "*.yaml" 2>/dev/null | while IFS= read -r file; do
        if grep -q "^sops:" "$file"; then
            echo "   -> Updating $file"
            nix run nixpkgs#sops -- updatekeys -y "$file"
        fi
    done
    echo "✅ Re-keying complete."

# ----------------------------------------------------------------------
# 3. NODE DEPLOYMENT (nixos-anywhere logic)
# ----------------------------------------------------------------------

# Deploys NixOS entirely end-to-end
install-nixos host ssh-host:
    #!/usr/bin/env bash
    set -euo pipefail

    # --- 1. Bootstrap Host SSH Key ---
    mkdir -p "{{ bootstrap_dir }}/etc/ssh"
    if [[ ! -f "{{ bootstrap_dir }}/etc/ssh/ssh_host_ed25519_key" ]]; then
        echo "⚙️  Generating Host SSH Key for {{ host }}..."
        ssh-keygen -t ed25519 -N "" -f "{{ bootstrap_dir }}/etc/ssh/ssh_host_ed25519_key" > /dev/null
        chmod 600 "{{ bootstrap_dir }}/etc/ssh/ssh_host_ed25519_key"
    fi

    # --- 2. Convert SSH to AGE and Write Host Config ---
    HOST_AGE=$(nix run nixpkgs#ssh-to-age -- -i "{{ bootstrap_dir }}/etc/ssh/ssh_host_ed25519_key.pub")
    mkdir -p "hosts/{{ host }}/secrets"
    echo "{\"age\": \"$HOST_AGE\"}" > "hosts/{{ host }}/secrets/keys.json"

    # --- 3. Refresh SOPS Pipeline ---
    just regenerate-sops
    just rekey-secrets

    # --- 4. Inject Central Cluster Key into Bootstrap Dir ---
    echo "🔐 Extracting cluster private key for deployment..."
    mkdir -p "{{ bootstrap_dir }}/var/lib/sops-nix"

    if [[ ! -f "{{ bootstrap_dir }}/var/lib/sops-nix/cluster-key.txt" ]]; then
        nix run nixpkgs#sops -- -d --extract '["cluster_private_key"]' secrets/secrets.yaml \
            > "{{ bootstrap_dir }}/var/lib/sops-nix/cluster-key.txt"
        chmod 400 "{{ bootstrap_dir }}/var/lib/sops-nix/cluster-key.txt"
    fi

    # --- 5. Action: nixos-anywhere ---
    echo "🚀 Installing NixOS to {{ ssh-host }} (Flake attr: {{ host }})..."
    nix run github:nix-community/nixos-anywhere -- \
        --extra-files "{{ bootstrap_dir }}" \
        --flake ".#{{ host }}" \
        --generate-hardware-config nixos-facter ./hosts/{{ host }}/facter.json \
        "{{ ssh-host }}"

    # --- 6. Cleanup ---
    just cleanup-bootstrap

# Securely deletes the temporary bootstrap keys
cleanup-bootstrap:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ -d "{{ bootstrap_dir }}" ]]; then
        rm -rf "{{ bootstrap_dir }}"
        echo "🗑️  Bootstrap directory cleaned."
    fi

new template-name:
    kickstart templates/{{ template-name }} -o hosts

copy-cluster-key host:
    #!/usr/bin/env bash
    # echo "🔐 Extracting cluster private key for deployment..."
    mkdir -p "{{ bootstrap_dir }}/var/lib/sops-nix"

    nix run nixpkgs#sops -- -d --extract '["cluster_private_key"]' secrets/secrets.yaml \
        > "{{ bootstrap_dir }}/var/lib/sops-nix/cluster-key.txt"
    chmod 400 "{{ bootstrap_dir }}/var/lib/sops-nix/cluster-key.txt"
    scp "{{ bootstrap_dir }}/var/lib/sops-nix/cluster-key.txt" "{{ host }}:~/cluster-key.txt"
    ssh -t {{ host }} 'sudo cp ~/cluster-key.txt /var/lib/sops-nix/cluster-key.txt'
    ssh {{ host }} 'rm -f ~/cluster-key.txt'
    rm -f "{{ bootstrap_dir }}/var/lib/sops-nix/cluster-key.txt"

onboard-machine machine ssh-host:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Fetching host ssh key from host, to get age key..."
    HOST_AGE=$(ssh -t {{ ssh-host }} "sudo cat /etc/ssh/ssh_host_ed25519_key.pub" | nix run nixpkgs#ssh-to-age -- -i -)
    mkdir -p "hosts/{{ machine }}/secrets"
    echo "{\"age\": \"$HOST_AGE\"}" > "hosts/{{ machine }}/secrets/keys.json"

    echo "Regenerating secrets with new host, ensure keys.json exists in directory"
    if [ ! -f "hosts/{{ machine }}/secrets/keys.json" ]; then
        echo "❌ missing hosts/{{ machine }}/secrets/keys.json. Manually add the key!"
        exit 1
    fi
    just regenerate-sops
    just rekey-secrets

    echo "🔐 Copying cluster key to target..."
    just copy-cluster-key {{ ssh-host }}

    echo "🚀 Applying config  to {{ ssh-host }} (Flake attr: {{ machine }})..."
    colmena apply --on {{ machine }} --build-on-target

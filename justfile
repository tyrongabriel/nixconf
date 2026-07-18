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

# Creates the maintainer keys file if not present
init:
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p sops secrets

    if [[ ! -f "sops/keys.json" ]] || ! grep -q "maintainers" "sops/keys.json"; then
        echo "🔑 Enter your personal Maintainer AGE Public Key (age1...):"
        read MAINTAINER_KEY
        echo "{ \"maintainers\": [\"$MAINTAINER_KEY\"] }" > sops/keys.json
    else
        echo "✅ Maintainer key already exists."
    fi

# Generate a new age keypair for a user and add the public key to a host's keys.json
generate-user-age-key user host:
    #!/usr/bin/env bash
    set -euo pipefail

    KEYFILE="hosts/{{ host }}/secrets/keys.json"

    if [[ ! -f "$KEYFILE" ]]; then
        echo "❌ Missing $KEYFILE. Run 'just onboard-machine' or 'just install-nixos' first!"
        exit 1
    fi

    # Check if user already has a key in keys.json
    EXISTING=$(nix run nixpkgs#jq -- -r ".users.{{ user }} // empty" "$KEYFILE")
    if [[ -n "$EXISTING" ]]; then
        echo "⚠️  User {{ user }} already has a key in $KEYFILE: $EXISTING"
        echo "   Delete it from keys.json first if you want to regenerate."
        exit 1
    fi

    echo "⚙️  Generating new age keypair for user {{ user }} on host {{ host }}..."
    AGE_OUTPUT=$(nix shell nixpkgs#age -c age-keygen)
    AGE_PRIV=$(echo "$AGE_OUTPUT" | grep "^AGE-SECRET-KEY")
    AGE_PUB=$(echo "$AGE_OUTPUT" | grep "public key:" | awk '{print $4}')

    # Add public key to host's keys.json
    tmp=$(mktemp)
    nix run nixpkgs#jq -- --arg pub "$AGE_PUB" --arg user "{{ user }}" '.users[$user] = $pub' "$KEYFILE" > "$tmp"
    mv "$tmp" "$KEYFILE"
    echo "✅ Added public key for {{ user }} to $KEYFILE"

    # Add private key to host's secrets.yaml
    SECRETS_FILE="hosts/{{ host }}/secrets/secrets.yaml"
    mkdir -p "hosts/{{ host }}/secrets"

    if [[ -f "$SECRETS_FILE" ]] && grep -q "^sops:" "$SECRETS_FILE"; then
        # Decrypt, add key, re-encrypt
        DECRYPTED=$(nix run nixpkgs#sops -- -d "$SECRETS_FILE")
        echo "$DECRYPTED" | yq ".age_keys.{{ user }}.private = \"$AGE_PRIV\"" | yq ".age_keys.{{ user }}.public = \"$AGE_PUB\"" | nix run nixpkgs#sops -- -e /dev/stdin > "$SECRETS_FILE"
    else
        # Create new file with the age key then encrypt in-place
        printf 'age_keys:\n  %s:\n    private: "%s"\n    public: "%s"\n' "{{ user }}" "$AGE_PRIV" "$AGE_PUB" > "$SECRETS_FILE"
        sops -e -i "$SECRETS_FILE"
    fi

    echo "✅ Age keypair for {{ user }} added to host {{ host }}"

    just regenerate-sops
    just rekey-secrets

# Initialize per-user secrets file for a user on a host
init-user-secrets host user:
    #!/usr/bin/env bash
    set -euo pipefail

    SECRETS_DIR="hosts/{{ host }}/secrets/users"
    mkdir -p "$SECRETS_DIR"
    SECRETS_FILE="$SECRETS_DIR/{{ user }}.yaml"

    if [[ -f "$SECRETS_FILE" ]]; then
        echo "⚠️  $SECRETS_FILE already exists. Skipping."
        exit 0
    fi

    # Create empty secrets file then encrypt in-place
    echo "placeholder: null" > "$SECRETS_FILE"
    sops -e -i "$SECRETS_FILE"

    just regenerate-sops
    just rekey-secrets

# ----------------------------------------------------------------------
# 2. SOPS MANAGEMENT
# ----------------------------------------------------------------------

# Rebuilds .sops.yaml based on keys.json and all hosts
regenerate-sops:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "sops/keys.json" ]; then
        echo "❌ missing sops/keys.json. Run 'just init' first!"
        exit 1
    fi

    echo "⚙️ Regenerating .sops.yaml..."

    # Collect all host keys for shared/global secret access
    HOST_KEYS=()
    for keyfile in hosts/*/secrets/keys.json; do
        [ -f "$keyfile" ] || continue
        HOST_KEY=$(nix run nixpkgs#jq -- -r '.host' "$keyfile")
        HOST_KEYS+=("$HOST_KEY")
    done

    # Write top of .sops.yaml (Global Secrets)
    echo "creation_rules:" > .sops.yaml
    echo "  # Rule 1: Global Secrets (decryptable by maintainers + all hosts)" >> .sops.yaml
    echo "  - path_regex: ^secrets/secrets\\.yaml$" >> .sops.yaml
    echo "    key_groups:" >> .sops.yaml
    echo "      - age:" >> .sops.yaml
    nix run nixpkgs#jq -- -r '.maintainers[]' sops/keys.json | while read -r MAINTAINER; do
        echo "        - $MAINTAINER" >> .sops.yaml
    done
    for hk in "${HOST_KEYS[@]}"; do
        echo "        - $hk" >> .sops.yaml
    done

    echo "" >> .sops.yaml
    echo "  # Rule 2: Shared Host Secrets (decryptable by maintainers + all hosts)" >> .sops.yaml
    echo "  - path_regex: ^hosts/[^/]+/secrets/shared\\.secrets\\.yaml$" >> .sops.yaml
    echo "    key_groups:" >> .sops.yaml
    echo "      - age:" >> .sops.yaml
    nix run nixpkgs#jq -- -r '.maintainers[]' sops/keys.json | while read -r MAINTAINER; do
        echo "        - $MAINTAINER" >> .sops.yaml
    done
    for hk in "${HOST_KEYS[@]}"; do
        echo "        - $hk" >> .sops.yaml
    done

    # Write rules for specific hosts
    for keyfile in hosts/*/secrets/keys.json; do
        [ -f "$keyfile" ] || continue
        HOST=$(basename $(dirname $(dirname "$keyfile")))
        HOST_KEY=$(nix run nixpkgs#jq -- -r '.host' "$keyfile")

        echo "" >> .sops.yaml
        echo "  # Rule 3: Node-Specific Secrets for $HOST" >> .sops.yaml
        echo "  - path_regex: ^hosts/$HOST/secrets/secrets\\.yaml$" >> .sops.yaml
        echo "    key_groups:" >> .sops.yaml
        echo "      - age:" >> .sops.yaml
        nix run nixpkgs#jq -- -r '.maintainers[]' sops/keys.json | while read -r MAINTAINER; do
            echo "        - $MAINTAINER" >> .sops.yaml
        done
        echo "        - $HOST_KEY" >> .sops.yaml
        # Also allow each user on this host to decrypt host secrets
        nix run nixpkgs#jq -- -r '.users | to_entries[] | .value' "$keyfile" | while read -r USER_KEY; do
            echo "        - $USER_KEY" >> .sops.yaml
        done

        # Per-user secrets for this host
        nix run nixpkgs#jq -- -r '.users | keys[]' "$keyfile" | while read -r USERNAME; do
            USER_KEY=$(nix run nixpkgs#jq -- -r ".users[\"$USERNAME\"]" "$keyfile")
            echo "" >> .sops.yaml
            echo "  # Rule 4: User-Specific Secrets for $USERNAME on $HOST" >> .sops.yaml
            echo "  - path_regex: ^hosts/$HOST/secrets/users/${USERNAME}\\.yaml$" >> .sops.yaml
            echo "    key_groups:" >> .sops.yaml
            echo "      - age:" >> .sops.yaml
            nix run nixpkgs#jq -- -r '.maintainers[]' sops/keys.json | while read -r MAINTAINER; do
                echo "        - $MAINTAINER" >> .sops.yaml
            done
            echo "        - $USER_KEY" >> .sops.yaml
        done
    done

    # Fallback Rule for uninitialized host secrets files
    echo "" >> .sops.yaml
    echo "  # Rule 5: Fallback for any other secrets.yaml (Maintainers only)" >> .sops.yaml
    echo "  - path_regex: ^hosts/[^/]+/secrets/.*secrets\\.yaml$" >> .sops.yaml
    echo "    key_groups:" >> .sops.yaml
    echo "      - age:" >> .sops.yaml
    nix run nixpkgs#jq -- -r '.maintainers[]' sops/keys.json | while read -r MAINTAINER; do
        echo "        - $MAINTAINER" >> .sops.yaml
    done

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
    echo "{\"host\": \"$HOST_AGE\", \"users\": {}}" > "hosts/{{ host }}/secrets/keys.json"

    # --- 3. Refresh SOPS Pipeline ---
    just regenerate-sops
    just rekey-secrets

    # --- 4. Action: nixos-anywhere ---
    echo "🚀 Installing NixOS to {{ ssh-host }} (Flake attr: {{ host }})..."
    nix run github:nix-community/nixos-anywhere -- \
        --extra-files "{{ bootstrap_dir }}" \
        --flake ".#{{ host }}" \
        --generate-hardware-config nixos-facter ./hosts/{{ host }}/facter.json \
        "{{ ssh-host }}"

    # --- 5. Cleanup ---
    just cleanup-bootstrap

# Securely deletes the temporary bootstrap keys
cleanup-bootstrap:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ -d "{{ bootstrap_dir }}" ]]; then
        rm -rf "{{ bootstrap_dir }}"
        echo "🗑️  Bootstrap directory cleaned."
    fi

onboard-machine machine ssh-host:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Fetching host ssh key from host, to get age key..."
    HOST_AGE=$(ssh -t {{ ssh-host }} "sudo cat /etc/ssh/ssh_host_ed25519_key.pub" | nix run nixpkgs#ssh-to-age -- -i -)
    mkdir -p "hosts/{{ machine }}/secrets"
    echo "{\"host\": \"$HOST_AGE\", \"users\": {}}" > "hosts/{{ machine }}/secrets/keys.json"

    echo "Regenerating secrets with new host, ensure keys.json exists in directory"
    if [ ! -f "hosts/{{ machine }}/secrets/keys.json" ]; then
        echo "❌ missing hosts/{{ machine }}/secrets/keys.json. Manually add the key!"
        exit 1
    fi
    just regenerate-sops
    just rekey-secrets

    #echo "🚀 Applying config to {{ ssh-host }} (Flake attr: {{ machine }})..."
    #colmena apply --on {{ machine }} --build-on-target

new template-name:
    kickstart templates/{{ template-name }} -o hosts

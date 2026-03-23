set shell := ["zsh", "-uc"]

default:
    just -l

# Updates files keys, used when new public key is added
sops-rekey:
    sops updatekeys ./**/secrets.yaml

install-nixos name host:
    nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-facter ./hosts/{{ name }}/facter.json  --flake .#droplet --target-host {{ host }}

# You should run sudo systemctl start sshd-keygen.service to re-generate host keys, to not keep the copied ones

generate-topology outPath='./images/topology/':
    nix build .#topology.config.output
    sudo cp result/* {{ outPath }}
    rm -r ./result

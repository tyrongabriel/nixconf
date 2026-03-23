Init a new machine:

```nix
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-facter ./facter.json  --flake .#yoga --target-host root@<ip address>


nix-shell -p ssh-to-age
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```

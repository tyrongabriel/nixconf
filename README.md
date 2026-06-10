Init a new machine:

```nix
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-facter ./facter.json  --flake .#yoga --target-host root@<ip address>


nix-shell -p ssh-to-age
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```


Note: to generate an ssh key (non-resident) with a yubikey:

```bash
ssh-keygen -t ed25519-sk -O verify-required -N "" -C "<username>@<hostname>" -f ./id_<yubikey-name>
```


change swap size:

```bash
sudo btrfs filesystem mkswapfile --size 32G /.swapvol/swapfile
```

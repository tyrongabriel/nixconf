# Init a new machine

Helpful docs: https://github.com/nix-community/disko/blob/master/docs/quickstart.md

Start machine on a live OS, connect to network.
set root password, enable ssh:

```bash
sudo passwd root
sudo systemctl enable sshd
sudo systemctl start sshd
```

## Generate facter.json

From the admin machine, generate the hardware report on the target and copy it back:

```bash
ssh root@<host> "nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixos-facter -- -o /tmp/facter.json"
scp root@<host>:/tmp/facter.json hosts/<host>/facter.json
```

Inspect the facter.json and update the host's config files accordingly:
- `disks.mod.nix` — update disk device IDs
- `boot.nix` — update CPU (Intel/AMD), GPU, PCI bus IDs, kernel modules

## Format drives with disko

Scp the disko config to the target:

```bash
scp ./hosts/<host>/disks.mod.nix root@<ip>:/tmp/disk-config.nix
```

Format and mount:

```bash
ssh root@<ip> "nix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix"
```

Verify with `ssh root@<ip> mount | grep /mnt`

## Minimal install

Generate the hardware config and copy the disko config:

```bash
ssh root@<ip> "nixos-generate-config --no-filesystems --root /mnt"
ssh root@<ip> "cp /tmp/disk-config.nix /mnt/etc/nixos/"
```

Set the following config in `/mnt/etc/nixos/configuration.nix`:

```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disk-config.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "<hostname>";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Vienna";

  # Enable flakes for the post-install onboarding
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Root SSH access with tyron's keys — needed for post-install onboarding
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBY2DkFamhhD8nnS8zqCnJRMD2GKvmiV9QQk+1dfA/Z tyron@legion"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsJ5MFDfXhkemPUaDDL2Ozkxj8m+90+HYs80om11q7ZAAAACXNzaDp5dXN1Zg== tyron@yusuf"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIC0zX/W36xFcPSeDnhJKZrOaWUeKIXkDFA+i/IZpRrXGAAAACXNzaDp5ZWxlbg== tyron@yelen"
  ];

  system.stateVersion = "26.05";
}
```

Install and reboot:

```bash
ssh root@<ip> "nixos-install --root /mnt"
ssh root@<ip> reboot
```

## Post-install — apply the flake config

After reboot, SSH in as root:

```bash
ssh root@<ip>
```

### 1. Create placeholder secrets files (on admin machine)

The flake expects encrypted SOPS files to exist before it can build:

```bash
mkdir -p hosts/<host>/secrets/users

# Generate .sops.yaml rules for the new host (needs keys.json to exist)
just regenerate-sops

echo 'placeholder: null' > hosts/<host>/secrets/secrets.yaml
sops -e -i hosts/<host>/secrets/secrets.yaml

echo 'placeholder: null' > hosts/<host>/secrets/users/tyron.yaml
sops -e -i hosts/<host>/secrets/users/tyron.yaml
```

### 2. Onboard — fetch host key, rekey secrets, apply flake

```bash
just onboard-machine <host> root@<ip>
```

This does:
- Fetches the machine's SSH host ed25519 key, converts it to an age key
- Writes `hosts/<host>/secrets/keys.json`
- Regenerates `.sops.yaml` with rules for this host
- Re-keys all encrypted secrets (now decryptable by the host)
- Copies the flake and applies it via `colmena apply --build-on-target`

### 3. Add your user age key and per-user secrets

```bash
just generate-user-age-key tyron <host>
just init-user-secrets <host> tyron
```

Then re-apply to pick up the new secrets:

```bash
colmena apply --on <host> --build-on-target
```


# Init a new remote machine (nixos-anywhere)

```nix
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-facter ./facter.json  --flake .#yoga --target-host root@<ip address>


nix-shell -p ssh-to-age
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```


# Misc
generate an ssh key (non-resident) with a yubikey:

```bash
ssh-keygen -t ed25519-sk -O verify-required -N "" -C "<username>@<hostname>" -f ./id_<yubikey-name>
```


change swap size:

```bash
sudo btrfs filesystem mkswapfile --size 32G /.swapvol/swapfile
```

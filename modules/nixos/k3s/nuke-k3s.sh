#!/usr/bin/env bash

# ==============================================================================
# NIXOS SNIPPET TO IMPORT THIS SCRIPT AND MAKE IT AVAILABLE IN PATH:
#
# Add the following to your NixOS configuration (e.g., configuration.nix):
#
# environment.systemPackages = [
#   (pkgs.writeScriptBin "nuke-k3s" (builtins.readFile ./nuke-k3s.sh))
# ];
#
# Remember to make this script executable beforehand, or Nix will handle it if
# you use writeScriptBin.
# ==============================================================================

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

echo "WARNING: This script will destructively remove K3s and its data."
read -p "Are you sure you want to proceed? [y (confirm steps) / a (yes to all) / n (quit)]: " init_ans

case "$init_ans" in
    [yY]) YES_TO_ALL=false ;;
    [aA]) YES_TO_ALL=true ;;
    *) echo "Aborting."; exit 0 ;;
esac

# Helper function to ask for confirmation if YES_TO_ALL is false
confirm_step() {
    local msg="$1"
    if $YES_TO_ALL; then
        return 0
    fi
    read -p ">>> $msg [y/N]: " ans
    case "$ans" in
        [yY]) return 0 ;;
        *) return 1 ;;
    esac
}

if confirm_step "Stop K3s processes?"; then
    echo "Stopping k3s systemd service..."
    systemctl stop k3s 2>/dev/null

    echo "Killing remaining k3s, k3s-agent, and containerd-shim processes..."
    killall k3s k3s-agent containerd-shim 2>/dev/null
else
    echo "Skipping process termination."
fi

if confirm_step "Unmount K3s filesystems?"; then
    # Using a loop to handle nested mounts that might need multiple passes
    for base_mount in /run/k3s /run/containerd /var/lib/kubelet /var/lib/rancher; do
        echo "Scanning for active mounts under $base_mount..."
        # Find mounts and unmount them
        grep "$base_mount" /proc/mounts | cut -d ' ' -f 2 | sort -r | while read -r m; do
            if [ -n "$m" ]; then
                echo "Unmounting $m..."
                umount -l "$m"
            fi
        done
    done
else
    echo "Skipping unmounting filesystems."
fi

if confirm_step "Remove data directories?"; then
    directories=(
        "/var/lib/rancher/k3s"
        "/var/lib/kubelet"
        "/etc/rancher/k3s"
        "/run/k3s"
        "/run/containerd"
        "/var/lib/cni"
        "/var/log/pods"
        "/var/log/containers"
    )
    for dir in "${directories[@]}"; do
        echo "Removing directory: $dir"
        rm -rf "$dir"
    done
else
    echo "Skipping removal of data directories."
fi

if confirm_step "Clean up networking interfaces?"; then
    interfaces=(cni0 flannel.1 flannel-v6.1 kube-ipvs0 nodelocaldns)
    for iface in "${interfaces[@]}"; do
        if ip link show "$iface" > /dev/null 2>&1; then
            echo "Deleting network interface: $iface"
            ip link delete "$iface"
        fi
    done
else
    echo "Skipping cleanup of networking interfaces."
fi

if confirm_step "Reset IPTables rules (Warning: Deletes ALL rules)?"; then
    echo "Flushing and deleting IPTables filter rules..."
    iptables -F
    iptables -X

    echo "Flushing and deleting IPTables nat rules..."
    iptables -t nat -F
    iptables -t nat -X

    echo "Flushing and deleting IPTables mangle rules..."
    iptables -t mangle -F
    iptables -t mangle -X
else
    echo "Skipping IPTables reset."
fi

echo "Cleanup phase complete."
echo "Note: If you haven't already, set 'services.k3s.enable = false' in your NixOS config and run 'nixos-rebuild switch'."

# This prompt is required even if 'A' (Yes to all) was selected at the beginning
read -p "Do you want to restart the system now? [y/N]: " reboot_ans
case "$reboot_ans" in
    [yY])
        echo "Rebooting system..."
        reboot
        ;;
    *)
        echo "Skipping reboot. Please reboot manually later."
        ;;
esac

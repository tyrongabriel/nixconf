# Talos images

For netcup: https://factory.talos.dev/?arch=amd64&bootloader=auto&cmdline=net.ifnames%3D0+console%3DttyS0%2C115200n8&cmdline-set=true&extensions=-&extensions=siderolabs%2Famd-ucode&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Fnetbird&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.12.6

ISO: https://factory.talos.dev/image/3ff60e854df49c7ffb10eb23d9d17e9f08f086f4df3a1415ca3f6d6c578e6b61/v1.12.6/nocloud-amd64.iso
RAW: https://factory.talos.dev/image/3ff60e854df49c7ffb10eb23d9d17e9f08f086f4df3a1415ca3f6d6c578e6b61/v1.12.6/nocloud-amd64.raw.xz
```yaml
customization:
    extraKernelArgs:
        - net.ifnames=0
        - console=ttyS0,115200n8
    systemExtensions:
        officialExtensions:
            - siderolabs/amd-ucode
            - siderolabs/iscsi-tools
            - siderolabs/netbird
            - siderolabs/qemu-guest-agent
```

Download and convert to qcow2:
```bash
curl -L https://factory.talos.dev/image/3ff60e854df49c7ffb10eb23d9d17e9f08f086f4df3a1415ca3f6d6c578e6b61/v1.12.6/nocloud-amd64.raw.xz --output talos-amd64-nocloud-netbird.raw.xz
xz -d talos-amd64-nocloud-netbird.raw.xz
qemu-img convert -f raw -O qcow2 talos-amd64-nocloud-netbird.raw talos-amd64-nocloud-netbird.qcow2
rm -f talos-amd64-nocloud-netbird.raw
```

## Generate secrets

```bash
sops talenv.sops.yaml # Write NETBIRD_SETUP_KEY: "<key>"
talhelper gensecret > talsecret.sops.yaml
sops -e -i talsecret.sops.yaml
```

## Gen configs

```bash
talhelper genconfig \
  -s talsecret.sops.yaml \
  -e talenv.sops.yaml
```

## Apply config

```bash
talosctl apply-config \
  --insecure \
  --nodes 152.53.149.109 \
  --file clusterconfig/homelab-ncvps01.yaml
```

## Use talosctl

```bash
export TALOSCONFIG="./clusterconfig/talosconfig"
talosctl config endpoint api.cluster.netbird.cloud
talosctl config node 152.53.149.109

# Bootstrap (ONLY ONCE!)
talosctl bootstrap
# Wait a bit, fetch kubeconfig
talosctl kubeconfig .
export KUBECONFIG=./kubeconfig # Or palce it into ~/.kube/config
```

## Install Cilium

```bash
cilium install \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445
```

## Bootstrap FluxCD

```bash
export GITHUB_TOKEN="$(wl-paste)"
flux bootstrap github \
  --owner=tyrongabriel \
  --repository=nixconf \
  --branch=main \
  --path=./kubernetes/cluster \
  --personal
```

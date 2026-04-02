To nuke libvirt:

```bash
sudo sh -c 'for dom in $(virsh list --all --name); do virsh destroy $dom; virsh undefine $dom --remove-all-storage; done && for net in $(virsh net-list --all --name); do virsh net-destroy $net; virsh net-undefine $net; done && for pool in $(virsh pool-list --all --name); do virsh pool-destroy $pool; virsh pool-undefine $pool; done && rm -rf /var/lib/libvirt/images/*'
```

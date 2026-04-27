# Secrets
We need to tell fluxcd what its agekey is, create a key with `age-keygen -o /tmp/fluxcd.key` and add the public key to `fluxcd.sops.yaml`, copy ONLY the private key, not the whole file with comments, and create the k8s secret:
```bash
wl-paste | k create secret generic sops-age --namespace=flux-system --from-file=age.agekey=/dev/stdin
```

borg create --stats --progress -C zstd,6 \
    /run/media/tyron/BACK/yoga-back::back-$(date +%Y%m%d_%H%M%S) \
    ~/Documents \
    ~/university \
    ~/.ssh \
    ~/.kube \
    ~/.talos \
    ~/.thunderbird \
    ~/Pictures \
    ~/Videos \
    ~/Zotero

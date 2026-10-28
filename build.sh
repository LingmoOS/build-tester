#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

cd "$(dirname "$0")"

lb clean --purge || true

lb config \
    --mode debian \
    --distribution trixie \
    --architecture amd64 \
    --binary-image iso-hybrid \
    --archive-areas "main contrib non-free-firmware" \
    --apt-recommends false \
    --initramfs live-boot \
    --bootloaders "grub-efi grub-pc" \
    --apt-options "-o DPkg::Options::=\"--force-confnew\" -y --option Acquire::Retries=5 --option Acquire::http::Timeout=30" \
    --debootstrap-options "--include=ca-certificates" \
    --bootappend-live "boot=live components username=lingmo hostname=lingmo" \
    --bootappend-install "net.ifnames=0" \
	--iso-application "Lingmo OS" \
	--iso-publisher "Lingmo OS Community" \
	--iso-volume "Lingmo OS 5.x" \
	--linux-packages "linux-image linux-headers" \
	--memtest memtest86+ 

lb build

ISO="live-image-amd64.hybrid.iso"
if [[ ! -f "$ISO" ]]; then
    echo "Expected ISO was not produced: $ISO" >&2
    exit 1
fi

NAME="${1:-lingmo-os-nightly-amd64}"
mv "$ISO" "$NAME.iso"
if [[ -f live-image-amd64.packages ]]; then
    mv live-image-amd64.packages "$NAME.packages"
fi

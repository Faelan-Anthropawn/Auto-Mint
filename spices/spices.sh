#!/bin/bash
########################################
# Replace Cinnamon Spices Directory
########################################

echo "Downloading and replacing Cinnamon spices directory..."

SPICES_URL="https://github.com/Faelan-Anthropawn/Auto-Mint/tree/main/spices"

TARGET_DIR="$HOME/.config/cinnamon/spices"

rm -rf "$TARGET_DIR/*"

mkdir -p "$TARGET_DIR"

git clone --depth 1 --filter=blob:none --sparse https://github.com/Faelan-Anthropawn/Auto-Mint.git "$TMPDIR/Auto-Mint"

cd "$TMPDIR/Auto-Mint"

git sparse-checkout set spices

cp -r "$TMPDIR/Auto-Mint/spices/." "$TARGET_DIR/"

rm -rf "$TMPDIR/Auto-Mint"

echo "Cinnamon spices directory has been successfully replaced with the latest files from GitHub."

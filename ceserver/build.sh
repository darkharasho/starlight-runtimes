#!/usr/bin/env bash
# Builds ceserver (Cheat Engine's Linux memory server) and its extension from
# the GPLv2 Cheat Engine source at CE_TAG, with starlight.patch applied, and
# zips them as ceserver-<tag>-linux-x64.zip.
#
#   ceserver/build.sh [out-dir]
#
# Build on an old distro (CI uses ubuntu-22.04) so the binary runs on any
# newer glibc.
set -euo pipefail

CE_TAG="${CE_TAG:-7.5}"
here="$(cd "$(dirname "$0")" && pwd)"
out="$(mkdir -p "${1:-$here/../dist}" && cd "${1:-$here/../dist}" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

git clone -q --depth 1 --branch "$CE_TAG" --filter=blob:none --sparse \
  https://github.com/cheat-engine/cheat-engine.git "$work/src"
git -C "$work/src" sparse-checkout set "Cheat Engine/ceserver"
git -C "$work/src" apply "$here/starlight.patch"

# The 2022-era source trips modern GCC's stricter defaults.
lenient="-w -Wno-error=int-conversion -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration"
srv="$work/src/Cheat Engine/ceserver"
make -C "$srv/gcc" -j"$(nproc)" \
  CFLAGS="-O2 -MMD -MP -Doff64_t=__off64_t $lenient"
make -C "$srv/extension/gcc" -j"$(nproc)" \
  CFLAGS="-O2 -fPIC -MMD -MP $lenient"

name="ceserver-$CE_TAG"
stage="$work/stage/$name"
mkdir -p "$stage"
install -m755 "$srv/gcc/ceserver" "$stage/ceserver"
# ceserver loads the extension from its own directory by this exact name.
install -m755 "$srv/extension/gcc/libceserver-extension.so" "$stage/libceserver-extension_x86_64.so"
strip "$stage/ceserver" "$stage/libceserver-extension_x86_64.so"
cp "$here/../LICENSE.gpl-v2.txt" "$stage/"
cp "$here/starlight.patch" "$stage/"
cat > "$stage/SOURCE.md" <<MD
Built from https://github.com/cheat-engine/cheat-engine at tag $CE_TAG
("Cheat Engine/ceserver"), GPLv2, with starlight.patch applied:
- listens on 127.0.0.1 only,
- no LAN discovery broadcast,
- finds its extension even when its path contains spaces.
Build script: https://github.com/darkharasho/starlight-runtimes/blob/main/ceserver/build.sh
MD

zip="$out/$name-linux-x64.zip"
rm -f "$zip"
(cd "$work/stage" && zip -qr "$zip" "$name")
echo "zip: $zip"
echo "sha256: $(sha256sum "$zip" | cut -d' ' -f1)"
echo "size: $(stat -c %s "$zip")"

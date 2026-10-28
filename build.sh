#!/bin/bash
# runs on the crave build node inside the workspace root:
#   crave run --no-patch -- "curl -fsSL https://raw.githubusercontent.com/raihanadf/local_manifests/main/build.sh | bash"
set -e

# switch the workspace to evolution x a16 and add the garnet trees
repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs
rm -rf .repo/local_manifests
git clone --depth 1 https://github.com/raihanadf/local_manifests .repo/local_manifests
/opt/crave/resync.sh

# build
source build/envsetup.sh
lunch lineage_garnet-bp4a-userdebug
m evolution

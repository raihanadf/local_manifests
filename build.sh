#!/bin/bash
# runs on the crave build node inside the lineageos 23.2 workspace root (crave project 99):
#   crave run --no-patch -- "curl -fsSL https://raw.githubusercontent.com/raihanadf/local_manifests/main/build.sh | bash"
set -e
REPO_RAW=https://raw.githubusercontent.com/raihanadf/local_manifests/main

# garnet trees
rm -rf .repo/local_manifests
git clone --depth 1 https://github.com/raihanadf/local_manifests .repo/local_manifests
/opt/crave/resync.sh

# kernelsu-next built into the kernel, latest release tag on every build (needs CONFIG_KPROBES, already on in gki_defconfig)
(cd kernel/xiaomi/sm7435 && curl -fsSL https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/dev/kernel/setup.sh | bash -)

# inline signing keys: generated once, kept in the workspace, never uploaded anywhere
# losing them means the next build needs a data wipe, so back them up with crave pull after the first build
KEYS=vendor/lineage-priv/keys
if [ ! -f $KEYS/testkey.pk8 ]; then
    mkdir -p $KEYS
    for f in keys.mk keys.sh make_key.sh BUILD.bazel; do
        curl -fsSL $REPO_RAW/keys/$f -o $KEYS/$f
    done
    # aosp make_key always exits 1 (trap on EXIT), so judge success by the files below instead
    (cd $KEYS && chmod +x keys.sh make_key.sh && ./keys.sh) || true
fi
for k in testkey platform shared media networkstack $(grep -o ':.*override' $KEYS/keys.mk | cut -c2- | sort -u); do
    [ -f $KEYS/$k.pk8 ] || { echo "missing signing key $KEYS/$k.pk8"; exit 1; }
done

# build
source build/envsetup.sh
lunch lineage_garnet-bp4a-userdebug
m bacon

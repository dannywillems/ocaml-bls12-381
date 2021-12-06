COMMIT="bf24f2bce2a137afa2bbc52f0bbb44cc8ce5680b"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TMP_DIRECTORY=$(mktemp -d)
cd ${TMP_DIRECTORY}
wget https://github.com/supranational/blst/archive/${COMMIT}.zip
unzip ${COMMIT}.zip
cd blst-${COMMIT}
diff -qr . $SCRIPT_DIR/../src/blst/libblst

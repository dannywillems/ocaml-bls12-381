COMMIT="757aa00a90c03779f70d0ddab6bc84b40861bb4b"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TMP_DIRECTORY=$(mktemp -d)
cd ${TMP_DIRECTORY}
wget https://github.com/supranational/blst/archive/${COMMIT}.zip
unzip ${COMMIT}.zip
cd blst-${COMMIT}
diff -qr . $SCRIPT_DIR/../src/blst/libblst

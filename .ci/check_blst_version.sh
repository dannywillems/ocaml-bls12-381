COMMIT="ab335a9a5e5b691ffb919813e7115809584474dd"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TMP_DIRECTORY=$(mktemp -d)
cd ${TMP_DIRECTORY}
wget https://github.com/supranational/blst/archive/${COMMIT}.zip
unzip ${COMMIT}.zip
cd blst-${COMMIT}
diff -qr . $SCRIPT_DIR/../src/libblst

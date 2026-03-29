#!/bin/bash

# TrimUI Brick Deployment Script
# Builds ARM64 binary and deploys to device via FTP

set -e

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Configuration with defaults
PROJECT_NAME="${PROJECT_NAME:-my-brick-app}"
PAK_NAME="${PAK_NAME:-${PROJECT_NAME}.pak}"
BRICK_IP="${BRICK_IP:-192.168.0.142}"
BRICK_PASS="${BRICK_PASS:-tina}"
FTP_USER="${FTP_USER:-minui:minui}"
DEPLOY_DIR="deploy/${PAK_NAME}"

echo "Building for TrimUI Brick..."
make brick

echo "Assembling PAK folder..."
rm -rf deploy
mkdir -p "${DEPLOY_DIR}"

echo "Copying binary..."
cp "${PROJECT_NAME}-brick" "${DEPLOY_DIR}/${PROJECT_NAME}"

# Copy assets if they exist
if [ -d "assets" ]; then
    echo "Copying assets..."
    mkdir -p "${DEPLOY_DIR}/assets"
    cp -r assets/* "${DEPLOY_DIR}/assets/"
fi

echo "Creating launch.sh..."
cat > "${DEPLOY_DIR}/launch.sh" << EOF
#!/bin/sh
cd "\$(dirname "\$0")"
export SDL_VIDEODRIVER=kmsdrm
export SDL_AUDIODRIVER=alsa
./${PROJECT_NAME} 2>./debug.log
EOF
chmod +x "${DEPLOY_DIR}/launch.sh"

echo "PAK ready at: ${DEPLOY_DIR}"

echo "Clearing existing PAK folder on Brick..."
BRICK_PAK_PATH="/mnt/SDCARD/Tools/tg5040/${PAK_NAME}"
sshpass -p "${BRICK_PASS}" ssh -q root@${BRICK_IP} "rm -rf '${BRICK_PAK_PATH}' && mkdir -p '${BRICK_PAK_PATH}'"

echo "Transferring to Brick via FTP..."
BRICK_FTP_PATH="Tools/tg5040/${PAK_NAME// /%20}"

# Upload launch script and binary
curl -T "${DEPLOY_DIR}/launch.sh" "ftp://${BRICK_IP}/${BRICK_FTP_PATH}/" --user "${FTP_USER}" --silent
curl -T "${DEPLOY_DIR}/${PROJECT_NAME}" "ftp://${BRICK_IP}/${BRICK_FTP_PATH}/" --user "${FTP_USER}" --silent

# Upload assets if they exist
if [ -d "${DEPLOY_DIR}/assets" ]; then
    echo "Uploading assets..."
    sshpass -p "${BRICK_PASS}" ssh -q root@${BRICK_IP} "mkdir -p '${BRICK_PAK_PATH}/assets'"
    for file in "${DEPLOY_DIR}/assets"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            curl -T "$file" "ftp://${BRICK_IP}/${BRICK_FTP_PATH}/assets/" --user "${FTP_USER}" --silent
        fi
    done
fi

echo "Cleaning up..."
rm -f "${PROJECT_NAME}-brick"

echo "Done! Launch ${PAK_NAME} from the Tools menu on your Brick."

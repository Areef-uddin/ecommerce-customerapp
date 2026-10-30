#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.1"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/flutter"
FLUTTER_ROOT="${CACHE_DIR}/${FLUTTER_VERSION}"
FLUTTER_ARCHIVE="${CACHE_DIR}/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [[ ! -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
  mkdir -p "${CACHE_DIR}"
  echo "Downloading Flutter ${FLUTTER_VERSION}..."
  curl --fail --location --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    --output "${FLUTTER_ARCHIVE}"
  
  echo "Extracting Flutter SDK..."
  rm -rf "${CACHE_DIR}/flutter"
  tar -xJf "${FLUTTER_ARCHIVE}" -C "${CACHE_DIR}"
  rm -rf "${FLUTTER_ROOT}"
  mv "${CACHE_DIR}/flutter" "${FLUTTER_ROOT}"
  rm -f "${FLUTTER_ARCHIVE}"
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"
flutter config --enable-web --no-analytics
flutter pub get

API_URL="${API_BASE_URL:-https://ecommerce-backened-jsiy.onrender.com/api}"
echo "Building Flutter Web with API_BASE_URL=${API_URL}..."
flutter build web --release --no-pub --dart-define=API_BASE_URL="${API_URL}"

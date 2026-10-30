#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.1"
FLUTTER_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/flutter/${FLUTTER_VERSION}"
FLUTTER_ARCHIVE="${XDG_CACHE_HOME:-$HOME/.cache}/flutter/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [[ ! -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
  mkdir -p "${FLUTTER_ROOT}"
  curl --fail --location --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    --output "${FLUTTER_ARCHIVE}"
  tar -xJf "${FLUTTER_ARCHIVE}" -C "$(dirname "${FLUTTER_ROOT}")"
  mv "$(dirname "${FLUTTER_ROOT}")/flutter" "${FLUTTER_ROOT}"
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"
flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release --no-pub

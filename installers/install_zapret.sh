#!/bin/sh
set -e  # выходим при любом не-0 статусе

install_zapret() {
    echo "Установка zapret..."
    apk update

    VERSION="v70.20250505"
    ARCH="mipsel_24kc"
    BASE_URL="https://github.com/remittor/zapret-openwrt/releases/download"
    LINK="${BASE_URL}/${VERSION}/zapret_${VERSION}_${ARCH}.zip"

    TMP_DIR=$(mktemp -d /tmp/zapret.XXXXXX)
    [ -d "$TMP_DIR" ] || { echo "Не удалось создать временную директорию."; exit 1; }

    ZIP_FILE="$TMP_DIR/zapret.zip"
    wget -O "$ZIP_FILE" "$LINK"

    apk add unzip
    unzip "$ZIP_FILE" -d "$TMP_DIR"

    APK_DIR="$TMP_DIR/apk"
    [ -d "$APK_DIR" ] || { echo "Каталог apk не найден"; exit 1; }

    for pkg in "$APK_DIR"/*.apk; do
      apk add --allow-untrusted "$pkg"
    done

    rm -rf "$TMP_DIR"
    echo "Установка zapret завершена."
}

install_zapret "$@"
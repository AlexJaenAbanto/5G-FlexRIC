#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONF_DIR="${HOME}/flexric_conf"
XAPPS_DIR="${HOME}/xapps"

echo "[+] Preparando directorios..."
mkdir -p "$CONF_DIR" "$XAPPS_DIR"
cp "$DIR/configs/flexric.conf" "$CONF_DIR/flexric.conf"

echo "[+] Compilando imagen Docker de FlexRIC..."
cd "$DIR"
docker build -t flexric:latest -f docker/Dockerfile.flexric.ubuntu .

echo "[+] Desplegando contenedor flexric-ric..."
docker stop flexric-ric 2>/dev/null || true
docker rm flexric-ric 2>/dev/null || true

docker run -d \
  --name flexric-ric \
  --restart unless-stopped \
  --net=host \
  --privileged \
  -v "$CONF_DIR/flexric.conf":/usr/local/etc/flexric/flexric.conf \
  -v "$XAPPS_DIR":/xapps \
  flexric:latest \
  nearRT-RIC -c /usr/local/etc/flexric/flexric.conf

echo "[OK] FlexRIC desplegado y escuchando en E2 (36421) y E42 (36422)."

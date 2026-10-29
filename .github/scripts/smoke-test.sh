#!/usr/bin/env bash
# Smoke-test a YACReaderLibraryServer image:
#   - the container starts and the healthcheck passes
#   - the archive backend can really open comics (creates a library from
#     generated CBZ/CB7 files and checks every comic was processed)
#   - the HTTP API answers
#
# Usage: .github/scripts/smoke-test.sh <image>
set -euo pipefail

image="${1:?usage: smoke-test.sh <image>}"
name="yacr-smoke-$$"
work="$(mktemp -d)"

cleanup() {
    status=$?
    if [ "$status" -ne 0 ]; then
        echo "---- container log ----"
        docker logs "$name" 2>&1 || true
    fi
    docker rm -f "$name" > /dev/null 2>&1 || true
    rm -rf "$work" 2> /dev/null || true
    exit "$status"
}
trap cleanup EXIT

mkdir -p "$work/comics" "$work/config"

# Build test comics with nothing but the Python standard library.
python3 - "$work/comics" << 'PY'
import struct, sys, zipfile, zlib
from pathlib import Path

def png(w, h, rgb):
    raw = b"".join(b"\x00" + bytes(rgb) * w for _ in range(h))
    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw))
            + chunk(b"IEND", b""))

out = Path(sys.argv[1])
pages = out / "pages"
pages.mkdir()
for i in range(3):
    (pages / f"{i:02}.png").write_bytes(png(60, 90, (60 * i, 90, 150)))
with zipfile.ZipFile(out / "smoke.cbz", "w") as z:
    for p in sorted(pages.iterdir()):
        z.write(p, p.name)
PY

expected=1
if command -v 7z > /dev/null 2>&1; then
    (cd "$work/comics/pages" && 7z a -bd ../smoke.cb7 ./*.png > /dev/null)
    expected=2
fi
rm -rf "$work/comics/pages"
echo "Test comics: $(cd "$work/comics" && ls)"

docker run -d --name "$name" \
    -e PUID="$(id -u)" -e PGID="$(id -g)" -e TZ=Etc/UTC \
    -v "$work/config:/config" -v "$work/comics:/comics" \
    -p 127.0.0.1::8080 \
    "$image" > /dev/null

echo "Waiting for the container to become healthy..."
health=starting
for _ in $(seq 1 60); do
    if [ "$(docker inspect -f '{{.State.Running}}' "$name")" != "true" ]; then
        echo "Container exited"
        exit 1
    fi
    health="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$name")"
    [ "$health" = "healthy" ] && break
    sleep 2
done
if [ "$health" != "healthy" ]; then
    echo "Container did not become healthy (status: $health)"
    exit 1
fi
echo "Healthy."

out="$(docker exec -u abc "$name" YACReaderLibraryServer create-library smoke /comics 2>&1)"
echo "$out"
if ! grep -q "Number of comics processed = ${expected}\b" <<< "$out"; then
    echo "Expected ${expected} comics to be processed"
    exit 1
fi
docker exec -u abc "$name" YACReaderLibraryServer list-libraries | grep -q smoke

port="$(docker port "$name" 8080/tcp | head -n1 | sed 's/.*://')"
version="$(curl -fsS "http://127.0.0.1:${port}/v2/version")"
echo "API version: ${version}"

echo "Smoke test passed."

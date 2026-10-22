#!/usr/bin/env bash
# Install the Muse / Hatch agent platform on a Linux x86-64 host.
set -euo pipefail

BASE="${MUSE_RELEASE_BASE:-https://github.com/Xyzjdh/muse-agent-platform/releases/download/v1.0}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> Downloading agent archives from $BASE"
for f in hatch-engine.tar.gz hatch-data.tar.gz muse-assets.tar.gz muse-skills.tar.gz; do
  echo "    - $f"
  curl -fsSL -o "$WORK/$f" "$BASE/$f"
done

echo "==> Extracting to /"
# Engine + data archives use paths relative to /opt/hatch
tar xzf "$WORK/hatch-engine.tar.gz" -C /
tar xzf "$WORK/hatch-data.tar.gz"  -C /
# Muse archives use paths relative to /opt/muse
tar xzf "$WORK/muse-assets.tar.gz" -C /
tar xzf "$WORK/muse-skills.tar.gz" -C /

echo "==> Fixing ownership"
chown -R nobody:nogroup /opt/hatch /opt/muse 2>/dev/null || true

echo "==> Creating runtime directories"
mkdir -p /run/hatch/{auth,proxy,daemon,sentinel,sandbox-api,telemetry,ingress} \
         /var/lib/hatch-runtime/rootfs \
         /var/log/hatch

echo "==> Installing base environment"
if [ ! -f /etc/hatch/env ]; then
  mkdir -p /etc/hatch
  cat > /etc/hatch/env <<'EOF'
JARVIS_HOME=/home/hatch
JARVIS_BIN_DIR=/opt/hatch/bin
JARVIS_AUTHD_SOCK=/run/hatch/auth/authd.sock
JARVIS_INFERENCE_PROXY_SOCK=/run/hatch/proxy/inference.sock
JARVIS_STEFI_PROXY_SOCK=/run/hatch/proxy/stefi.sock
RUST_LOG=info
EOF
  : > /etc/hatch/env.override
else
  echo "    /etc/hatch/env already exists — left untouched"
fi

echo "==> Verifying"
/opt/hatch/bin/hatch --version
echo "    skills:   $(ls /opt/hatch/skills 2>/dev/null | wc -l) entries"
echo "    workflow: $(ls /opt/hatch/workflow-skills 2>/dev/null | wc -l) entries"
echo "    muse:     $(ls /opt/muse/skills 2>/dev/null | wc -l) entries"

cat <<'EOF'

Install complete.

Start the daemon:

    /opt/hatch/bin/hatch daemon &

Then connect a channel (Telegram/Slack) and run:

    /opt/hatch/bin/hatch agents list
EOF

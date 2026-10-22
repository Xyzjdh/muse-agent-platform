# Muse / Hatch Agent Platform

Complete agent platform — **engine binaries, skills, connectors, and runtime assets**.

This is the full `hatch` agent stack from Muse (muse.ai), not just the skill definitions.
The `hatch` daemon binary is the agent engine; the skill and connector files are what it drives.

## Components

| Archive | Uncompressed | Contents |
|---------|--------------|----------|
| `hatch-engine.tar.gz` | 1.7 GB | **Agent engine** — `hatch` daemon (488 MB Go binary, v0.1.0) + ~90 connector/CLI binaries + support daemons (`spawnd`, `hatch-execd`, `hatch-healthd`, `hatch-rescue`, `hatch-vault`, `authdc`, `browser-broker`, `browser-service`) |
| `hatch-data.tar.gz` | 520 MB | Runtime data — `assets/` (blocklist, ideas, artifacts), `skills/` (150 entries), `workflow-skills/` (54), `connectors/` (63 manifests), `runtime-cell/` (boot scripts, scope configs) |
| `muse-assets.tar.gz` | 165 MB | Muse skills assets — Spaces TypeScript runtime (libsql, Playwright, Bun), voice selector (50+ voices), booking data, artifact scripts |
| `muse-skills.tar.gz` | 1.2 MB | Muse workflow skills (54) |

Earlier uploads in this release (`muse-agent-platform.zip`, `muse-full-package.tar.gz`) contain only
`/opt/muse/` — **skills and assets, no engine**. Use the `hatch-engine` + `hatch-data` archives for a
working agent.

## Install

Target: Linux x86-64, root access.

```bash
# 1. Download
BASE=https://github.com/Xyzjdh/muse-agent-platform/releases/download/v1.0
curl -L -O $BASE/hatch-engine.tar.gz
curl -L -O $BASE/hatch-data.tar.gz
curl -L -O $BASE/muse-assets.tar.gz
curl -L -O $BASE/muse-skills.tar.gz

# 2. Extract to the filesystem root
sudo tar xzf hatch-engine.tar.gz -C /
sudo tar xzf hatch-data.tar.gz  -C /
sudo tar xzf muse-assets.tar.gz -C /
sudo tar xzf muse-skills.tar.gz -C /

# 3. Muse skills land in /opt/muse/ (tar paths are relative to /opt)
sudo ls /opt/muse/skills | head

# 4. Fix ownership (installer uses nobody:nogroup)
sudo chown -R nobody:nogroup /opt/hatch /opt/muse

# 5. Ensure runtime dirs exist
sudo mkdir -p /run/hatch/{auth,proxy,daemon,sentinel,sandbox-api,telemetry} /var/lib/hatch-runtime

# 6. Start the daemon
/opt/hatch/bin/hatch daemon --runtime-cell-leader=$$ &
```

Verify:

```bash
/opt/hatch/bin/hatch --version     # hatch 0.1.0 (8b82da8f825)
/opt/hatch/bin/hatch agents list
ps aux | grep hatch
```

## Runtime dependencies

The engine talks to these local sockets (created by the daemon and its support processes):

- `/run/hatch/auth/authd.sock` — credential vault
- `/run/hatch/proxy/inference.sock` — model inference
- `/run/hatch/proxy/stefi.sock` — egress policy
- `/run/hatch/sentinel/*.sock` — approvals, HTTP API
- `/run/hatch/sandbox-api/api.sock` — tool sandbox
- `/run/hatch/telemetry/telemetry.sock` — telemetry

Egress is proxied through `hatch-egress-proxy:3128` per `runtime-cell/guest.env`.
Set `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY` in `/etc/hatch/env` to match your network.

## Environment

`/etc/hatch/env` holds the managed environment (not shipped in these archives — it contains
host-specific IDs and sockets). Minimum keys for a fresh host:

```
JARVIS_HOME=/home/hatch
JARVIS_BIN_DIR=/opt/hatch/bin
JARVIS_AUTHD_SOCK=/run/hatch/auth/authd.sock
JARVIS_INFERENCE_PROXY_SOCK=/run/hatch/proxy/inference.sock
JARVIS_STEFI_PROXY_SOCK=/run/hatch/proxy/stefi.sock
HTTP_PROXY=http://<egress-proxy>:3128
HTTPS_PROXY=http://<egress-proxy>:3128
ALL_PROXY=http://<egress-proxy>:3128
```

`/etc/hatch/env.override` is for local killswitches and debugging.

## Optional: headless Chromium

`/opt/meta-chromium` (667 MB) and `/opt/hatch-image` (101 MB) are the browser runtime used by the
`browser-broker` / `browser-service` binaries. Not included in these archives — copy them
separately if you need browser automation.

## Notes

- The engine is a stripped Go binary; no source is included.
- Binaries in `/opt/hatch/bin` are hardlinked in groups of 36 (multi-call dispatchers). `tar`
  preserves the links, so extraction reproduces the original layout.
- `hatch-data.tar.gz` includes `runtime-cell/` boot scripts that assume a systemd-nspawn
  container layout. For a bare-metal install, start the daemon directly as shown above and
  skip `launch-daemon.sh` / `pre-start.sh`.

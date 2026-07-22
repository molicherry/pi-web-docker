# pi-web-docker

[中文文档](README.zh.md)

Dockerized deployment of [agegr/pi-web](https://github.com/agegr/pi-web) — the web UI for [pi coding agent](https://pi.dev).

This repo contains **only Docker configuration**. The WebUI source is pulled directly from the upstream [agegr/pi-web](https://github.com/agegr/pi-web) repo at build time.

## Quick Start

```bash
git clone https://github.com/molicherry/pi-web-docker.git
cd pi-web-docker
cp .env.example .env
# edit .env — set API key, adjust PUID/PGID
docker compose up -d
```

Pin a version in `.env` (e.g. `PI_WEB_VERSION=v0.7.16`) instead of using `latest`.

Open http://localhost:30141

### Build from Source

```bash
docker build -t ghcr.io/molicherry/pi-web-docker:latest --build-arg PI_WEB_VERSION=main .
docker compose up -d
```

## Prerequisites

- Docker (Docker Compose only needed for build-from-source)
- pi coding agent configured (`~/.pi/agent/` exists with `auth.json` or API key env var)
- If `~/.pi/agent/` doesn't exist yet, create it first: `mkdir -p ~/.pi/agent`
- Node.js 22+ (only for building from source, not needed in container)

## Volumes

| Host Path | Container Path | Purpose |
|---|---|---|
| `~/.pi/agent` | `/home/piuser/.pi/agent` | pi config, sessions, models, auth |
| `PI_WORKSPACE_DIR` (env) | `/workspace` | Project files |
| `PI_NPM_GLOBAL_DIR` (env) | `/home/piuser/.npm-global` | npm global packages (persistent) |

Set `PI_WORKSPACE_DIR` in `.env` to your project root. For projects outside that path, add additional volumes with **identical host and container paths**:

```yaml
volumes:
  - /home/you/projects:/home/you/projects
```

## Environment

| Variable | Default | Description |
|---|---|---|
| `PI_WEB_VERSION` | `main` | agegr/pi-web branch or tag |
| `PI_WEB_PORT` | `30141` | Host port |
| `PUID` / `PGID` | `1000` | Host user for file ownership |
| `PI_AGENT_DIR` | `~/.pi/agent` | pi config directory |
| `PI_WORKSPACE_DIR` | `~/pi-workspace` | Project directory mounted to `/workspace` |
| `PI_NPM_GLOBAL_DIR` | `~/.pi/npm-global` | npm global packages (persists across rebuilds) |
| `ANTHROPIC_API_KEY` | — | Anthropic API key |
| `OPENAI_API_KEY` | — | OpenAI API key |
| `DEEPSEEK_API_KEY` | — | DeepSeek API key |
| `GEMINI_API_KEY` | — | Google Gemini API key |

At least one API key is required. Additional provider keys can be added in `docker-compose.yml`. Or set them all in a mounted `auth.json` under `~/.pi/agent/`.

```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx
```


## Updating

```bash
docker compose pull
docker compose up -d
```

**Build from source:**

```bash
# Pull latest upstream, rebuild
docker compose build --no-cache
docker compose up -d
```

Or pin a specific version in `.env`:

```bash
PI_WEB_VERSION=v0.7.16
```

## Related

- [pi coding agent](https://pi.dev) — the CLI agent
- [agegr/pi-web](https://github.com/agegr/pi-web) — upstream WebUI

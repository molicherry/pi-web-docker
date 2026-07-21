# syntax=docker/dockerfile:1
# ── pi-web Docker ──────────────────────────────────────────────────
# Builds from upstream agegr/pi-web — no source in this repo.
# Multi-stage: git clone + npm build → slim runtime.
# ────────────────────────────────────────────────────────────────────

ARG PI_WEB_VERSION=main

# ─── Builder: clone upstream, install, build ───────────────────────
FROM node:22-bookworm-slim AS builder

WORKDIR /build

# 从上游 Git 仓库拉取
ADD https://github.com/agegr/pi-web.git#${PI_WEB_VERSION} .

# 安装依赖 + 构建 Next.js
RUN npm ci && npm run build && npm prune --omit=dev

# ─── Runtime: slim production image ────────────────────────────────
FROM node:22-bookworm-slim AS runtime

LABEL org.opencontainers.image.source="https://github.com/molicherry/pi-web-docker"
LABEL org.opencontainers.image.description="Dockerized pi-web — Web UI for pi coding agent"

# 系统工具
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git gosu procps ripgrep tini vim \
  && rm -rf /var/lib/apt/lists/*

# 运行时用户 (UID/GID 在容器启动时通过 --user 覆盖)
RUN useradd --create-home --shell /bin/bash piuser
ENV HOME=/home/piuser
ENV PI_CODING_AGENT_DIR=/home/piuser/.pi/agent

WORKDIR /app

# 从 builder 复制生产产物
COPY --from=builder /build/.next        ./.next
COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/package.json ./
COPY --from=builder /build/next.config.ts ./
COPY --from=builder /build/public      ./public

# 启动脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PI_WEB_NO_OPEN=1
ENV PI_OFFLINE=1
ENV PI_SKIP_VERSION_CHECK=1
ENV PORT=30141
ENV HOSTNAME=0.0.0.0

EXPOSE 30141
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]

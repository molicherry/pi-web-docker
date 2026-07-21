# pi-web-docker

[English](README.md)

[agegr/pi-web](https://github.com/agegr/pi-web) 的 Docker 化部署 —— [pi coding agent](https://pi.dev) 的 Web UI。

本仓库**仅包含 Docker 配置**，不包含 WebUI 源码。构建时直接从上游 [agegr/pi-web](https://github.com/agegr/pi-web) 拉取源码。

## 快速开始

```bash
git clone https://github.com/molicherry/pi-web-docker.git
cd pi-web-docker
cp .env.example .env
# 编辑 .env — 设置 API key，调整 PUID/PGID
docker compose up -d
```

如需锁定版本，在 `.env` 中设置 `PI_WEB_VERSION=v0.7.16`。

浏览器打开 http://localhost:30141

### 从源码构建

```bash
docker build -t ghcr.io/molicherry/pi-web-docker:latest --build-arg PI_WEB_VERSION=main .
docker compose up -d
```

## 前置条件

- Docker（仅从源码构建才需要 Docker Compose）
- pi coding agent 已配置（`~/.pi/agent/` 目录存在，包含 `auth.json` 或已设置 API key 环境变量）
- 如果 `~/.pi/agent/` 还不存在，先创建：`mkdir -p ~/.pi/agent`
- Node.js 22+（仅源码构建需要，容器内不需要）

## 卷挂载

| 宿主机路径 | 容器路径 | 用途 |
|---|---|---|
| `~/.pi/agent` | `/home/piuser/.pi/agent` | pi 配置、会话、模型、认证 |
| `PI_WORKSPACE_DIR`（环境变量） | `/workspace` | pi 工作的项目文件 |

在 `.env` 中设置 `PI_WORKSPACE_DIR` 指向你的项目根目录。如果项目在其他路径，添加额外卷挂载，**宿主机和容器路径必须一致**：

```yaml
volumes:
  - /home/you/projects:/home/you/projects
```

## 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `PI_WEB_VERSION` | `main` | agegr/pi-web 分支或 tag |
| `PI_WEB_PORT` | `30141` | 宿主机端口 |
| `PUID` / `PGID` | `1000` | 宿主机用户 ID，用于文件权限映射 |
| `PI_AGENT_DIR` | `~/.pi/agent` | pi 配置目录 |
| `PI_WORKSPACE_DIR` | `~/pi-workspace` | 挂载到 `/workspace` 的项目目录 |
| `ANTHROPIC_API_KEY` | — | Anthropic API key |
| `OPENAI_API_KEY` | — | OpenAI API key |
| `DEEPSEEK_API_KEY` | — | DeepSeek API key |
| `GEMINI_API_KEY` | — | Google Gemini API key |

至少需要配置一个 API key。其他 provider 可在 `docker-compose.yml` 中添加。也可以用挂载的 `~/.pi/agent/auth.json` 来管理所有 key。

```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx
```

## 更新

```bash
docker compose pull
docker compose up -d
```

**从源码构建：**

```bash
# 拉取最新上游代码，重建镜像
docker compose build --no-cache
docker compose up -d
```

或在 `.env` 中锁定版本：

```bash
PI_WEB_VERSION=v0.7.16
```

## 相关项目

- [pi coding agent](https://pi.dev) — CLI agent
- [agegr/pi-web](https://github.com/agegr/pi-web) — 上游 WebUI

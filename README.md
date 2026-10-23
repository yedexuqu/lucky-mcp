# lucky-mcp

Lucky（大吉）的 MCP 网关容器：把 [`@bearst/lucky-mcp-server`](https://github.com/BearstOzawa/lucky-mcp-server)（stdio MCP Server）用 [supergateway](https://github.com/supercorp-ai/supergateway) 包装成 **Streamable HTTP**，供 Octop 等 MCP 客户端远程接入。

通过 Lucky 的 OpenToken 调用 Lucky 3.x HTTP API，暴露 61 个工具：反向代理、SSL 证书、端口转发、DDNS、STUN/WOL、计划任务、FTP/WebDAV、Docker（只读）、IP 过滤、安全组、日志中心、Web 终端等。

## 架构

```
MCP 客户端 (Octop)
   │  streamable_http
   ▼
supergateway :8080/mcp        ← 本容器
   │  stdio
   ▼
lucky-mcp-server (Node 20)
   │  HTTP + openToken header
   ▼
Lucky 管理端 :16601（软路由）
```

## 部署

```bash
# 1. 配置环境变量（不要把 token 提交进仓库）
cp .env.example .env
vi .env   # 填 LUCKY_BASE_URL / LUCKY_OPEN_TOKEN

# 2. 构建并启动
docker compose up -d --build

# 3. 验证 MCP 握手
curl -s -X POST http://<host>:8092/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'
```

## MCP 客户端配置

```json
{
  "servers": {
    "lucky": {
      "transport": "streamable_http",
      "url": "http://<host>:8092/mcp",
      "enabled": true
    }
  }
}
```

如果客户端直接支持 stdio，也可以跳过网关：

```json
{
  "mcpServers": {
    "lucky": {
      "command": "npx",
      "args": ["-y", "@bearst/lucky-mcp-server"],
      "env": {
        "LUCKY_BASE_URL": "http://<lucky-host>:16601",
        "LUCKY_OPEN_TOKEN": "<open-token>"
      }
    }
  }
}
```

## 环境变量

| 变量 | 必填 | 说明 |
| --- | --- | --- |
| `LUCKY_BASE_URL` | 是 | Lucky 管理端根 URL（默认 `http://<router-ip>:16601`） |
| `LUCKY_OPEN_TOKEN` | 是 | OpenToken，在 Lucky 设置页签发 |
| `LUCKY_TIMEOUT_MS` | 否 | 请求超时毫秒（默认 15000） |
| `LUCKY_TLS_VERIFY` | 否 | Lucky HTTPS 自签证书时设 `false` |

网关端口：宿主 `8092` → 容器 `8080`，MCP 路径 `/mcp`。

## 安全说明

- OpenToken 等同于 Lucky 管理权限，**只在内网使用**，不要暴露公网
- `lucky_api_call` 已拒绝登录/登出/管理员密码/OpenToken/2FA/配置恢复/进程重启等敏感路径
- compose 中的真实 token 请用 `.env` 注入，不要提交进仓库

## License

MIT

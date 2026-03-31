# Custom AWS CloudWatch MCP & Log Helper

A specialized Model Context Protocol (MCP) server for AWS CloudWatch, bundled with rapid-access scripts, persistent memory, and AI-driven troubleshooting workflows.

---

## 📁 Project Structure

```text
.
├── memory.md               # 🧠 Persistent context (Log Groups, ARNs, Queries)
├── scripts/
│   └── aws_log_helper.sh   # ⚡ Fast log retrieval script
├── workflows/
│   └── log-investigation.md# 🛠 Multi-step investigation guide
├── Dockerfile              # 🐳 Containerized MCP server
├── pyproject.toml          # 📦 MCP server dependencies
└── README.md               # 📖 You are here
```

---

## 🧠 Using `memory.md` for AI Context

The `memory.md` file is designed to be provided as **immediate context** to your AI assistant. This eliminates the need for the AI to "discover" log groups manually, reducing latency and API calls.

### How to use it:
When starting a log-related task, include `@memory.md` in your prompt.

**Example Prompt:**
> "Using @memory.md, check the last 10 minutes of logs for the `web` service to see if there are any 500 errors."

### What's inside?
- **Mapped Log Groups**: Direct mapping of services (Web, Worker, Cron, Admin, DB) to their CloudWatch names.
- **Common Queries**: Pre-tested Log Insights queries for error spikes, user searches, and performance analysis.

---

## 🚀 Setup & Installation

### 1. Build the MCP Server
Build the Docker image to ensure AWS authentication and profiles are handled correctly within the container:
```bash
docker build -t custom/cloudwatch-mcp-server .
```

### 2. Configure Your AI Assistant
Add the following to your `mcp_config.json` (usually found in `~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json` or similar for other assistants):

```json
"cloudwatch": {
  "command": "docker",
  "args": [
    "run", "--rm", "-i",
    "-v", "/Users/YOUR_USER/.aws:/root/.aws:ro",
    "-e", "AWS_PROFILE=shark-dev-logs",
    "-e", "AWS_REGION=us-east-1",
    "-e", "AWS_SDK_LOAD_CONFIG=1",
    "-e", "AWS_CONFIG_FILE=/root/.aws/config",
    "-e", "AWS_SHARED_CREDENTIALS_FILE=/root/.aws/credentials",
    "custom/cloudwatch-mcp-server"
  ]
}
```
> [!IMPORTANT]
> Change `/Users/YOUR_USER/.aws` to your actual home directory path.

---

## 🛠 Features & Workflows

### 1. Rapid-Access Log Helper (`scripts/`)
A high-speed alternative to CloudWatch Insights for quick log tailing and basic checks.
- **Manual Usage**: `./scripts/aws_log_helper.sh [web|worker|cron] [duration]`
- **Example**: `./scripts/aws_log_helper.sh web 5m`

### 2. Standardized Workflows (`workflows/`)
Step-by-step guides for AI assistants to follow consistent troubleshooting procedures.
- **Log Investigation**: Mention `@[workflows/log-investigation.md]` to trigger a structured research and query phase.

### 3. Customized MCP Server
A Docker-hardened version of the standard AWS CloudWatch MCP server that resolves common volume mounting and AWS credential provider issues.

---

## 🤖 Example AI Prompts

- **The "One-Shot" Investigation**:
  > "Using @memory.md and @[workflows/log-investigation.md], find why user `uuid-123` is failing their deposit."
  
- **Quick Health Check**:
  > "@[scripts/aws_log_helper.sh] check the `worker` logs for the last 15m and summarize any errors."

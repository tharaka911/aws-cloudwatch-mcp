---
description: How to investigate logs for Sharkroll services (Web, Worker, Cron) in CloudWatch
---

# Log Investigation Workflow

Use this workflow to quickly query logs across different Sharkroll services.

## Service Mapping
| Service | Log Group | Purpose |
|---------|-----------|---------|
| **Web** | `/ecs/shark-dev-web` | REST API requests, public endpoints |
| **Worker** | `/ecs/shark-dev-worker` | Message broker consumers, background tasks |
| **Cron** | `/ecs/shark-dev-cron` | Scheduled tasks, rake-back, leader jobs |

## Fast Log Retrieval (Recommended)
For most investigations, use the rapid-access script located in the repository. It is significantly faster than standard Insights queries.

### 1. Using the Helper Script
```bash
./scripts/aws_log_helper.sh [web|worker|cron] [duration]
```
- **Execution**: Can be run by the user or the AI Assistant.
- **Example**: `./scripts/aws_log_helper.sh worker 5m`

---

## Detailed Analysis (MCP Server)
For complex filtering, use the **`custom/cloudwatch-mcp-server`**. This server is optimized to handle AWS profile mounting issues in Docker.

### Configuration
Ensure your `mcp_config.json` uses the `custom/cloudwatch-mcp-server` image with correctly mapped `AWS_CONFIG_FILE` and `AWS_SHARED_CREDENTIALS_FILE` environment variables.

---

## Search Parameters
When the user provides:
- **Date/Time**: Convert to epoch timestamps (use `date -v` on macOS).
- **User ID**: Filter for the exact string or look inside the `authorization` or `meta` JSON.
- **Endpoint**: Filter for the request path (e.g., `/api/v1/games/...`).

## Optimized CLI Templates (Fallback)

### 1. Request logs for a specific endpoint (Web)
```bash
aws logs start-query --log-group-name /ecs/shark-dev-web \
  --start-time $(date -v-1H +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ENDPOINT_NAME/ | sort @timestamp desc | limit 20' \
  --profile shark-dev-logs --region us-east-1
```

### 2. Error logs (Any service)
```bash
aws logs start-query --log-group-name LOG_GROUP_NAME \
  --start-time $(date -v-24H +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter level = "error" or @message like /error|exception|fail|500/ | sort @timestamp desc | limit 50' \
  --profile shark-dev-logs --region us-east-1
```

### 3. User-specific logs
```bash
aws logs start-query --log-group-name /ecs/shark-dev-web \
  --start-time $(date -v-24H +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /USER_ID/ | sort @timestamp desc | limit 50' \
  --profile shark-dev-logs --region us-east-1
```

---

## AI Instructions
1. **Prefer Optimized Path**: Start by using `./scripts/aws_log_helper.sh` if the request is a simple "check logs" or "tail logs" task.
2. **Detailed Research**: Use the `cloudwatch` MCP server for complex pattern matching or cross-log analysis.
3. **Identity & Mapping**:
   - Web: `/ecs/shark-dev-web`
   - Worker: `/ecs/shark-dev-worker`
   - Cron: `/ecs/shark-dev-cron`
4. **Output Management**: Redirect large log outputs to a temporary file (e.g., `/tmp/logs.txt`) before analysis to avoid context window flooding.

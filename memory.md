# CloudWatch MCP Memory

This file serves as a reference for log groups and common troubleshooting queries handled by this MCP server.

## ☁️ Sharkroll Dev Environment Log Groups

| Service | Log Group | Purpose |
| :--- | :--- | :--- |
| **Web API** | `/ecs/shark-dev-web` | Public REST API, entry point for player requests. |
| **Worker** | `/ecs/shark-dev-worker` | Message processing, async jobs. |
| **Cron** | `/ecs/shark-dev-cron` | Scheduled tasks, daily rewards, maintenance. |
| **Admin** | `/ecs/shark-dev-admin` | Internal back-office and admin panel activity. |
| **Database** | `/aws/rds/instance/shark-dev-db2/postgresql` | RDS PostgreSQL logs for debugging queries/locks. |

---

## 🔍 Common Log Insights Queries

### 1. Identify Error Spikes (Last 24h)
```text
fields @timestamp, @message, @logStream, @log
| filter level = "error" or @message like /error|exception|fail/
| stats count(*) by bin(1h)
```

### 2. Search for Specific User ID
```text
fields @timestamp, @message
| filter @message like /USER_UUID_HERE/
| sort @timestamp desc
| limit 50
```

### 3. Monitor High Response Times (Web)
```text
fields @timestamp, @message, responseTime
| filter responseTime > 1000
| sort responseTime desc
| limit 20
```

---

## 🚀 Speed Tip
To get logs quickly without complex queries, use the repository's helper script:
`./scripts/aws_log_helper.sh [service] [duration]`
*Example:* `./scripts/aws_log_helper.sh web 5m`

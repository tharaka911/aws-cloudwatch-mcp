#!/bin/bash

# Sharkroll AWS Log Helper
# Usage: ./aws_log_helper.sh [web|worker|cron] [duration (e.g., 2m, 1h)]

SERVICE=$1
DURATION=${2:-2m}
PROFILE="shark-dev-logs"
REGION="us-east-1"

case $SERVICE in
  web)
    LOG_GROUP="/ecs/shark-dev-web"
    ;;
  worker)
    LOG_GROUP="/ecs/shark-dev-worker"
    ;;
  cron)
    LOG_GROUP="/ecs/shark-dev-cron"
    ;;
  *)
    echo "Usage: $0 [web|worker|cron] [duration]"
    exit 1
    ;;
esac

# Convert duration to seconds for start-time
if [[ "$DURATION" == *m ]]; then
  SECONDS=$(( ${DURATION%m} * 60 ))
elif [[ "$DURATION" == *h ]]; then
  SECONDS=$(( ${DURATION%h} * 3600 ))
else
  SECONDS=$DURATION
fi

START_TIME=$(date -v-${SECONDS}S +%s)

echo "Fetching logs for $SERVICE ($LOG_GROUP) from the last $DURATION..."

QUERY_ID=$(aws logs start-query --log-group-name "$LOG_GROUP" \
  --start-time "$START_TIME" \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | sort @timestamp desc | limit 50' \
  --profile "$PROFILE" --region "$REGION" --output text --query 'queryId')

if [ -z "$QUERY_ID" ]; then
  echo "Failed to start query."
  exit 1
fi

echo "Query started (ID: $QUERY_ID). Waiting for results..."

while true; do
  STATUS=$(aws logs get-query-results --query-id "$QUERY_ID" --profile "$PROFILE" --region "$REGION" --output text --query 'status')
  if [ "$STATUS" == "Complete" ]; then
    break
  fi
  sleep 1
done

aws logs get-query-results --query-id "$QUERY_ID" --profile "$PROFILE" --region "$REGION" | \
  jq -r '.results[] | map(select(.field=="@timestamp") | .value) + map(select(.field=="@message") | .value) | join(" | ")'

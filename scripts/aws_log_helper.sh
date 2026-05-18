#!/bin/bash

# Sharkroll AWS Log Helper
# Usage: ./aws_log_helper.sh [dev|prod] [web|worker|cron|notification] [duration (e.g., 2m, 1h)]

if [[ "$1" == "dev" || "$1" == "prod" ]]; then
  ENV=$1
  SERVICE=$2
  DURATION=${3:-2m}
else
  ENV="dev"
  SERVICE=$1
  DURATION=${2:-2m}
fi

if [ "$ENV" == "prod" ]; then
  PROFILE="shark-prod-logs"
  REGION="eu-west-1"
  ENV_PREFIX="prod"
else
  PROFILE="shark-dev-logs"
  REGION="us-east-1"
  ENV_PREFIX="dev"
fi

case $SERVICE in
  web)
    LOG_GROUP="/ecs/shark-${ENV_PREFIX}-web"
    ;;
  worker)
    LOG_GROUP="/ecs/shark-${ENV_PREFIX}-worker"
    ;;
  cron)
    LOG_GROUP="/ecs/shark-${ENV_PREFIX}-cron"
    ;;
  notification)
    LOG_GROUP="/ecs/shark-${ENV_PREFIX}-notification"
    ;;
  *)
    echo "Usage: $0 [dev|prod] [web|worker|cron|notification] [duration]"
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

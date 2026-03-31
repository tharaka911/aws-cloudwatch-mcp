# ☁️ AWS Credentials & Profile Setup

Detailed instructions for setting up the necessary AWS credentials and profiles for this MCP server and its helper scripts.

---

## 1. Install AWS CLI
If you haven't already, install the AWS Command Line Interface:
- **macOS**: `brew install awscli`
- **Linux**: `sudo apt-get install awscli` (or equivalent)
- **Windows**: [Download MSI Installer](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

---

## 2. Configure a Named Profile (Recommended)
This repository's workflows and Docker configurations assume the existence of a named profile (default: `shark-dev-logs`).

### Using the Configuration Wizard
Run the following command and follow the prompts:

```bash
aws configure --profile shark-dev-logs
```

**You will be prompted for:**
- **AWS Access Key ID**: Your IAM user's access key.
- **AWS Secret Access Key**: Your IAM user's secret key.
- **Default region name**: `us-east-1` (typical for Sharkroll Dev).
- **Default output format**: `json`.

---

## 3. Manual Configuration (Alternative)
If you prefer to edit files directly, update your AWS configuration files in `~/.aws/` (Linux/macOS) or `%USERPROFILE%\.aws\` (Windows).

### `~/.aws/credentials`
Add your keys to this file:
```ini
[shark-dev-logs]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

### `~/.aws/config`
Add the regional settings to this file:
```ini
[profile shark-dev-logs]
region = us-east-1
output = json
```

---

## 4. Verify Your Profile
Check if the profile is recognized and working correctly:

```bash
# Verify identity
aws sts get-caller-identity --profile shark-dev-logs

# Verify log groups are accessible
aws logs describe-log-groups --log-group-name-prefix /ecs/shark-dev --profile shark-dev-logs
```

---

## 5. Integrating with MCP Server
Ensure your `mcp_config.json` correctly references this profile.

### Example Configuration:
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
> Double-check that the path to your `.aws` directory in the volume mount (`-v`) is correct for your local machine.

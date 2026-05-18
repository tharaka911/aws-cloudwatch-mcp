# ☁️ AWS Credentials & Profile Setup (Dev & Prod)

Detailed instructions for setting up the necessary AWS credentials and profiles for this MCP server and its helper scripts in both the **Development** and **Production** environments.

---

## 1. Install AWS CLI
If you haven't already, install the AWS Command Line Interface:
- **macOS**: `brew install awscli`
- **Linux**: `sudo apt-get install awscli` (or equivalent)
- **Windows**: [Download AWS CLI MSI Installer](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

---

## 2. Configure Named Profiles
The repository workflows, Docker run scripts, and CloudWatch MCP servers assume the existence of two separate named profiles:
1. `shark-dev-logs` (for the Development environment)
2. `shark-prod-logs` (for the Production environment)

### Using the Configuration Wizard
Run the following commands for each environment and follow the prompts:

#### 💻 Development Profile:
```bash
aws configure --profile shark-dev-logs
```
* **AWS Access Key ID**: Your Dev IAM user's access key.
* **AWS Secret Access Key**: Your Dev IAM user's secret key.
* **Default region name**: `us-east-1` (typical for Sharkroll Dev).
* **Default output format**: `json`.

#### 🚀 Production Profile:
```bash
aws configure --profile shark-prod-logs
```
* **AWS Access Key ID**: Your Prod IAM user's access key.
* **AWS Secret Access Key**: Your Prod IAM user's secret key.
* **Default region name**: `eu-west-1` (typical for Sharkroll Prod).
* **Default output format**: `json`.

---

## 3. Manual Configuration (Alternative)
If you prefer to edit files directly, update your AWS configuration files in `~/.aws/` (Linux/macOS) or `%USERPROFILE%\.aws\` (Windows).

### `~/.aws/credentials`
Add your credentials to this file:
```ini
[shark-dev-logs]
aws_access_key_id = YOUR_DEV_ACCESS_KEY_ID
aws_secret_access_key = YOUR_DEV_SECRET_ACCESS_KEY

[shark-prod-logs]
aws_access_key_id = YOUR_PROD_ACCESS_KEY_ID
aws_secret_access_key = YOUR_PROD_SECRET_ACCESS_KEY
```

### `~/.aws/config`
Add the regional configuration for each profile:
```ini
[profile shark-dev-logs]
region = us-east-1
output = json

[profile shark-prod-logs]
region = eu-west-1
output = json
```

---

## 4. Verify Your Profiles
Confirm that your CLI is authenticated and has permission to access the correct CloudWatch Log Groups.

### 💻 Development Verification:
```bash
# Verify identity
aws sts get-caller-identity --profile shark-dev-logs

# Verify log groups are accessible (us-east-1)
aws logs describe-log-groups --log-group-name-prefix /ecs/shark-dev --profile shark-dev-logs
```

### 🚀 Production Verification:
```bash
# Verify identity
aws sts get-caller-identity --profile shark-prod-logs

# Verify log groups are accessible (eu-west-1)
aws logs describe-log-groups --log-group-name-prefix /ecs/shark-prod --profile shark-prod-logs
```

---

## 5. Integrating with MCP Server Configuration
Ensure your Claude Desktop/MCP configuration file (`mcp_config.json` or `claude_desktop_config.json`) defines both servers so you can seamlessly toggle between Dev and Prod logs.

### Dual Configuration Example:
```json
{
  "mcpServers": {
    "cloudwatch-shark-dev": {
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
    },
    "cloudwatch-shark-prod": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-v", "/Users/YOUR_USER/.aws:/root/.aws:ro",
        "-e", "AWS_PROFILE=shark-prod-logs",
        "-e", "AWS_REGION=eu-west-1",
        "-e", "AWS_SDK_LOAD_CONFIG=1",
        "-e", "AWS_CONFIG_FILE=/root/.aws/config",
        "-e", "AWS_SHARED_CREDENTIALS_FILE=/root/.aws/credentials",
        "custom/cloudwatch-mcp-server"
      ]
    }
  }
}
```

> [!IMPORTANT]
> - Ensure the local volume path `/Users/YOUR_USER/.aws` points to the correct location on your host system.
> - Verify that `AWS_REGION` is explicitly set to `us-east-1` for Dev and `eu-west-1` for Prod to prevent cross-region routing errors.


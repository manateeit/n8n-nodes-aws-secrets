# n8n-nodes-aws-secrets

AWS Secrets Manager node for n8n - retrieve secrets dynamically in your workflows.

## Features

- Retrieve secrets from AWS Secrets Manager
- Automatic JSON parsing for structured secrets
- Pass secrets dynamically to other nodes (SFTP, databases, APIs, etc.)
- Use AWS IAM credentials for secure access

## Installation

### Method 1: Community Node Installation (Recommended)

1. **SSH into your n8n EC2 instance:**
   ```bash
   ssh -i your-key.pem ec2-user@10.0.1.143
   ```

2. **Copy the package to the EC2 instance:**
   From your local machine:
   ```bash
   cd /Users/chrismckenna/development/archtopPOC
   tar -czf n8n-nodes-aws-secrets.tar.gz n8n-nodes-aws-secrets/
   scp -i your-key.pem n8n-nodes-aws-secrets.tar.gz ec2-user@10.0.1.143:/tmp/
   ```

3. **Install on the EC2 instance:**
   ```bash
   # SSH to EC2
   ssh -i your-key.pem ec2-user@10.0.1.143

   # Extract and install
   cd /opt/n8n
   mkdir -p custom-nodes
   cd custom-nodes
   tar -xzf /tmp/n8n-nodes-aws-secrets.tar.gz
   cd n8n-nodes-aws-secrets

   # Install in n8n container
   docker exec -it n8n-n8n-1 sh -c "cd /tmp && npm install -g /home/node/.n8n/custom-nodes/n8n-nodes-aws-secrets"

   # Restart n8n
   cd /opt/n8n
   docker-compose restart n8n
   ```

4. **Access n8n:**
   - URL: https://10.0.1.143
   - Username: admin
   - Password: testpassword123

### Method 2: Volume Mount (Alternative)

1. **Copy package to EC2:**
   ```bash
   scp -i your-key.pem -r n8n-nodes-aws-secrets ec2-user@10.0.1.143:/opt/n8n/custom-nodes/
   ```

2. **Update docker-compose.yml:**
   Add volume mount:
   ```yaml
   n8n:
     volumes:
       - n8n-data:/home/node/.n8n
       - /opt/n8n/custom-nodes:/opt/custom-nodes
   ```

3. **Restart:**
   ```bash
   docker-compose down && docker-compose up -d
   ```

## Usage

### 1. Create AWS Credentials

In n8n:
1. Go to **Credentials** > **New**
2. Select **AWS Secrets Manager API**
3. Fill in:
   - **Region:** us-east-1 (or your AWS region)
   - **Access Key ID:** Your AWS access key
   - **Secret Access Key:** Your AWS secret key
4. Click **Save**

### 2. Add AWS Secrets Manager Node

1. Create a new workflow
2. Add the **AWS Secrets Manager** node
3. Select your credentials
4. Configure:
   - **Secret Name:** e.g., `datalake/sftp/credentials`
   - **Parse JSON:** Enable if secret is JSON format

### 3. Use Secret Values in Other Nodes

The node outputs all secret fields as top-level JSON properties. Access them using expressions:

**Example - SFTP Node:**
```
Host: {{ $json.host }}
Port: {{ $json.port }}
Username: {{ $json.username }}
Password: {{ $json.password }}
```

**Example Secret Structure in AWS:**
```json
{
  "host": "sftp.example.com",
  "port": 22,
  "username": "dataloader",
  "password": "secure_password_123"
}
```

### 4. Complete Workflow Example: SFTP → S3

```
[AWS Secrets] → [SFTP Download] → [S3 Upload]
```

1. **AWS Secrets Manager Node:**
   - Secret Name: `datalake/sftp/credentials`
   - Parse JSON: ✓

2. **SFTP Node:**
   - Operation: Download
   - Path: `/data/*.csv`
   - Host: `{{ $json.host }}`
   - Port: `{{ $json.port }}`
   - Username: `{{ $json.username }}`
   - Password: `{{ $json.password }}`

3. **AWS S3 Node:**
   - Operation: Upload
   - Bucket: `datalake-raw-data`
   - File: Use binary data from SFTP

## Node Output

The node outputs a JSON object with:

- `secretName`: The name of the secret retrieved
- `secretValue`: The raw secret value (if not JSON)
- `versionId`: AWS version ID of the secret
- `createdDate`: When the secret was created
- Plus all parsed JSON fields at the top level

**Example Output:**
```json
{
  "secretName": "datalake/sftp/credentials",
  "versionId": "abc123-def456",
  "createdDate": "2025-01-15T12:00:00Z",
  "host": "sftp.example.com",
  "port": 22,
  "username": "dataloader",
  "password": "secure_password_123"
}
```

## Development

### Build from Source

```bash
cd n8n-nodes-aws-secrets
npm install
npm run build
```

### Package Structure

```
n8n-nodes-aws-secrets/
├── credentials/
│   └── AwsSecretsApi.credentials.ts
├── nodes/
│   └── AwsSecrets/
│       ├── AwsSecrets.node.ts
│       └── awsSecrets.svg
├── dist/               # Compiled output
├── package.json
├── tsconfig.json
└── gulpfile.js
```

## Troubleshooting

### Node Not Appearing in n8n

1. Check if the package was installed:
   ```bash
   docker exec -it n8n-n8n-1 npm list -g | grep aws-secrets
   ```

2. Check n8n logs:
   ```bash
   docker logs n8n-n8n-1
   ```

3. Restart n8n:
   ```bash
   docker-compose restart n8n
   ```

### AWS Credentials Issues

- Ensure IAM user has `secretsmanager:GetSecretValue` permission
- Verify region is correct
- Test credentials with AWS CLI:
  ```bash
  aws secretsmanager get-secret-value --secret-id your-secret-name --region us-east-1
  ```

### Cannot Access Secrets

- Check secret name is exact (case-sensitive)
- Verify secret exists in the specified region
- Review IAM permissions

## License

MIT

## Author

Archtop

# Quick Start Guide

Get the AWS Secrets Manager node running in n8n in under 5 minutes.

## Step 1: Push to GitHub (First Time Only)

```bash
# 1. Create a new repository on GitHub:
#    - Go to https://github.com/new
#    - Name: n8n-nodes-aws-secrets
#    - Visibility: Public or Private

# 2. Push this code to GitHub:
cd /Users/chrismckenna/development/archtopPOC/n8n-nodes-aws-secrets

# Update the remote URL with your GitHub username/org (if not already correct)
git remote add origin https://github.com/archtop/n8n-nodes-aws-secrets.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 2: Install in n8n (Easiest Method)

### For Docker n8n (Your Setup):

```bash
# Set your SSH key path
export SSH_KEY=/path/to/your-key.pem

# Run the installation script
./install-from-github.sh
```

**Or manually:**
```bash
ssh -i your-key.pem ec2-user@10.0.1.143

# Install from GitHub
docker exec -it n8n-n8n-1 npm install -g github:archtop/n8n-nodes-aws-secrets

# Restart n8n
cd /opt/n8n
docker-compose restart n8n
```

## Step 3: Configure in n8n

1. Access https://10.0.1.143
2. Login: admin / testpassword123
3. Go to **Credentials** → **New**
4. Search for **AWS Secrets Manager API**
5. Add your AWS credentials:
   - Region: us-east-1
   - Access Key ID: (your AWS key)
   - Secret Access Key: (your AWS secret)

## Step 4: Create Your First Workflow

### Example: SFTP to S3 with Dynamic Credentials

**Create a secret in AWS Secrets Manager first:**
```bash
aws secretsmanager create-secret \
  --name datalake/sftp/credentials \
  --secret-string '{
    "host": "sftp.example.com",
    "port": 22,
    "username": "dataloader",
    "password": "your-password"
  }' \
  --region us-east-1
```

**In n8n:**

1. Add **AWS Secrets Manager** node
   - Secret Name: `datalake/sftp/credentials`
   - Parse JSON: ✓

2. Add **SFTP** node (connect to AWS Secrets output)
   - Operation: Download Files
   - Path: `/data/*.csv`
   - Host: `{{ $json.host }}`
   - Port: `{{ $json.port }}`
   - Username: `{{ $json.username }}`
   - Password: `{{ $json.password }}`

3. Add **AWS S3** node
   - Operation: Upload
   - Bucket Name: your-bucket
   - Use binary data from SFTP

4. Click **Execute Workflow**

## Updating the Node

When you make changes:

```bash
# Make changes to TypeScript files
# Build and commit
npm run build
git add -A
git commit -m "Update: your changes"
git push

# Reinstall in n8n
ssh -i your-key.pem ec2-user@10.0.1.143
docker exec -it n8n-n8n-1 npm uninstall -g n8n-nodes-aws-secrets
docker exec -it n8n-n8n-1 npm install -g github:archtop/n8n-nodes-aws-secrets
cd /opt/n8n && docker-compose restart n8n
```

## Troubleshooting

**Node not showing up?**
```bash
# Check installation
docker exec -it n8n-n8n-1 npm list -g | grep aws-secrets

# Check logs
docker logs n8n-n8n-1

# Force restart
docker-compose restart n8n
```

**Still not working?**
See detailed troubleshooting in `GITHUB_SETUP.md`

## Advanced Installation Methods

See `GITHUB_SETUP.md` for:
- Installing via n8n Community Nodes UI
- Using environment variables for auto-installation
- Publishing to npm registry
- Installing from private GitHub repos

## Files Reference

- `README.md` - Complete documentation
- `GITHUB_SETUP.md` - Detailed GitHub setup and installation options
- `QUICKSTART.md` - This file
- `install-from-github.sh` - Automated installation script
- `install-on-ec2.sh` - Legacy manual installation (not needed if using GitHub)

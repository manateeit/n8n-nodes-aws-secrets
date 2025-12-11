# GitHub Setup & Installation Guide

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository:
   - **Name:** `n8n-nodes-aws-secrets`
   - **Description:** AWS Secrets Manager node for n8n
   - **Visibility:** Public (for community nodes) or Private
   - **Don't** initialize with README (we already have one)

3. Copy the repository URL (e.g., `https://github.com/archtop/n8n-nodes-aws-secrets.git`)

## Step 2: Push to GitHub

```bash
cd /Users/chrismckenna/development/archtopPOC/n8n-nodes-aws-secrets

# Update remote URL if needed (replace with your actual GitHub username/org)
git remote add origin https://github.com/archtop/n8n-nodes-aws-secrets.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Install in n8n Docker Container

Once pushed to GitHub, you have **three installation options**:

### Option A: Install via n8n Community Nodes UI (Easiest)

1. Access n8n at https://10.0.1.143
2. Go to **Settings** → **Community Nodes**
3. Click **Install a Community Node**
4. Enter: `archtop/n8n-nodes-aws-secrets`
5. Click **Install**

**Note:** This only works if the repository is public on GitHub.

### Option B: Install via Docker Exec (Works for Private Repos)

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@10.0.1.143

# Install the node in the n8n container
docker exec -it n8n-n8n-1 sh -c "npm install -g github:archtop/n8n-nodes-aws-secrets"

# Restart n8n
cd /opt/n8n
docker-compose restart n8n
```

**For private repos, use GitHub personal access token:**
```bash
docker exec -it n8n-n8n-1 sh -c "npm install -g https://YOUR_GITHUB_TOKEN@github.com/archtop/n8n-nodes-aws-secrets.git"
```

### Option C: Install via docker-compose Environment Variable (Best for Production)

Update `/opt/n8n/docker-compose.yml`:

```yaml
n8n:
  image: n8nio/n8n:next
  environment:
    # ... existing environment variables ...
    N8N_CUSTOM_EXTENSIONS: "github:archtop/n8n-nodes-aws-secrets"
  # ... rest of config ...
```

Then restart:
```bash
docker-compose down && docker-compose up -d
```

## Step 4: Verify Installation

1. Access n8n at https://10.0.1.143
2. Create a new workflow
3. Click the **+** button to add a node
4. Search for **"AWS Secrets"**
5. You should see **"AWS Secrets Manager"** in the results

## Step 5: Create AWS Credentials

1. Go to **Credentials** → **New**
2. Search for **"AWS Secrets Manager API"**
3. Fill in:
   - **Region:** us-east-1 (or your AWS region)
   - **Access Key ID:** Your AWS access key
   - **Secret Access Key:** Your AWS secret key
4. Click **Save**

## Troubleshooting

### Node not appearing after installation

```bash
# Check if package is installed
docker exec -it n8n-n8n-1 npm list -g | grep aws-secrets

# Check n8n logs
docker logs n8n-n8n-1

# Force restart
docker-compose restart n8n
```

### Installation fails in container

```bash
# Check container has internet access
docker exec -it n8n-n8n-1 ping -c 3 github.com

# Try manual installation
docker exec -it n8n-n8n-1 sh
cd /tmp
git clone https://github.com/archtop/n8n-nodes-aws-secrets.git
cd n8n-nodes-aws-secrets
npm install
npm run build
npm link
exit
```

### Updating the node

```bash
# Reinstall from GitHub
docker exec -it n8n-n8n-1 sh -c "npm uninstall -g n8n-nodes-aws-secrets && npm install -g github:archtop/n8n-nodes-aws-secrets"

# Restart n8n
docker-compose restart n8n
```

## Publishing to npm Registry (Optional)

If you want to publish to npm for easier installation:

```bash
# Login to npm
npm login

# Publish
npm publish

# Then install in n8n with just:
docker exec -it n8n-n8n-1 npm install -g n8n-nodes-aws-secrets
```

## Example Workflow

**SFTP Download → S3 Upload using dynamic credentials:**

1. **AWS Secrets Manager** node
   - Secret Name: `datalake/sftp/credentials`
   - Parse JSON: ✓

2. **SFTP** node
   - Host: `{{ $json.host }}`
   - Port: `{{ $json.port }}`
   - Username: `{{ $json.username }}`
   - Password: `{{ $json.password }}`

3. **AWS S3** node
   - Upload files from SFTP

## Continuous Updates

When you make changes to the node:

```bash
# Make changes to TypeScript files
# Build and commit
npm run build
git add -A
git commit -m "Update: describe your changes"
git push

# Reinstall in n8n
docker exec -it n8n-n8n-1 sh -c "npm uninstall -g n8n-nodes-aws-secrets && npm install -g github:archtop/n8n-nodes-aws-secrets"
docker-compose restart n8n
```

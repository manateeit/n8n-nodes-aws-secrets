#!/bin/bash
# Quick installation script for n8n AWS Secrets Manager node from GitHub
# Run this after pushing the package to GitHub

set -e

EC2_IP="${EC2_IP:-10.0.1.143}"
EC2_USER="${EC2_USER:-ec2-user}"
SSH_KEY="${SSH_KEY:-~/.ssh/your-key.pem}"
GITHUB_REPO="${GITHUB_REPO:-manateeit/n8n-nodes-aws-secrets}"

echo "🚀 Installing n8n AWS Secrets Manager Node from GitHub"
echo "========================================================"
echo ""
echo "GitHub Repo: $GITHUB_REPO"
echo "EC2 Instance: $EC2_IP"
echo "SSH Key: $SSH_KEY"
echo ""

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Error: SSH key not found at $SSH_KEY"
    echo "Set SSH_KEY environment variable:"
    echo "  export SSH_KEY=/path/to/your-key.pem"
    exit 1
fi

echo "📦 Installing node in n8n container..."

# Install from GitHub in the Docker container
ssh -i "$SSH_KEY" ${EC2_USER}@${EC2_IP} << ENDSSH
set -e

echo "  Installing from GitHub: $GITHUB_REPO"
docker exec -it n8n-n8n-1 sh -c "npm install -g github:$GITHUB_REPO"

echo "  Restarting n8n..."
cd /opt/n8n
docker-compose restart n8n

echo "✅ Installation complete!"
ENDSSH

echo ""
echo "=========================================="
echo "✨ Node Installed Successfully!"
echo "=========================================="
echo ""
echo "Access n8n at: https://$EC2_IP"
echo "Username: admin"
echo "Password: testpassword123"
echo ""
echo "Wait 30-60 seconds for n8n to restart, then:"
echo "1. Go to Credentials > New > AWS Secrets Manager API"
echo "2. Create a new workflow and search for 'AWS Secrets'"
echo ""

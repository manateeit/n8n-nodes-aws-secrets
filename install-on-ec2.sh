#!/bin/bash
# Installation script for n8n AWS Secrets Manager custom node
# Run this from your local machine

set -e

EC2_IP="10.0.1.143"
EC2_USER="ec2-user"
SSH_KEY="${SSH_KEY:-~/.ssh/your-key.pem}"  # Set SSH_KEY env var or update this path

echo "🔧 Installing n8n AWS Secrets Manager Custom Node"
echo "=================================================="
echo ""
echo "EC2 Instance: $EC2_IP"
echo "SSH Key: $SSH_KEY"
echo ""

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Error: SSH key not found at $SSH_KEY"
    echo "Set SSH_KEY environment variable or update the script:"
    echo "  export SSH_KEY=/path/to/your-key.pem"
    exit 1
fi

# Step 1: Build package locally
echo "📦 Step 1: Building package..."
npm run build
echo "✅ Build complete"
echo ""

# Step 2: Create tarball
echo "📦 Step 2: Creating package tarball..."
cd ..
tar -czf n8n-nodes-aws-secrets.tar.gz n8n-nodes-aws-secrets/ \
    --exclude='node_modules' \
    --exclude='.git'
echo "✅ Tarball created"
echo ""

# Step 3: Copy to EC2
echo "📤 Step 3: Copying package to EC2..."
scp -i "$SSH_KEY" n8n-nodes-aws-secrets.tar.gz ${EC2_USER}@${EC2_IP}:/tmp/
echo "✅ Package copied"
echo ""

# Step 4: Install on EC2
echo "🔧 Step 4: Installing on n8n..."
ssh -i "$SSH_KEY" ${EC2_USER}@${EC2_IP} << 'ENDSSH'
set -e

cd /opt/n8n
mkdir -p custom-nodes
cd custom-nodes

# Extract package
echo "  Extracting package..."
tar -xzf /tmp/n8n-nodes-aws-secrets.tar.gz

# Install dependencies in the package
echo "  Installing package dependencies..."
cd n8n-nodes-aws-secrets
npm install --production

# Copy package into n8n container's node_modules
echo "  Installing in n8n container..."
docker cp /opt/n8n/custom-nodes/n8n-nodes-aws-secrets n8n-n8n-1:/opt/custom-nodes/

# Install globally in container
docker exec n8n-n8n-1 sh -c "cd /opt/custom-nodes/n8n-nodes-aws-secrets && npm link"

echo "✅ Installation complete"
ENDSSH

# Step 5: Restart n8n
echo "🔄 Step 5: Restarting n8n..."
ssh -i "$SSH_KEY" ${EC2_USER}@${EC2_IP} "cd /opt/n8n && docker-compose restart n8n"
echo "✅ n8n restarted"
echo ""

# Cleanup
echo "🧹 Cleaning up..."
rm n8n-nodes-aws-secrets.tar.gz
echo "✅ Cleanup complete"
echo ""

echo "=========================================="
echo "✨ Installation Complete!"
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

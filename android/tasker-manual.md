# Manual VM Control Procedures

Alternative to Tasker automation - manual procedures for controlling your Portable Claude Code VM from Android.

## When to Use Manual Control

- You prefer direct control
- Automation isn't working
- You want to understand what's happening
- Debugging issues
- Quick one-off operations

## Option 1: Via Termux (Recommended)

### Start VM

```bash
# In Termux
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-start
```

### Check VM Status

```bash
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-status
```

### Stop VM

```bash
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-stop
```

## Option 2: Via GCP Console (Browser)

### Start VM

1. Open Chrome/Firefox on Android
2. Go to: https://console.cloud.google.com
3. Navigate: Compute Engine → VM instances
4. Select your VM
5. Click "Start"
6. Wait for "RUNNING" status

### Stop VM

1. Open GCP Console
2. Navigate to VM instances
3. Select your VM
4. Click "Stop"
5. Confirm

## Option 3: Via gcloud CLI in Termux

### Install gcloud CLI

```bash
# In Termux
pkg install python
pip install google-cloud-sdk

# Or install gcloud alpha component
pip install google-cloud-sdk

# Initialize
gcloud init
```

### Start VM

```bash
gcloud compute instances start portable-cc-dev \
  --zone=us-central1-a \
  --project=your-project-id
```

### Stop VM

```bash
gcloud compute instances stop portable-cc-dev \
  --zone=us-central1-a \
  --project=your-project-id
```

### Check Status

```bash
gcloud compute instances describe portable-cc-dev \
  --zone=us-central1-a \
  --project=your-project-id \
  --format="value(status)"
```

## Option 4: Via REST API (curl in Termux)

### Get Access Token

```bash
# Requires OAuth setup or service account key
# See: ../ios-shortcuts/README.md
```

### Start VM

```bash
curl -X POST \
  "https://compute.googleapis.com/compute/v1/projects/your-project/zones/us-central1-a/instances/portable-cc-dev/start" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Stop VM

```bash
curl -X POST \
  "https://compute.googleapis.com/compute/v1/projects/your-project/zones/us-central1-a/instances/portable-cc-dev/stop" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Check Status

```bash
curl \
  "https://compute.googleapis.com/compute/v1/projects/your-project/zones/us-central1-a/instances/portable-cc-dev" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  | jq ".status"
```

## Quick Reference Commands

### Termux Aliases

Add these to `~/.bashrc` in Termux:

```bash
# VM Control
alias cc-start='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-start'
alias cc-stop='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-stop'
alias cc-status='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-status'

# Connect
alias cc-vm='mosh ubuntu@portable-cc-dev'
alias cc-tmux='mosh ubuntu@portable-cc-dev tmux attach'
```

### Quick Status Check

```bash
# One-liner to check everything
cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-status
```

## Manual Workflow Example

### Morning Routine

1. **Check status**: `cc-status`
2. **If stopped**: `cc-start`
3. **Wait** 30-60 seconds
4. **Connect**: `cc-tmux`
5. **Start Claude**: `claude-code`

### Evening Shutdown

1. **Detach from tmux**: Ctrl+B, D
2. **Stop VM**: `cc-stop`
3. **Confirm**: `cc-status`

### Quick Check During Day

1. **Check**: `cc-status`
2. **If running**: `cc-tmux` to attach
3. **If stopped**: `cc-start` then wait

## Troubleshooting

### vm-start Fails

**Error**: "gcloud: command not found"

**Solution**: Use Cloud Function REST API instead:
```bash
curl -X POST %CLOUD_FUNCTION_URL \
  -H "X-API-Key: %API_KEY"
```

**Error**: "Permission denied"

**Solution**: Make script executable:
```bash
chmod +x ~/portable-cc-with-voice/vm-lifecycle/*
```

**Error**: "VM not found"

**Solution**: Check environment variables:
```bash
echo $GCP_PROJECT_ID
echo $GCP_INSTANCE_NAME
```

### Connection Fails

**Error**: "Connection refused"

**Solution**:
1. VM is still starting: wait 1-2 minutes
2. Tailscale not connected: Open Tailscale app
3. Wrong IP: Check Tailscale app for current IP

**Error**: "Host key verification failed"

**Solution**:
```bash
# Remove old host key
ssh-keygen -R portable-cc-dev

# Or edit known_hosts
nano ~/.ssh/known_hosts
# Delete the line for your VM
```

### Tailscale Issues

**VPN won't connect**

1. Open Tailscale app
2. Tap "Switch off"
3. Wait 5 seconds
4. Tap "Switch on"
5. If still fails, restart phone

**Can't find VM in Tailscale**

1. VM might be stopped
2. Start VM first (GCP Console)
3. Wait for Tailscale to connect

## Cost Awareness

### Manual Cost Control

Since you're starting manually, remember to stop!

**Set a reminder**: Use Android alarm or calendar

**Check usage**:
```bash
# In Termux
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-status
```

**Daily cost**: ~$0.05/hour × hours used

## Automation Alternatives

If manual control feels tedious, consider:

1. **Tasker automation**: See [tasker-profiles.md](tasker-profiles.md)
2. **iOS Shortcuts** (if you also have iPhone)
3. **Scheduled tasks**: cron jobs on VM to auto-stop

### Simple Auto-Stop (on VM)

Add to VM's crontab:

```bash
# On the VM
crontab -e

# Auto-stop after 12 hours
0 */12 * * * /sbin/shutdown -h now

# Or auto-stop at specific time
0 22 * * * /sbin/shutdown -h now
```

## Next Steps

1. Set up Termux aliases for quick commands
2. Practice manual procedures
3. Consider Tasker for convenience: [tasker-profiles.md](tasker-profiles.md)
4. Learn workflows: [workflows-guide.md](workflows-guide.md)

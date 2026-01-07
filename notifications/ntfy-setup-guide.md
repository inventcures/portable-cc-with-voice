# Push Notification Setup Guide

This guide shows you how to set up push notifications for Claude Code, so you get alerted on your iPhone when Claude needs your input.

## Overview

The system uses **ntfy.sh** for push notifications:
- Claude Code calls the hook when it needs input
- Hook sends HTTP POST to ntfy.sh
- ntfy.sh sends push notification to your iPhone

## Option 1: ntfy.sh Cloud (Easiest)

### Step 1: Choose a Topic Name

Pick a unique, hard-to-guess topic name:

```bash
# Generate a random topic name
export NTFY_TOPIC="portable-cc-$(uuidgen | tr -d '-' | head -c 12)"
```

Or use your own memorable name:
```bash
export NTFY_TOPIC="your-name-portable-cc"
```

### Step 2: Install the Hook

```bash
# On the VM
mkdir -p ~/.claude/hooks
cp ~/portable-cc-with-voice/notifications/notify.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/notify.sh
```

### Step 3: Configure the Hook

```bash
# Add to your ~/.zshrc
echo "export NTFY_TOPIC='your-topic-name'" >> ~/.zshrc
source ~/.zshrc
```

### Step 4: Update Claude Code Settings

```bash
# Copy settings to Claude config directory
cp ~/portable-cc-with-voice/notifications/settings.json ~/.claude/
```

### Step 5: Install ntfy iOS App

1. Open App Store
2. Search for "ntfy"
3. Install the app
4. Open the app
5. Subscribe to your topic: `your-topic-name`

### Step 6: Test

```bash
# Test notification
curl -X POST "https://ntfy.sh/your-topic-name" \
  -H "Title: Test" \
  -d "If you see this, notifications work!"
```

You should receive a notification on your iPhone!

## Option 2: Self-Hosted ntfy (More Privacy)

### Why Self-Host?

- Full privacy - messages don't go through public server
- No rate limits
- Works without internet (if on same network)

### Quick Start (Docker)

```bash
# On a server (could be your VM)
docker run -p 8080:80 \
  -v /var/lib/ntfy:/var/lib/ntfy \
  binwiederhier/ntfy \
  serve \
  --cache-file /var/lib/ntfy/cache.db
```

### Then Configure

```bash
# On the VM
export NTFY_SERVER="http://your-server-ip:8080"
export NTFY_TOPIC="your-private-topic"
```

### With Authentication (Recommended)

```bash
# Generate a token
export NTFY_TOKEN=$(openssl rand -hex 16)

# Start ntfy with auth
docker run -p 8080:80 \
  -v /var/lib/ntfy:/var/lib/ntfy \
  -e NTFY_AUTH_FILE=/var/lib/ntfy/auth.db \
  binwiederhier/ntfy \
  serve \
  --cache-file /var/lib/ntfy/cache.db \
  --auth-db=/var/lib/ntfy/auth.db \
  --auth-default-access=deny

# Add user
ntfy user add your-user --role=admin
ntfy token add your-user
```

Then add to your VM config:
```bash
echo "export NTFY_TOKEN='your-token-here'" >> ~/.zshrc
```

See [ntfy.sh docs](https://ntfy.sh/docs/) for more details.

## Configuration Options

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `NTFY_TOPIC` | Your unique topic name | `portable-cc-abc123` |
| `NTFY_SERVER` | ntfy server URL | `https://ntfy.sh` (default) |
| `NTFY_TOKEN` | Auth token for private topics | `tk_AbCdEf1234` |
| `NTFY_PRIORITY` | Notification priority | `high` (default) |

### Priorities

| Priority | Behavior |
|----------|----------|
| `min` | No notification, silent |
| `low` | No sound/vibration |
| `default` | Standard notification |
| `high` | High priority (default) |
| `urgent` | Urgent, bypasses DND |

## Troubleshooting

### Not receiving notifications?

1. Check topic name matches in VM and iOS app
2. Test with curl command above
3. Check ntfy app notifications are enabled in iOS Settings
4. Check iOS Focus modes aren't blocking notifications

### Hook not firing?

1. Check hook is executable: `ls -l ~/.claude/hooks/notify.sh`
2. Check Claude settings: `cat ~/.claude/settings.json`
3. Test manually:
   ```bash
   echo '{"tool_name":"AskUserQuestion","tool_input":{"questions":[{"question":"Test"}]}}' | ~/.claude/hooks/notify.sh
   ```

### Rate limiting?

The free ntfy.sh tier has rate limits. For heavy use:
- Self-host ntfy.sh
- Or get a paid tier at https://ntfy.sh

## Privacy Considerations

- **Free ntfy.sh**: Messages go through public server, topic name is your only privacy
- **Self-hosted**: Full privacy, only you can see messages
- **With authentication**: Even if someone guesses your topic, they need the token

## Alternatives

If you prefer another service, the hook can be adapted for:

- **Pushover**: Simple API, paid
- **Gotify**: Self-hosted, requires more setup
- **Pushbullet**: Discontinued, don't use
- **Apprise**: Multi-service aggregator

See the hook script - just change the `curl` command!

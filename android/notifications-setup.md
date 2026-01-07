# ntfy Android App Setup Guide

ntfy for Android provides push notifications for Claude Code questions. This guide covers Android-specific setup and features.

## What is ntfy?

ntfy is a push notification service that:
- Sends notifications via HTTP POST
- Has Android and iOS apps
- Offers free cloud tier
- Can be self-hosted
- Simple API

## Android App Features

Compared to iOS, ntfy Android has:

| Feature | Android | iOS |
|---------|---------|-----|
| Background handling | ✅ Better | ⚠️ Aggressive killing |
| Custom sounds | ✅ Per-topic | ✅ Per-topic |
| Widgets | ✅ Yes | ✅ Yes |
| No restrictions | ✅ True | ⚠️ iOS limitations |
| Multiple topics | ✅ Unlimited | ✅ Unlimited |
| Doze mode | ⚠️ May affect | ⚠️ May affect |

## Installation

```bash
# Play Store
# https://play.google.com/store/apps/details=com.ntfy.app
```

Or from GitHub:
```bash
# https://github.com/binwiederhomer/ntfy-android/releases
```

## Setup

### Step 1: Create/Open ntfy Account

1. Open ntfy app
2. Sign in or create account (optional, for premium)
3. Free tier works without account!

### Step 2: Subscribe to Your Topic

1. Tap + to add subscription
2. Enter topic name: `your-ntfy-topic`
3. Tap Subscribe

**Security**: Use a hard-to-guess topic name since the free tier has no authentication.

### Step 3: Configure Subscription

1. Tap and hold your subscription
2. Select "Settings"
3. Configure:
   - **Display name**: "Claude Code" or similar
   - **Icon**: Choose an icon
   - **Notification sound**: Choose a distinct sound
   - **Vibration**: Enable
   - **LED**: Enable (if device supports)

### Step 4: Test Notification

```bash
# From Termux or VM
curl -X POST https://ntfy.sh/your-topic \
  -H "Title: Test" \
  -H "Priority: high" \
  -d "If you see this, notifications work!"
```

## Claude Code Hook Setup

### Hook Script Configuration

The hook script from the main project works on Android:

```bash
# On the VM, the hook is already configured
# ~/portable-cc-with-voice/notifications/notify.sh
```

### Environment Variables

```bash
# Set in ~/.bashrc or ~/.zshrc
export NTFY_TOPIC="your-secret-topic"
export NTFY_SERVER="https://ntfy.sh"
```

### Testing the Hook

```bash
# On the VM, test the hook
echo '{"tool_name":"AskUserQuestion","tool_input":{"questions":[{"question":"Test question"}]}}' | ~/.claude/hooks/notify.sh
```

## Android-Specific Features

### Background Notifications

Android handles background notifications better than iOS:

- **Doze mode**: May delay non-priority notifications
- **Battery optimization**: Add ntfy to whitelist
- **Background restrictions**: Android 8+ may limit

**Enable background notifications:**

1. Settings → Apps & notifications → ntfy
2. Battery → Unrestricted
3. Notifications → Allow all

### Widgets

Add ntfy widget to home screen:

1. Long press home screen
2. Widgets → ntfy
3. Choose widget size
4. Configure to show your topic

**Widget features**:
- Show latest notification
- Tap to open app
- Quick subscribe button
- Refresh button

### Custom Notification Sounds

Set different sounds for different projects:

1. ntfy app → Tap & hold subscription
2. Settings → Notification sound
3. Choose built-in or custom sound

**Example**:
- Main project: "Ding"
- Side project: "Chime"
- Work project: "Bell"

## Notification Priorities

ntfy supports priorities:

| Priority | Android Behavior |
|----------|-------------------|
| `min` | Silent, no vibration |
| `low` | Silent (maybe vibration) |
| `default` | Default sound/vibration |
| `high` | Priority sound/vibration |
| `urgent` | Alert sound, heads-up |

Configure in `notify.sh`:

```bash
NTFY_PRIORITY="high"  # For urgent Claude questions
NTFY_PRIORITY="default"  # For regular updates
```

## Advanced: Authentication

For private topics, ntfy supports authentication:

### Access Tokens

1. Generate token in ntfy app
2. Use in curl:

```bash
curl -X POST https://ntfy.sh/your-topic \
  -H "Authorization:Bearer your-token" \
  -d "Authenticated message"
```

### Username/Password

1. Set credentials in ntfy app
2. Use in curl:

```bash
curl -X POST https://user:pass@ntfy.sh/your-topic \
  -d "Authenticated message"
```

**Note**: For Claude Code, authentication is recommended for production use.

## Troubleshooting

### Notifications Not Arriving

1. **Check topic name**: Must match exactly
2. **Check internet**: ntfy requires connection
3. **Check app permissions**:
   - Settings → Apps → ntfy → Notifications
   - Ensure notifications are enabled
4. **Check Do Not Disturb**: May suppress notifications
5. **Check battery optimization**:
   - Settings → Apps → ntfy → Battery
   - Set to "Unrestricted"

### Notifications Delayed

Android may delay notifications for battery:

1. Add ntfy to battery optimization whitelist
2. Use higher priority (high or urgent)
3. Check for Doze mode restrictions

### Can't Subscribe

**"Topic not found"**: Normal for new topics on free tier

**"Failed to subscribe"**: Check internet connection

## Integration with Tasker

Tasker can react to ntfy notifications:

1. Install ntfy app
2. In Tasker, create Profile → Event → Plugin → ntfy
3. Trigger on notification received
4. Action: Flash, Notify, Run Task, etc.

**Example**: Vibrate when Claude asks a question

## Alternative: Self-Hosted ntfy

For privacy or reliability, self-host ntfy:

### Docker on VM

```bash
# On your VM
docker run -d \
  --name ntfy \
  -p 8080:80 \
  -v /var/lib/ntfy:/var/lib/ntfy \
  binwiederhier/ntfy \
  serve \
  --cache-file /var/lib/ntfy/cache.db
```

### Android Configuration

1. In ntfy app
2. Add subscription
3. For server URL, use your VM's Tailscale IP:
   - `http://your-vm-tailscale-ip:8080`
4. Subscribe!

**Advantages**:
- No internet needed
- Free (you pay for VM)
- Private

## Comparison: iOS vs Android

| Aspect | iOS | Android |
|--------|-----|---------|
| Notification delivery | ⭐⭐⭐ (aggressive killing) | ⭐⭐⭐⭐⭐ (better) |
| Background refresh | ⚠️ Limited | ✅ Better |
| Custom sounds | ✅ Yes | ✅ Yes |
| Widgets | ✅ Yes | ✅ Yes |
| Doze mode | N/A | ⚠️ May affect |
| Self-hosting | ✅ Possible | ✅ Possible |

**Winner**: Android has better background handling!

## Quick Reference

### Test Notification

```bash
curl -X POST https://ntfy.sh/your-topic \
  -H "Title: Claude: MyProject" \
  -H "Priority: high" \
  -d "Claude needs input"
```

### From VM Hook

```bash
# Triggered by Claude when asking questions
~/.claude/hooks/notify.sh
```

### From Termux

```bash
# Send manual notification from phone
curl -X POST https://ntfy.sh/your-topic \
  -d "Manual test from Android"
```

## Next Steps

1. Install ntfy app
2. Subscribe to your topic
3. Test notification
4. Configure Claude hook on VM
5. Set up Tasker integration: [tasker-profiles.md](tasker-profiles.md)
6. Learn workflows: [workflows-guide.md](workflows-guide.md)

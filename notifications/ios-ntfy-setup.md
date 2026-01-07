# ntfy iOS App Setup

Quick guide to setting up the ntfy iOS app for push notifications.

## Installation

1. Open the App Store on your iPhone
2. Search for "ntfy"
3. Install the free app

   Direct link: https://apps.apple.com/app/ntfy-2022/id1625396347

## Initial Setup

### 1. Open the App

You'll see a welcome screen and an option to subscribe to topics.

### 2. Subscribe to Your Topic

Tap the + button or "Add Subscription":

- **Topic URL**: `your-topic-name@https://ntfy.sh`
  - For cloud: `my-topic@https://ntfy.sh`
  - For self-hosted: `my-topic@http://your-server.com`

- **Display Name**: Whatever you want (e.g., "Claude Code")

### 3. Enable Notifications

When prompted, allow notifications:
- **Allow**: Receive push notifications
- **Allow**: Preview notifications (shows message content)

### 4. Test

Send a test from your VM or any device:
```bash
curl -X POST "https://ntfy.sh/your-topic-name" \
  -H "Title: Test" \
  -d "If you see this, it works!"
```

## App Features

### Notification Settings

For each subscription, you can configure:

1. Tap on your subscription
2. Tap the gear icon ⚙️
3. Configure:
   - **Notifications**: Enable/disable
   - **Sound**: Choose notification sound
   - **Min Priority**: Only notify for urgent messages
   - **Icon**: Choose an icon

### Background Fetch

The app uses iOS background fetch:
- **Auto-disconnect**: Can be set to disconnect after inactivity
- **Keep-alive**: For self-hosted servers, keep connection alive

Recommended settings for portable CC:
- **Auto-disconnect**: 15 minutes (balances battery and responsiveness)
- **Keep-alive**: Enabled

### Watch App

ntfy also has an Apple Watch app:
- Receive notifications on your wrist
- Quick actions directly from watch

## Managing Topics

### Multiple Topics

You can subscribe to multiple topics:
- `portable-cc-main` - For main projects
- `portable-cc-work` - For work projects
- `portable-cc-personal` - For personal projects

Configure different notification sounds for each!

### Private Topics

For private (authenticated) topics:

1. When subscribing, tap "Advanced"
2. Enter your token in the "Authorization" field
3. Format: `Bearer tk_your-token-here`

## Notification Actions

### Quick Actions

From a notification, you can:
- **Tap**: Open the ntfy app and view message
- **Long press**: View options (mark read, delete)

### Dismissing

Notifications are cleared when:
- You tap on them
- You clear all notifications
- You mark as read in the app

## Troubleshooting

### Notifications Not Arriving

1. **Check iOS Settings**:
   - Settings > Notifications > ntfy
   - Allow Notifications: ON
   - Alerts: ON
   - Sounds: ON
   - Banner Style: Persistent

2. **Check Focus Modes**:
   - Settings > Focus
   - Make sure ntfy is allowed for your Focus mode

3. **Check Background App Refresh**:
   - Settings > General > Background App Refresh
   - ntfy: ON

4. **Check Subscription**:
   - In ntfy app, tap on subscription
   - Make sure "Notifications" is enabled

### Delayed Notifications

iOS may delay notifications for battery optimization:
- Add ntfy to iOS "Always Allow" for notifications
- Keep app in "Dock" for priority

### Connection Issues

For self-hosted servers:
- Make sure server is accessible from your network
- Check VPN settings (Tailscale should be on)
- Test topic: `curl https://your-server.com/your-topic`

## Battery Tips

The ntfy app is designed to be battery-efficient:

1. **Use 15-minute auto-disconnect**
2. **Disable unnecessary topics**
3. **Set appropriate priority filter** (ignore low/min priority)
4. **Keep app updated**

## Widget

Add the ntfy widget to your home screen:
1. Long press home screen
2. Tap "+"
3. Search "ntfy"
4. Choose widget size
5. See latest notifications at a glance!

## Advanced

### URL Schemes

ntfy supports URL schemes for automation:

```
ntfy://subscribe/your-topic@https://ntfy.sh
```

Use this in iOS Shortcuts for quick topic subscription!

### Siri Integration

Create a Siri Shortcut:
1. Open ntfy app
2. Tap on a topic
3. Tap "Add to Home Screen"
4. Use Siri to run: "Hey Siri, check Claude"

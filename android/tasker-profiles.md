# Tasker Profiles for Portable Claude Code

Tasker is a powerful automation app for Android. This guide provides pre-configured profiles for controlling your Portable Claude Code VM from your Android device.

## What is Tasker?

Tasker allows you to:
- Automate actions based on triggers (time, location, events)
- Make HTTP requests to APIs
- Control other apps
- Create custom dialogs and notifications

## Prerequisites

1. **Install Tasker**
   - Play Store: ~$3.99 one-time purchase
   - https://play.google.com/store/apps/details=net.dinglisch.android.taskerm

2. **GCP Cloud Function deployed**
   - See `../ios-shortcuts/gcp-cloud-function.py`
   - Provides simple API for VM control

3. **API Key**
   - From Cloud Function deployment
   - Or create your own

## Profile 1: Start VM

### Task Configuration

**Task: Start Dev VM**

| Setting | Value |
|---------|-------|
| **Trigger** | Manual (or add widget/shortcut) |
| **Action 1** | HTTP Request |
| **Server:Port** | `your-cloud-function-url` |
| **Path** | `/` (function handles method) |
| **Method** | POST |
| **Headers** | `X-API-Key: your-api-key` |
| **Action 2** | Wait |
| **Seconds** | 5 |
| **Action 3** | Flash |
| **Text** | "VM is starting!" |
| **Action 4** | Notify |
| **Title** | "Portable CC" |
| **Text** | "VM start command sent" |
| **Icon** | Select icon |

### Alternative: Using Termux

Instead of Cloud Function, use Termux:

**Task: Start VM (Termux)**

| Setting | Value |
|---------|-------|
| **Action 1** | Run Shell |
| **Command** | `/data/data/com.termux/files/home/portable-cc-with-voice/vm-lifecycle/vm-start` |
| **Use Root** | Off |
| **Action 2** | Flash |
| **Text** | "Starting VM..." |

## Profile 2: Stop VM

### Task Configuration

**Task: Stop Dev VM**

| Setting | Value |
|---------|-------|
| **Trigger** | Manual |
| **Action 1** | HTTP Request |
| **Server:Port** | `your-cloud-function-url` |
| **Method** | DELETE |
| **Headers** | `X-API-Key: your-api-key` |
| **Action 2** | Flash |
| **Text** | "VM stopped!" |
| **Action 3** | Notify |
| **Title** | "Portable CC" |
| **Text** | "VM has been stopped" |

## Profile 3: Check VM Status

### Task Configuration

**Task: VM Status**

| Setting | Value |
|---------|-------|
| **Trigger** | Manual |
| **Action 1** | HTTP Request |
| **Server:Port** | `your-cloud-function-url` |
| **Method** | GET |
| **Headers** | `X-API-Key: your-api-key` |
| **Output** | %http_response |
| **Action 2** | Variable Search Replace |
| **Variable** | %status |
| **Search** | `"status":"(.*?)"` |
| **Replace** | $1 |
| **Action 3** | Flash |
| **Text** | "VM Status: %status" |

## Profile 4: Auto-Start VM (WiFi Based)

### Task Configuration

**Task: Auto-Start VM at Work**

| Setting | Value |
|---------|-------|
| **Trigger** | State → Network → WiFi Connected |
| **SSID** | Your work WiFi SSID |
| **Action 1** | HTTP Request → Start VM (as above) |
| **Action 2** | Notify |
| **Text** | "Connected to work WiFi, VM starting..." |

## Profile 5: Quick Connect

### Task Configuration

**Task: Quick Connect to VM**

| Setting | Value |
|---------|-------|
| **Trigger** | Manual |
| **Action 1** | Run Shell |
| **Command** | `mosh ubuntu@portable-cc-dev tmux attach` |
| **Action 2** | Wait |
| **Seconds** | 2 |
| **Action 3** | Load App |
| **Package** | com.sonelli.juicessh (or com.termux) |

## Profile 6: Notification on Claude Question

**Task: Claude Notification Handler**

Uses Termux:API to run notify.sh locally:

| Setting | Value |
|---------|-------|
| **Trigger** | Event → AutoNotification → Intercept |
| **Title** | Contains "Claude:" |
| **Action 1** | Vibrate |
| **Pattern** | 3 short |
| **Action 2** | Notify Sound |

## Profile 7: Start VM + Open Termux

### Task Configuration

**Task: Dev Session Start**

| Setting | Value |
|---------|-------|
| **Trigger** | Manual |
| **Action 1** | HTTP Request → Start VM |
| **Action 2** | Wait 10 seconds |
| **Action 3** | Flash → "VM should be ready" |
| **Action 4** | Load App → Termux |
| **Action 5** | Run Shell → `tmux attach -t main` |

## Importable Tasker Data

You can import these profiles. See [tasker-import.xml](tasker-import.xml) for the full XML import file.

## Widgets

Create home screen widgets for quick access:

1. Long press home screen
2. Widget → Tasker
3. Select task (Start VM, Stop VM, etc.)
4. Customize widget appearance

## Scenes (Optional UI)

Create a simple scene for VM control:

**Scene: VM Control**

1. Create Scene → "VM Control"
2. Add buttons:
   - Start VM
   - Stop VM
   - Check Status
   - Connect
3. Link buttons to tasks
4. Add widget to home screen

## Variables

Set up Tasker variables for easy configuration:

| Variable | Value | Description |
|----------|-------|-------------|
| `%CC_CLOUD_FUNCTION` | Your function URL | Cloud Function URL |
| `%CC_API_KEY` | Your API key | Authentication |
| `%CC_VM_NAME` | portable-cc-dev | VM name |
| `%CC_TAILSCALE_IP` | Your Tailscale IP | For SSH |

Use variables in actions: `%CC_CLOUD_FUNCTION`

## Profiles for Specific Use Cases

### Morning Routine

**Task: Morning Dev Setup**

| Trigger | Time → 8:00 AM |
| Actions | 1. Check VM status<br>2. If stopped, start VM<br>3. Notify "VM ready" |

### Evening Shutdown

**Task: Evening Dev Shutdown**

| Trigger | Time → 10:00 PM |
| Actions | 1. Stop VM<br>2. Notify "VM stopped for tonight" |

### Location-Based

**Task: Arrive at Work**

| Trigger | Location → Enter → Work Location |
| Actions | 1. Start VM if needed<br>2. Open Termux |

## Manual Control

### Running Tasks Without Automation

If you prefer manual control:

1. Open Tasker
2. Go to Tasks tab
3. Tap task to run

### Manual Control via Android Intents

You can also trigger tasks from other apps:

```bash
# Via ADB (from PC)
adb shell am start -a net.dinglisch.android.tasker.ACTION_TASK -e task_name "Start Dev VM"
```

## Integration with Termux

Tasker can run Termux commands directly:

### Run Shell Action

```
Command: /data/data/com.termux/files/usr/bin/bash
Arguments: -c "cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-start"
Timeout: 120 seconds
```

Or with Termux:API plugin:

```
Action: Termux:API → Execute
Command: cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-start
```

## Troubleshooting

### HTTP Request Fails

- Check Cloud Function URL is correct
- Verify API key is valid
- Check network connection

### Termux Command Not Found

- Ensure Termux is installed
- Check package path (may vary)
- Use absolute path: `/data/data/com.termux/files/usr/bin/bash`

### Task Not Triggering

- Check trigger conditions
- Look in Tasker log (Menu → More → Run Log)
- Test task manually first

### Background Restrictions

Android may limit background actions:
- Add Tasker to battery optimization whitelist
- Allow background usage for Termux
- Consider using "Run in Foreground" option

## Advanced: Webhooks

For external triggering, use Join by joaoapps:

1. Install Join on Android
2. Create Tasker profile triggered by Join event
3. Trigger from anywhere via HTTP request to Join API

## Next Steps

1. Install Tasker
2. Import profiles: [tasker-import.xml](tasker-import.xml)
3. Test each task manually
4. Add widgets to home screen
5. Set up automation triggers
6. See [tasker-manual.md](tasker-manual.md) for manual procedures

## Resources

- Tasker Wiki: https://tasker.joaoapps.com/wiki/
- Tasker Forums: https://forum.joaoapps.com/
- Tasker Android App: https://play.google.com/store/apps/details=net.dinglisch.android.taskerm

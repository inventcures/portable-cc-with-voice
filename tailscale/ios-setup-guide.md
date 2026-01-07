# Tailscale iOS Setup Guide

This guide walks you through setting up Tailscale on your iOS device for secure access to your Portable Claude Code VM.

## Prerequisites

- iOS device (iPhone or iPad)
- Tailscale account (free tier works fine)
- VM with Tailscale installed and authenticated

## Installation Steps

### 1. Install the Tailscale iOS App

1. Open the App Store on your iOS device
2. Search for "Tailscale"
3. Download and install the app

   Or use this direct link: https://apps.apple.com/app/tailscale/id1474278280

### 2. Sign In to Tailscale

1. Open the Tailscale app
2. Choose your sign-in method:
   - **Recommended**: Sign in with Apple
   - Or use: Google, Microsoft, GitHub, or email
3. Authorize the app

### 3. Enable VPN

1. After signing in, you'll see a switch at the top
2. Tap the switch to enable the VPN
3. Confirm the VPN permission when prompted
4. The VPN icon will appear in your status bar

### 4. Verify Connection

1. In the Tailscale app, you should see your VM listed under "Machines"
2. Note the Tailscale IP address (looks like `100.x.x.x`)
3. You can also set a memorable name for your VM

### 5. Configure Termius

1. Open Termius
2. Add a new host:
   - **Alias**: `portable-cc` (or your preferred name)
   - **Hostname**: The Tailscale IP or hostname
   - **Port**: `22` (or `11222` if using Tailscale SSH)
   - **Username**: `ubuntu`
3. Add your SSH key:
   - In Termius, go to **Keychain**
   - Generate a new key or import existing
   - Add the public key to your VM's `~/.ssh/authorized_keys`

### 6. Test Connection

1. Make sure Tailscale VPN is connected on iOS
2. In Termius, tap your new host
3. You should connect via SSH

## Tips

### Background VPN

Tailscale on iOS maintains the VPN connection in the background, but iOS may disconnect it:

- **Solution**: Open Tailscale app briefly before connecting via Termius
- **Or**: Use **Blink Shell** which has better Tailscale integration

### mosh Support

For better network resilience (WiFi to cellular transitions):

1. **Use Blink Shell** instead of Termius for built-in mosh support
2. Or enable mosh in Termius if available

### Auto-Connect

To make connecting faster:

1. Use iOS Shortcuts to:
   - Open Tailscale (ensure VPN connected)
   - Open Termius
   - Auto-connect to your host

## Troubleshooting

### Can't see VM in Tailscale app

- Make sure VM is running
- Check VM is authenticated: `sudo tailscale status`
- Try restarting Tailscale on VM: `sudo systemctl restart tailscaled`

### Can't connect via SSH

- Verify Tailscale VPN is active on iOS
- Check the Tailscale IP hasn't changed
- Verify SSH key is properly configured
- Try connecting with verbose mode: `ssh -v ubuntu@<tailscale-ip>`

### VPN disconnects frequently

- This is iOS behavior for battery optimization
- Open Tailscale app briefly before using Termius
- Consider using Blink Shell for better integration

## Security Notes

- Your VM has no public IP - all access is through Tailscale
- Tailscale provides end-to-end encryption
- Only devices signed into your Tailscale account can connect
- Consider enabling Tailscale's ACLs for additional security

## Next Steps

1. Configure push notifications (see `../notifications/`)
2. Set up voice input (see `../voice/`)
3. Create iOS Shortcuts for quick VM control (see `../ios-shortcuts/`)

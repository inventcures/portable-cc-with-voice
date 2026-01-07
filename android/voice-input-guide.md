# Voice Input Guide for Android

Android offers several voice input options for use with Portable Claude Code. This guide compares options and helps you choose the right one.

## Options Overview

| Option | Price | Offline | Quality | Best For |
|--------|-------|---------|--------|----------|
| **Gboard Voice Typing** | Free | ❌ | ⭐⭐⭐⭐ | General use, built-in |
| **Google Voice Access** | Free | ⭐⭐⭐ | ⭐⭐⭐⭐ | Complete hands-free |
| **Futo Voice Input** | Paid | ⭐⭐⭐ | ⭐⭐⭐ | Privacy, dictation |
| **FlorisBoard** | Free | ✅ | ⭐⭐⭐ | Open-source, custom keyboard |

## Recommendation

For most users: **Gboard Voice Typing** (built-in, works everywhere)

For hands-free coding: **Google Voice Access**

For privacy: **Futo Voice Input**

## Gboard Voice Typing (Built-in)

### Setup

Gboard is pre-installed on most Android devices.

1. Enable in any app with text input:
   - Tap text field
   - Tap microphone icon on keyboard
   - Or use Gboard settings

### Enabling if Not Present

```bash
# Play Store
https://play.google.com/store/apps/details=com.google.android.inputmethod.latin

# Install Gboard
# Set as default keyboard
```

### Using Gboard Voice Typing

1. Tap in a text field (Termux, JuiceSSH, etc.)
2. Tap microphone icon on keyboard
3. Speak your command
4. Gboard transcribes to text
5. Tap to correct if needed
6. Press Enter to send

### Tips

- **Speak clearly**: Normal pace, natural tone
- **Say punctuation**: "period", "comma", "open parenthesis", etc.
- **Review text**: Always review before sending
- **Works offline**: No, requires internet connection

### Punctuation Commands

| To say | Result |
|--------|--------|
| "period" or "dot" | . |
| "comma" | , |
| "question mark" | ? |
| "exclamation mark" | ! |
| "colon" | : |
| "semicolon" | ; |
| "open parenthesis" | ( |
| "close parenthesis" | ) |
| "new line" | Enter |

### Example Commands

```
"git status"
"git commit -m, fix login bug, period"
"claude-code"
"create function fetch user data"
"run tests"
```

## Google Voice Access (Full Voice Control)

### What is Google Voice Access?

A complete voice control system for Android. You can control the entire device by voice.

### Setup

1. Go to Settings
2. Accessibility → Voice Access
3. Turn on Voice Access
4. Follow setup tutorial

### Using Voice Access

1. Activate Voice Access:
   - "Hey Google, Voice Access" (if enabled)
   - Or tap accessibility button

2. Commands:
   - "Open Termux"
   - "Type [your command]"
   - "Tap enter"
   - "Show keyboard"

### Voice Access Commands

**Navigation:**
- "Go home"
- "Go back"
- "Open [app name]"
- "Show notifications"

**Typing:**
- "Type [text]"
- "Delete [number] characters"
- "Replace [word] with [word]"

**In Termux:**
- "Type git status"
- "Tap enter"
- "Type claude-code"
- "Tap enter"

### Tips

- Great for truly hands-free operation
- Works anywhere in Android
- Can use with screen off (with some limitations)
- Requires practice to learn commands

## Futo Voice Input (Privacy-Focused)

### What is Futo?

A privacy-focused voice input keyboard that processes voice locally.

### Setup

```bash
# Play Store
https://play.google.com/store/apps/details=com.futo.inputmethod.latin

# Or GitHub
https://github.com/futo-org/futo-voice-input
```

### Features

- **Local processing**: No cloud needed
- **Privacy-first**: Voice never leaves device
- **Offline**: Works without internet
- **Paid**: One-time purchase

### Why Use Futo?

- Privacy concerns with Google services
- Need offline voice input
- Want to support privacy-focused projects

## FlorisBoard (Open Source)

### What is FlorisBoard?

An open-source keyboard for Android with plugin support.

### Setup

```bash
# Play Store
https://play.google.com/store/apps/details=org.florisboard.florisboard

# Or F-Droid
https://f-droid.org/packages/org.florisboard.florisboard/
```

### Features

- Completely open-source
- Plugin architecture
- Voice input plugin available
- Highly customizable

### Voice Input Plugin

1. Install FlorisBoard
2. Enable as keyboard
3. Go to FlorisBoard Settings
4. Plugins → Add Plugin
5. Install Voice Input plugin
6. Enable plugin

### Why FlorisBoard?

- Want open-source alternatives
- Don't want Google/Big Tech keyboards
- Want to customize keyboard experience

## Comparison to iOS Options

| Feature | iOS (Wispr Flow) | Android (Gboard) |
|---------|------------------|-------------------|
| Formatting | Excellent (removes filler) | Basic (raw transcription) |
| Offline | Yes (iOS 26+) | No (requires internet) |
| Technical terms | Excellent | Good |
| Privacy | Cloud processing | Google cloud |
| Cost | Free tier available | Free |
| Setup | Keyboard extension | Built-in |

**Note**: Wispr Flow is better for formatting, but Android alternatives are improving.

## Voice Input in Termux

### Using Voice Input in Termux

1. Open Termux
2. Tap in terminal to bring up keyboard
3. Tap microphone icon (Gboard or Voice Access)
4. Speak command
5. Voice is transcribed to terminal
6. Press Enter to execute

### Voice Input in JuiceSSH

1. Open JuiceSSH
2. Connect to your VM
3. Long press in terminal
4. Paste or use voice input
5. Voice is transcribed to terminal

### External Keyboard with Voice

If using an external keyboard:

1. Some have microphone keys
2. Or use voice input on device keyboard
3. Switch between keyboards as needed

## Best Practices

### For Coding Commands

1. **Speak clearly and slowly**
2. **Use simple commands**: "git status" vs complex phrases
3. **Spell out unusual words**: "c-l-a-u-d-e" if needed
4. **Review before sending**: Always check transcribed text

### For Claude Conversations

Claude understands natural language, so:

1. **Speak naturally**: "Create a function that fetches user data"
2. **Don't overthink punctuation**: Claude understands
3. **Be specific**: "Fix the bug on line 42"
4. **Review**: Check the transcription

### Common Issues

**Problem**: Transcription has errors

**Solutions**:
- Speak more slowly
- Use shorter phrases
- Spell technical terms
- Use "delete" and re-dictate

**Problem**: No microphone icon

**Solutions**:
- Check keyboard settings
- Switch to Gboard
- Enable voice input in Android settings

**Problem**: "Can't reach Google"

**Solutions**:
- Check internet connection
- Try offline alternative (Futo Voice Input)
- Type manually as fallback

## Advanced: ADB Voice Commands

For advanced users with ADB enabled:

```bash
# Trigger voice input via ADB
adb shell input text "your-text-here"

# Simulate microphone button
adb shell input keyevent 4
```

## Accessibility: Voice Control for Entire Device

For users who need or want complete voice control:

### Google Voice Access + Termux

1. Enable Voice Access
2. Say "Open Termux"
3. Say "Type mosh ubuntu at portable dash cc dash dev"
4. Say "Tap enter"
5. Use voice commands to navigate tmux

This allows hands-free operation of your entire development workflow!

## Next Steps

1. Choose your voice input method
2. Practice with simple commands
3. Set up any required apps
4. Test in Termux or JuiceSSH
5. Learn workflows: [workflows-guide.md](workflows-guide.md)

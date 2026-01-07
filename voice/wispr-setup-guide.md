# Wispr Flow Setup for Mobile Claude Code

Wispr Flow is an AI-powered voice keyboard that provides excellent transcription for coding and technical terms.

## What is Wispr Flow?

Wispr Flow is an iOS keyboard that:
- Transcribes speech to text with high accuracy
- Removes filler words (um, uh, like)
- Understands technical terminology
- Works offline on newer iOS versions
- Formats commands properly

## Installation

### Step 1: Download from App Store

1. Open App Store
2. Search for "Wispr Flow"
3. Download and install

   Direct link: https://apps.apple.com/app/wispr-flow-ai-voice-keyboard/id6497229487

### Step 2: Initial Setup

1. Open Wispr Flow
2. Create an account (free tier available)
3. Complete the tutorial
4. Grant microphone permissions

### Step 3: Enable as Keyboard

1. Open iOS Settings
2. Go to **General > Keyboard > Keyboards**
3. Tap **Add New Keyboard**
4. Select **Wispr Flow**
5. Tap **Wispr Flow** in the list
6. Enable **Allow Full Access**
7. Confirm

### Step 4: Grant Full Access

Full Access is required for Wispr Flow to work properly:

1. In Settings > Keyboards > Wispr Flow
2. Toggle **Allow Full Access** to ON
3. Confirm the prompt

**Note**: Full Access allows the keyboard to transmit text to apps. This is required for all third-party keyboards.

## Using Wispr Flow in Termius

### Basic Usage

1. Open **Termius** on your iPhone
2. Connect to your VM via SSH
3. Tap in the terminal input area
4. Tap the **globe/icon** to switch keyboards
5. Select **Wispr Flow**
6. Tap the **microphone** button
7. Speak your command
8. Wispr Flow transcribes and formats
9. Switch back to regular keyboard
10. Press **Enter** to execute

### Example Commands

Try speaking these:

```
"git checkout main"
"claude-code"
"npm run dev"
"git status"
"docker ps -a"
```

Wispr Flow handles:
- Terminal commands
- Code snippets
- Git commands
- File paths
- Technical terms

### Tips for Better Transcription

1. **Speak clearly** at normal pace
2. **Use natural phrasing** for commands
3. **Spell unusual names** if needed (Wispr learns)
4. **Pause briefly** between commands
5. **Review before executing** (check the transcribed text)

## Wispr Flow Features

### Custom Vocabulary

Wispr Flow can learn your project-specific terms:

1. Open Wispr Flow app
2. Go to Settings > Vocabulary
3. Add words like:
   - Project names
   - Function names
   - Special variables
   - Team member names

### Custom Snippets

Create voice shortcuts for common commands:

1. Open Wispr Flow app
2. Go to Snippets
3. Add new snippet
4. Set voice trigger (e.g., "run tests")
5. Set text output (e.g., "npm test -- --watch")

### Multiple Languages

Wispr Flow supports multiple languages:
- English (best for coding)
- Spanish
- French
- German
- And more...

## Comparison: Wispr Flow vs Siri Dictation

| Feature | Wispr Flow | Siri Dictation |
|---------|-----------|----------------|
| Filler word removal | Yes | No |
| Formatting | Excellent | Basic |
| Offline | Yes (iOS 26+) | No |
| Technical terms | Excellent | Fair |
| Custom vocabulary | Yes | No |
| Cost | Free tier | Free |

## Troubleshooting

### Keyboard Not Appearing

1. Check Wispr Flow is enabled in Settings
2. Check "Allow Full Access" is ON
3. Restart Termius
4. Try in another app (Notes) to test

### Transcription Poor

1. Speak more clearly
2. Check microphone not covered
3. Add technical terms to vocabulary
4. Try in quieter environment

### Can't Switch Keyboards

1. Long press the globe icon
2. Or tap globe icon multiple times
3. Or use Settings > General > Keyboard > Keyboards to set default

### Battery Drain

Voice keyboards use more battery:
- Close keyboard when not in use
- Use regular keyboard for typing
- Keep app updated

## Alternative: Siri Dictation

If Wispr Flow doesn't work for you, use iOS native dictation:

1. Enable in Settings > General > Keyboard > Enable Dictation
2. In Termius, tap microphone key on keyboard
3. Speak
4. Text appears

**Note**: Siri requires internet connection and doesn't format as well.

## Best Practices for Claude Code

When dictating to Claude Code:

1. **Be explicit**: "Create a new function called fetch user data"
2. **Speak punctuation**: "Create function, open parenthesis, close parenthesis"
3. **Use natural language**: Claude understands conversational input
4. **Review before sending**: Check the transcribed text

### Example Conversations

```
You: "Create a react component for user profile"
You: "Add a button that calls the delete function"
You: "Fix the typescript error on line 42"
You: "Refactor this function to be more readable"
```

## Tips for Mobile Coding

1. **Keep commands short** - easier to transcribe accurately
2. **Use Claude for heavy lifting** - let it write the code
3. **Review in chunks** - don't dictate large blocks at once
4. **Use git copiously** - commit often, easy to revert
5. **Take breaks** - voice input can be tiring

## Privacy

- Wispr Flow processes voice locally when possible
- Cloud processing for some features
- Check privacy policy: https://wisprflow.ai/privacy
- For sensitive work, consider alternatives

## Resources

- Wispr Flow: https://wisprflow.ai/
- App Store: https://apps.apple.com/app/wispr-flow-ai-voice-keyboard/id6497229487
- Documentation: https://docs.wisprflow.ai/

## Next Steps

1. Install Wispr Flow
2. Complete setup
3. Practice with simple commands
4. Try with Claude Code
5. Build custom snippets for your workflow

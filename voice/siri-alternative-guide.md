# Siri Voice Input Alternative Guide

If Wispr Flow isn't available or you prefer using built-in iOS features, this guide shows you how to use Siri Dictation and Siri Shortcuts for voice input with Claude Code.

## Option 1: Siri Dictation (Built-in)

iOS has built-in dictation that works in any text field.

### Enable Siri Dictation

1. Open **Settings**
2. Go to **General > Keyboard**
3. Enable **Enable Dictation**

### Using Siri Dictation in Termius

1. Open **Termius**
2. Connect to your VM
3. Tap in the terminal
4. Tap the **microphone** key on the keyboard (next to spacebar)
5. Speak your command
6. Tap Done when finished
7. Press **Enter** to execute

### Limitations

- Requires internet connection
- No automatic formatting
- Doesn't remove filler words
- Less accurate with technical terms
- Basic punctuation only

### Tips for Better Results

1. **Speak slowly and clearly**
2. **Say punctuation explicitly**: "period", "comma", "open parenthesis", "close parenthesis"
3. **Spell technical terms**: "C L A U D E dash code"
4. **Keep commands short**: One line at a time

## Option 2: Siri Shortcuts

Create Siri shortcuts that open Termius pre-configured.

### Basic "Open Terminal" Shortcut

1. Open **Shortcuts** app
2. Tap **+** to create new
3. Add action: **Open App**
4. Select **Termius**
5. Name: "Open Terminal"
6. Add to Siri: "Open terminal"

### Advanced "Ask Claude" Shortcut

This shortcut lets you dictate a message for Claude:

```
1. Dictate Text
   - Prompt: "What do you want to ask Claude?"
2. Copy to Clipboard
3. Open Termius
4. [User pastes and sends]
```

**Note**: This is manual - you still need to paste the text.

### "Start Dev Session" Shortcut

Combines multiple actions:

```
1. Run "Start Dev VM" shortcut (from ios-shortcuts/)
2. Wait 5 seconds
3. Open Termius
4. [User connects manually]
```

## Option 3: Voice Control (Accessibility)

iOS has a Voice Control feature that works everywhere:

### Enable Voice Control

1. Open **Settings**
2. Go to **Accessibility**
3. Tap **Voice Control**
4. Enable **Voice Control**

### Using Voice Control

1. Say "Show numbers" to see numbered controls
2. Say numbers to tap items
3. Say "Tap [item name]" for direct control
4. Say "Dictate [text]" to enter text

This is more complex but very powerful.

## Comparison

| Feature | Siri Dictation | Wispr Flow | Voice Control |
|---------|---------------|------------|---------------|
| Ease of use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Formatting | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Offline | ❌ | ✅ | ✅ |
| Technical terms | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Free | ✅ | Free tier | ✅ |

## Recommended Workflow (Siri Dictation)

### For Commands

```
1. Tap microphone key
2. Speak: "git status"
3. Tap Done
4. Press Enter
```

### For Multi-line Input

```
1. Type first part
2. Tap microphone
3. Speak: "git commit -m, open quote, fix bug, close quote"
4. Tap Done
5. Press Enter
```

### For Claude Conversations

```
1. Tap microphone
2. Speak naturally: "create a function that fetches user data"
3. Tap Done
4. Press Enter
5. Claude understands the natural language
```

## Punctuation Guide

When using Siri Dictation, say punctuation explicitly:

| Symbol | Say |
|--------|-----|
| . | "period" or "dot" |
| , | "comma" |
| ? | "question mark" |
| ! | "exclamation point" |
| : | "colon" |
| ; | "semicolon" |
| ( | "open parenthesis" |
| ) | "close parenthesis" |
| [ | "open bracket" |
| ] | "close bracket" |
| { | "open brace" |
| } | "close brace" |
| ' | "open single quote" / "close single quote" |
| " | "open quote" / "close quote" |
| @ | "at" |
| # | "hash" or "pound" |
| $ | "dollar sign" |
| % | "percent" |
| & | "ampersand" |
| * | "asterisk" |
| + | "plus" |
| - | "hyphen" or "minus" |
| = | "equals" |
| _ | "underscore" |
| | | "vertical bar" or "pipe" |
| / | "slash" or "forward slash" |
| \ | "backslash" |
| ~ | "tilde" |
| ` | "backtick" |

## Example Commands with Punctuation

```
"git commit -m, open quote, fix login bug, close quote"
"docker run -d -p, eight thousand colon eighty, nginx"
"export, space, API key, equals, open quote, my key, close quote"
```

## Siri Shortcuts for Common Tasks

### Quick Status Check

1. Get Contents of URL: VM status endpoint
2. Show result in notification
3. Add to Siri: "Check VM status"

### Quick Start

1. Run Start VM shortcut
2. Wait for confirmation
3. Open Termius
4. Add to Siri: "Start coding"

### Quick Stop

1. Run Stop VM shortcut
2. Show confirmation
3. Add to Siri: "Stop coding"

## Limitations and Workarounds

### Limitation: Can't paste automatically

**Workaround**: Use clipboard manager or manual paste

### Limitation: Terminal input awkward

**Workaround**: Use dictation for Claude prompts, typing for commands

### Limitation: No code formatting

**Workaround**: Let Claude write the code, dictate natural language prompts

## Tips for Best Results

1. **Speak clearly** - at normal pace, not too fast
2. **Use quiet environment** - reduces errors
3. **Review before sending** - catch transcription errors
4. **Use natural language** - Claude understands conversational input
5. **Keep it short** - shorter = more accurate
6. **Practice** - get used to punctuation phrases

## Next Steps

1. Enable Siri Dictation
2. Practice with simple commands
3. Create Siri Shortcuts for common tasks
4. Test with Claude Code
5. Consider Wispr Flow for better formatting

## Accessibility Considerations

If you have difficulty using touch:
- Voice Control provides full control
- Siri can open apps and make calls
- Shortcuts can automate complex tasks

For users with speech impairments:
- All features work with typing
- Claude Code is fully keyboard-accessible
- Termius supports external keyboards

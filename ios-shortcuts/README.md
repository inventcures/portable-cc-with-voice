# iOS Shortcuts for VM Control

Create iOS Shortcuts to start and stop your Portable Claude Code VM from your iPhone home screen.

## Option 1: Using GCP Cloud Function (Recommended)

The Cloud Function provides a simple API key authentication instead of complex OAuth.

### Step 1: Deploy the Cloud Function

See `gcp-cloud-function.py` for deployment instructions.

### Step 2: Get Your Function URL

After deployment, you'll get a URL like:
```
https://REGION-PROJECT_ID.cloudfunctions.net/vm-control
```

### Step 3: Create "Start VM" Shortcut

1. Open iOS Shortcuts app
2. Tap "+" to create new shortcut
3. Tap "Add Action"
4. Search for "Get Contents of URL"
5. Configure:
   - URL: `YOUR_FUNCTION_URL`
   - Method: `POST`
   - Headers: Add new header
     - Name: `X-API-Key`
     - Value: `YOUR_API_KEY`
6. Add action: "Show Notification"
   - Text: "VM is starting..."
7. Name: "Start Dev VM"
8. Add to Home Screen

### Step 4: Create "Stop VM" Shortcut

Same as above, but:
- Method: `DELETE`
- Notification text: "VM is stopping..."
- Name: "Stop Dev VM"

### Step 5: Create "Check VM Status" Shortcut

Same as above, but:
- Method: `GET`
- Parse JSON response and show status
- Name: "VM Status"

## Option 2: Direct GCP API (OAuth)

This method uses OAuth tokens which is more complex but doesn't require a Cloud Function.

### Step 1: Create OAuth Credentials

```bash
# Create OAuth client ID for iOS
gcloud iam oauth-clients create portable-cc-ios \
    --display-name="Portable CC iOS"
```

### Step 2: Get Access Token

You'll need to implement OAuth flow in the shortcut, which is complex.

**Recommendation**: Use Option 1 (Cloud Function) instead.

## Option 3: Using gcloud REST API with Service Account Key

This uses your service account key directly (less secure but simpler).

### Step 1: Base64 Encode Your Key

```bash
base64 -i ~/gcp-key-portable-cc-dev.json
```

### Step 2: Create Shortcut with Bearer Token

1. Get Contents of URL: `https://oauth2.googleapis.com/token`
   - Method: POST
   - Body: Form
   - Form: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=YOUR_JWT`
   - Note: You need to sign a JWT with your key

This is complex. **Use Option 1**.

## Shortcut Examples

### Start VM (Cloud Function)

```
1. URL: https://us-central1-portable-cc-dev.cloudfunctions.net/vm-control
2. Method: POST
3. Header: X-API-Key = your-api-key
4. Get result from URL
5. If result contains "starting":
   Show notification "VM is starting..."
6. Wait 10 seconds
7. Show notification "VM should be ready. Open Termius to connect."
```

### Stop VM (Cloud Function)

```
1. URL: https://us-central1-portable-cc-dev.cloudfunctions.net/vm-control
2. Method: DELETE
3. Header: X-API-Key = your-api-key
4. Get result from URL
5. Show notification "VM is stopping. You won't be charged now!"
```

### Check Status (Cloud Function)

```
1. URL: https://us-central1-portable-cc-dev.cloudfunctions.net/vm-control
2. Method: GET
3. Header: X-API-Key = your-api-key
4. Get result from URL
5. Dictionary: Get value for "status"
6. Show notification "VM status: {status}"
```

## Advanced: Combined Shortcut

Create one shortcut that:

1. Checks VM status (GET)
2. If stopped: Start it (POST)
3. If running: Ask if you want to stop it
4. Show appropriate notification

### Shortcut Flow:

```
1. GET URL (check status)
2. Get dictionary value for "status"
3. If status is "TERMINATED" or "STOPPED":
   - POST URL (start)
   - Show notification "Starting VM..."
4. If status is "RUNNING":
   - Ask "VM is running. Stop it?"
   - If yes: DELETE URL (stop)
   - Show notification "Stopping VM..."
5. Otherwise:
   - Show notification "VM status: {status}"
```

## Automation: Auto-Start When Opening Termius

You can create a shortcut that:

1. Checks VM status
2. Starts it if needed
3. Opens Termius
4. Auto-connects to your host

Use this as your primary way to start coding!

## Security Notes

1. **Never share your API key**
2. **Store in iCloud Keychain** when possible
3. **Use Cloud Function** instead of direct API (limits exposure)
4. **Rotate keys periodically**

## Troubleshooting

### "Unauthorized" Error

- Check API key is correct
- Check X-API-Key header is set
- Verify Cloud Function is deployed

### "404 Not Found"

- Check function URL is correct
- Verify region matches your deployment
- Check function name matches

### "Timeout"

- VM starting can take 1-2 minutes
- Use async pattern: start, then check status later
- Add retry logic in shortcut

## Next Steps

1. Deploy Cloud Function
2. Create shortcuts
3. Add to home screen
4. Test from iPhone
5. Add to Siri: "Hey Siri, start dev VM"

For more on Cloud Functions, see:
https://cloud.google.com/functions/docs

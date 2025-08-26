# Watch Connectivity Test Guide

## Prerequisites
1. **Physical Devices Only**: Watch Connectivity doesn't work reliably in simulator
2. **Both apps installed**: iOS app and watch app must be installed on their respective devices
3. **Same Apple ID**: Both devices must be signed in with the same Apple ID
4. **Bluetooth enabled**: Both devices must have Bluetooth enabled
5. **Watch paired**: Apple Watch must be paired with iPhone

## Test Steps

### Step 1: Clean Build
1. In Xcode, go to Product → Clean Build Folder
2. Build and run both apps fresh

### Step 2: Check Console Logs
1. Open Console app on Mac
2. Filter by your device names
3. Look for these log patterns:
   - `⌚ WatchConnectivity: Initializing`
   - `⌚ WatchConnectivity: Session activated successfully`
   - `⌚ WatchConnectivity: Watch app installed: true`
   - `⌚ WatchConnectivity: Watch app reachable: true`

### Step 3: Test Sequence
1. **Start watch app first**, wait for session activation
2. **Start iOS app**, wait for session activation
3. **Sign in on iOS app**, check if data is sent to watch
4. **Check watch app**, should show user data

### Step 4: Debug Commands
- Use "Test Connection" button on watch app
- Check session state in iOS app console
- Look for error messages in both consoles

## Common Issues

### "Companion app is not installed"
- **Cause**: Bundle identifier mismatch or app not properly installed
- **Fix**: Verify bundle identifiers match in project settings

### "Session not activated"
- **Cause**: WCSession not properly initialized
- **Fix**: Ensure both apps call `session.activate()`

### "Watch app not reachable"
- **Cause**: Watch app not running or Bluetooth issues
- **Fix**: Make sure watch app is running and Bluetooth is enabled

## Bundle Identifiers
- iOS App: `com.bernsonfamily.volume-fitness-tracker`
- Watch App: `com.bernsonfamily.volume-fitness-tracker.watchkitapp`

## Expected Console Output

### iOS App (Successful)
```
⌚ WatchConnectivity: Initializing iOS Watch Connectivity Manager
⌚ WatchConnectivity: Session activation started
⌚ WatchConnectivity: Session activated successfully
⌚ WatchConnectivity: Watch app installed: true
⌚ WatchConnectivity: Watch app reachable: true
⌚ WatchConnectivity: Successfully sent user data to watch
```

### Watch App (Successful)
```
⌚ WatchConnectivity: Initializing Watch App Watch Connectivity Manager
⌚ WatchConnectivity: Session activation started
⌚ WatchConnectivity: Session activated successfully
⌚ WatchConnectivity: Received message from iOS app
⌚ WatchConnectivity: User data received - Email: user@example.com
```

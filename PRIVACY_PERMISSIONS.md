# Privacy Permissions for BackyardGolf App

This document contains the privacy permissions that need to be added to your BackyardGolf app's Info.plist file to enable video recording and social sharing features.

## Required Privacy Permissions

Add the following keys and values to your app's Info.plist file in Xcode:

### 1. Bluetooth Permission (Already exists)
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Connect to ESP32 for LED control and shot tracking</string>
```

### 2. Camera Permission (NEW)
```xml
<key>NSCameraUsageDescription</key>
<string>Record trick shots and create video highlights to share</string>
```

### 3. Microphone Permission (NEW)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Record audio with trick shot videos</string>
```

### 4. Photo Library Add Permission (NEW)
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save recorded trick shot videos to your photo library</string>
```

### 5. Photo Library Access Permission (NEW)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos and videos to share with your golf achievements</string>
```

## How to Add These Permissions in Xcode

1. **Open your project in Xcode**
   - Open `BackyardGolf.xcodeproj` in Xcode

2. **Select the BackyardGolf target**
   - Click on the project name in the navigator
   - Select the "BackyardGolf" target

3. **Go to the Info tab**
   - Click on the "Info" tab in the target settings

4. **Add the privacy permissions**
   - Click the "+" button to add new entries
   - Add each of the keys above with their corresponding values

## Alternative Method: Edit Info.plist Directly

If you prefer to edit the Info.plist file directly:

1. **Find the Info.plist file**
   - In Xcode, look for "Info.plist" in the project navigator
   - If not visible, it may be embedded in the project settings

2. **Add the privacy keys**
   - Add each key-value pair from the list above

## What These Permissions Enable

- **NSBluetoothAlwaysUsageDescription**: Allows the app to connect to your ESP32 smart hole device
- **NSCameraUsageDescription**: Enables video recording for trick shots
- **NSMicrophoneUsageDescription**: Records audio with video recordings
- **NSPhotoLibraryAddUsageDescription**: Saves recorded videos to the user's photo library
- **NSPhotoLibraryUsageDescription**: Allows access to photos for sharing achievements

## Testing the Permissions

After adding these permissions:

1. **Build and run the app** on a physical device (permissions don't work in simulator)
2. **Test video recording** - the app will request camera and microphone permissions
3. **Test photo library access** - the app will request photo library permissions
4. **Test Bluetooth connectivity** - the app will request Bluetooth permissions

## Important Notes

- These permissions are required for the video recording and social sharing features to work
- Users will see these permission requests when they first use the features
- The app will gracefully handle cases where users deny permissions
- All permission requests include clear explanations of why the app needs access

## Privacy Compliance

These permission descriptions are designed to be:
- **Clear and specific** about what the app does with the data
- **User-friendly** and easy to understand
- **Compliant** with App Store guidelines
- **Transparent** about data usage

Your BackyardGolf app is now ready with all the necessary privacy permissions for a complete video recording and social sharing experience! 🏌️‍♂️📱✨

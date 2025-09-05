# 🏌️ Backyard Golf - iOS Companion App

A sophisticated iOS companion app for your high-tech backyard golf setup featuring ESP32 Bluetooth integration, LED control, automatic shot tracking, and social media sharing.

## ✨ Features

### 🔧 Hardware Integration
- **ESP32 Bluetooth Communication** - Connect and control your ESP32-based setup
- **LED Strip Control** - Turn on/off, change colors, set patterns
- **Automatic Shot Detection** - Real-time shot tracking via sensors
- **UWB Support** - Ultra Wideband positioning for precise tracking

### 📱 Social Features  
- **Shot Recording** - Capture and share your best shots
- **Leaderboards** - Compete with friends and family
- **Social Sharing** - Post to Instagram, Twitter, Facebook
- **Achievement System** - Unlock milestones and badges

### 🎯 Game Features
- **Score Tracking** - Keep detailed game statistics
- **Multiple Game Modes** - Various scoring systems and challenges
- **Player Management** - Add players, track individual stats
- **Weather Integration** - Factor in wind and conditions

## 🚀 Quick Start

### Prerequisites
- **macOS** with Xcode 15+
- **iOS 16+** device or simulator
- **ESP32** microcontroller with Bluetooth capability
- **Apple Developer Account** (for device testing)

### 1. Clone & Setup
```bash
# Clone your repository
git clone https://github.com/danbrown20/BackyardGolf-iOS.git
cd BackyardGolf-iOS

# Open in Xcode
open BackyardGolf.xcodeproj
# OR if you have a workspace:
open BackyardGolf.xcworkspace
# OR if it's a Swift Package:
open Package.swift
```

### 2. Configure Permissions
Add these to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Connect to ESP32 for LED control and shot tracking</string>

<key>NSCameraUsageDescription</key>
<string>Record golf shots and create highlights</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>UWB positioning for precise shot tracking</string>

<key>NSMicrophoneUsageDescription</key>
<string>Record audio with shot videos</string>
```

### 3. Enable Capabilities
In Xcode, go to **Signing & Capabilities** and add:
- ✅ **Background Modes** → "Uses Bluetooth LE accessories"
- ✅ **Camera** access
- ✅ **Location Services**

### 4. ESP32 Setup
Configure your ESP32 with these UUIDs (or customize in `ESP32BluetoothManager.swift`):

```cpp
// ESP32 Arduino Code
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define LED_CONTROL_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define SHOT_SENSOR_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26a9"
```

## 🔧 Usage

### Basic Integration
```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = ESP32BluetoothManager()
    
    var body: some View {
        VStack {
            Text("Backyard Golf")
                .font(.largeTitle)
            
            Text(bluetoothManager.connectionStatus)
                .foregroundColor(bluetoothManager.isConnected ? .green : .red)
            
            if bluetoothManager.isConnected {
                Button("Toggle LEDs") {
                    bluetoothManager.toggleLEDs()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("Connect to ESP32") {
                    bluetoothManager.startScanning()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Text("Shots: \(bluetoothManager.shotCount)")
                .font(.title2)
        }
        .padding()
    }
}
```

### LED Control Commands
```swift
// Turn LEDs on/off
bluetoothManager.toggleLEDs()

// Set colors
bluetoothManager.setLEDColor("RED")
bluetoothManager.setLEDColor("GREEN") 
bluetoothManager.setLEDColor("BLUE")

// Set patterns
bluetoothManager.setLEDPattern("FLASH")
bluetoothManager.setLEDPattern("PULSE")
bluetoothManager.setLEDPattern("RAINBOW")

// Celebration mode (automatic)
bluetoothManager.celebrationMode()
```

## 🤖 Automation

### GitHub Actions
Automatic build and test on every push:
- ✅ **Builds** all project types (Package.swift, .xcodeproj, .xcworkspace)
- ✅ **Tests** on iOS Simulator
- ✅ **Archives** for distribution on main branch
- ✅ **Uploads** build artifacts

### Local Development
```bash
# Build project
xcodebuild -scheme BackyardGolf -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -scheme BackyardGolf -destination 'platform=iOS Simulator,name=iPhone 16' test

# Install on simulator
xcrun simctl install booted ./build/BackyardGolf.app
```

## 📋 ESP32 Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `LED_ON` | Turn all LEDs on | `bluetoothManager.toggleLEDs()` |
| `LED_OFF` | Turn all LEDs off | `bluetoothManager.toggleLEDs()` |
| `COLOR_RED` | Set LEDs to red | `bluetoothManager.setLEDColor("RED")` |
| `COLOR_GREEN` | Set LEDs to green | `bluetoothManager.setLEDColor("GREEN")` |
| `COLOR_BLUE` | Set LEDs to blue | `bluetoothManager.setLEDColor("BLUE")` |
| `PATTERN_FLASH` | Flashing pattern | `bluetoothManager.setLEDPattern("FLASH")` |
| `PATTERN_PULSE` | Pulsing pattern | `bluetoothManager.setLEDPattern("PULSE")` |
| `PATTERN_RAINBOW` | Rainbow cycle | `bluetoothManager.setLEDPattern("RAINBOW")` |

## 🛠 Customization

### Change ESP32 UUIDs
Edit `ESP32BluetoothManager.swift`:
```swift
private let serviceUUID = CBUUID(string: "YOUR-SERVICE-UUID")
private let ledControlUUID = CBUUID(string: "YOUR-LED-UUID")
private let shotSensorUUID = CBUUID(string: "YOUR-SENSOR-UUID")
```

### Add New Commands
```swift
func setLEDBrightness(_ level: Int) {
    guard isConnected, let characteristic = ledControlCharacteristic else { return }
    sendCommand("BRIGHTNESS_\(level)", to: characteristic)
}
```

## 🚧 Roadmap

- [ ] **Social Media Integration** (Instagram, Twitter sharing)
- [ ] **Game Modes** (tournaments, challenges)
- [ ] **Statistics Dashboard** (detailed analytics)
- [ ] **UWB Integration** (precise positioning)
- [ ] **Weather API** (wind/temperature tracking)
- [ ] **Apple Watch** companion app
- [ ] **iPad** optimized interface

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏌️‍♂️ About

Created for enthusiasts who want to bring technology to their backyard golf games. Perfect for tracking shots, controlling ambiance, and sharing achievements with the golf community.

---

**Happy Golfing!** 🏌️‍♂️🎯

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = ESP32BluetoothManager()
    @State private var showingSettings = false
    @State private var selectedColor = "GREEN"
    @State private var selectedPattern = "SOLID"
    
    let colors = ["RED", "GREEN", "BLUE", "YELLOW", "PURPLE", "CYAN", "WHITE"]
    let patterns = ["SOLID", "FLASH", "PULSE", "RAINBOW", "STROBE"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    headerView
                    
                    // Connection Status
                    connectionStatusView
                    
                    // Control Panel
                    if bluetoothManager.isConnected {
                        controlPanelView
                    } else {
                        connectButtonView
                    }
                    
                    // Shot Statistics
                    shotStatsView
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Backyard Golf")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack {
            Image(systemName: "figure.golf")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Backyard Golf Pro")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(.top)
    }
    
    // MARK: - Connection Status
    private var connectionStatusView: some View {
        VStack(spacing: 10) {
            HStack {
                Circle()
                    .fill(bluetoothManager.isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(bluetoothManager.connectionStatus)
                    .font(.headline)
                    .foregroundColor(bluetoothManager.isConnected ? .green : .primary)
                
                Spacer()
                
                if bluetoothManager.isScanning {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if bluetoothManager.isConnected && bluetoothManager.rssi.intValue != 0 {
                Text("Signal: \(bluetoothManager.rssi.intValue) dBm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Connect Button
    private var connectButtonView: some View {
        VStack(spacing: 15) {
            Button(action: {
                bluetoothManager.startScanning()
            }) {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Connect to ESP32")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(bluetoothManager.isScanning)
            
            Text("Make sure your ESP32 is powered on and in range")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Control Panel
    private var controlPanelView: some View {
        VStack(spacing: 20) {
            
            // LED Controls
            VStack(alignment: .leading, spacing: 15) {
                Text("LED Controls")
                    .font(.headline)
                
                // On/Off Toggle
                HStack {
                    Text("LEDs")
                    Spacer()
                    Toggle("", isOn: $bluetoothManager.ledStatus)
                        .onChange(of: bluetoothManager.ledStatus) { _ in
                            bluetoothManager.toggleLEDs()
                        }
                }
                
                if bluetoothManager.ledStatus {
                    // Color Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                            ForEach(colors, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                    bluetoothManager.setLEDColor(color)
                                }) {
                                    Circle()
                                        .fill(colorFromString(color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Pattern Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pattern")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Pattern", selection: $selectedPattern) {
                            ForEach(patterns, id: \.self) { pattern in
                                Text(pattern).tag(pattern)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedPattern) { pattern in
                            bluetoothManager.setLEDPattern(pattern)
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // Quick Actions
            VStack(alignment: .leading, spacing: 15) {
                Text("Quick Actions")
                    .font(.headline)
                
                HStack(spacing: 15) {
                    Button("Celebration Mode") {
                        bluetoothManager.celebrationMode()
                    }
                    .buttonStyle(ActionButtonStyle(color: .green))
                    
                    Button("Reset Count") {
                        bluetoothManager.shotCount = 0
                    }
                    .buttonStyle(ActionButtonStyle(color: .orange))
                }
                
                Button("Disconnect") {
                    bluetoothManager.disconnect()
                }
                .buttonStyle(ActionButtonStyle(color: .red))
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Shot Statistics
    private var shotStatsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Shot Statistics")
                .font(.headline)
            
            VStack(spacing: 10) {
                StatRow(title: "Total Shots", value: "\(bluetoothManager.shotCount)")
                
                if let lastShot = bluetoothManager.lastShotDetected {
                    StatRow(title: "Last Shot", value: timeAgoString(from: lastShot))
                } else {
                    StatRow(title: "Last Shot", value: "None")
                }
                
                StatRow(title: "Session", value: "Active")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Functions
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "RED": return .red
        case "GREEN": return .green
        case "BLUE": return .blue
        case "YELLOW": return .yellow
        case "PURPLE": return .purple
        case "CYAN": return .cyan
        case "WHITE": return .white
        default: return .gray
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Views

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct ActionButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("ESP32 Configuration")
                        .font(.headline)
                    
                    Text("Service UUID: 4fafc201-1fb5-459e-8fcc-c5c9c331914b")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("LED Control UUID: beb5483e-36e1-4688-b7f5-ea07361b26a8")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Shot Sensor UUID: beb5483e-36e1-4688-b7f5-ea07361b26a9")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                Text("Backyard Golf Pro v1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

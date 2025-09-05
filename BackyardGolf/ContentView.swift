//
//  ContentView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = ESP32BluetoothManager()
    @StateObject private var gameManager = GameManager()
    @StateObject private var videoRecorder = VideoRecorder()
    @StateObject private var socialManager = SocialMediaManager()
    
    @State private var showingSettings = false
    @State private var showingGameSetup = false
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
                    
                    // Game Mode Section
                    if gameManager.isGameActive {
                        activeGameView
                    } else {
                        gameSetupView
                    }
                    
                    // Video Recording Section (only in trick shot mode)
                    if gameManager.currentSession?.gameMode == .trickShot {
                        videoRecordingView
                    }
                    
                    // Control Panel (existing)
                    if bluetoothManager.isConnected {
                        controlPanelView
                    } else {
                        connectButtonView
                    }
                    
                    // Enhanced Shot Statistics
                    shotStatsView
                    
                    // Social Sharing Section
                    if gameManager.currentSession != nil {
                        socialSharingView
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Backyard Golf")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingGameSetup = true }) {
                        Image(systemName: "gamecontroller")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(bluetoothManager: bluetoothManager)
            }
            .sheet(isPresented: $showingGameSetup) {
                GameSetupView(gameManager: gameManager)
            }
            .sheet(isPresented: $gameManager.showingVideoShare) {
                if let videoURL = gameManager.lastTrickShotVideo {
                    VideoShareView(
                        videoURL: videoURL,
                        message: gameManager.socialManager.generateTrickShotMessage(
                            playerName: gameManager.currentUser.username,
                            points: 0
                        ),
                        socialManager: gameManager.socialManager
                    )
                }
            }
        }
    }

    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("🏌️‍♂️")
                .font(.system(size: 60))
            
            Text("Backyard Golf")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Smart Golf Chipping Companion")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(bluetoothManager.isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            Text(bluetoothManager.isConnected ? "Connected to Smart Hole" : "Disconnected")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if bluetoothManager.isConnected {
                Text("Signal: \(Int(bluetoothManager.signalStrength * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var gameSetupView: some View {
        VStack(spacing: 15) {
            Text("🎮 Game Modes")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(GameSession.GameMode.allCases, id: \.self) { mode in
                    GameModeButton(mode: mode) {
                        startQuickGame(mode: mode)
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var activeGameView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: gameManager.currentSession?.gameMode.icon ?? "target")
                    .foregroundColor(.green)
                
                Text(gameManager.currentSession?.gameMode.rawValue ?? "Game")
                    .font(.headline)
                
                Spacer()
                
                Button("End Game") {
                    gameManager.endGame()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .cornerRadius(8)
            }
            
            // Game stats
            if let session = gameManager.currentSession {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Players: \(session.players.count)")
                    Text("Round: \(session.currentRound)/\(session.maxRounds)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Shot buttons
            if bluetoothManager.isConnected {
                HStack(spacing: 10) {
                    Button("Record Shot") {
                        recordTestShot()
                    }
                    .buttonStyle(QuickActionButtonStyle(color: .green))
                    
                    Button("Simulate Shot") {
                        simulateShot()
                        bluetoothManager.celebrationMode()
                    }
                    .buttonStyle(QuickActionButtonStyle(color: .orange))
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var videoRecordingView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: videoRecorder.isRecording ? "video.fill" : "video.slash")
                    .foregroundColor(videoRecorder.isRecording ? .red : .gray)
                
                Text(videoRecorder.isRecording ? "Recording Trick Shot..." : "Ready to Record")
                    .font(.headline)
                    .foregroundColor(videoRecorder.isRecording ? .red : .primary)
                
                Spacer()
            }
            
            if videoRecorder.isRecording {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(0.8)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: videoRecorder.isRecording)
                    
                    Text("Tap to stop recording when shot is complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // Recording Controls
            HStack(spacing: 15) {
                if !videoRecorder.isRecording {
                    Button("Start Recording") {
                        gameManager.startTrickShotRecording()
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                } else {
                    Button("Stop Recording") {
                        gameManager.stopTrickShotRecording()
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var controlPanelView: some View {
        VStack(spacing: 15) {
            Text("🎛️ LED Control")
                .font(.headline)
            
            // Color Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                            bluetoothManager.setLEDColor(color)
                        }) {
                            Text(color)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedColor == color ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedColor == color ? Color.blue : Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Pattern Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Pattern")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(patterns, id: \.self) { pattern in
                        Button(action: {
                            selectedPattern = pattern
                            bluetoothManager.setLEDPattern(pattern)
                        }) {
                            Text(pattern)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedPattern == pattern ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedPattern == pattern ? Color.blue : Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Quick Actions
            HStack(spacing: 10) {
                Button("Celebration") {
                    bluetoothManager.celebrationMode()
                }
                .buttonStyle(QuickActionButtonStyle(color: .orange))
                
                Button("Turn Off") {
                    bluetoothManager.turnOffLED()
                }
                .buttonStyle(QuickActionButtonStyle(color: .red))
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var connectButtonView: some View {
        VStack(spacing: 15) {
            Text("🔌 Connect to Smart Hole")
                .font(.headline)
            
            Button(action: {
                bluetoothManager.startScanning()
            }) {
                HStack {
                    Image(systemName: "wifi")
                    Text("Scan for Devices")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var shotStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Recent Shots")
                .font(.headline)
            
            if gameManager.recentShots.isEmpty {
                Text("No shots recorded yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(gameManager.recentShots.prefix(3)) { shot in
                    HStack {
                        Circle()
                            .fill(shot.points > 0 ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text("\(shot.points) points")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(shot.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var socialSharingView: some View {
        VStack(spacing: 12) {
            Text("📱 Social Sharing")
                .font(.headline)
            
            HStack(spacing: 10) {
                Button("Share Score") {
                    shareCurrentScore()
                }
                .buttonStyle(QuickActionButtonStyle(color: .blue))
                
                Button("Share Achievement") {
                    shareAchievement()
                }
                .buttonStyle(QuickActionButtonStyle(color: .purple))
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Functions
    
    private func startQuickGame(mode: GameSession.GameMode) {
        let defaultPlayer = Player(
            id: gameManager.currentUser.id,
            username: gameManager.currentUser.username,
            avatar: "person.circle.fill",
            stats: PlayerStats()
        )
        gameManager.startGame(mode: mode, players: [defaultPlayer])
        
        if bluetoothManager.isConnected {
            bluetoothManager.setLEDColor("GREEN")
            bluetoothManager.setLEDPattern("FLASH")
        }
    }
    
    private func recordTestShot() {
        guard let session = gameManager.currentSession,
              let player = session.players.first else { return }
        
        let target = Target(
            id: UUID().uuidString,
            name: "Center Target",
            points: 10,
            position: CGPoint(x: 0.5, y: 0.5),
            radius: 0.1
        )
        
        let distance = Double.random(in: 15...35)
        gameManager.recordShot(for: player, target: target, distance: distance)
        bluetoothManager.celebrationMode()
    }
    
    private func simulateShot() {
        // Simulate a successful shot
        if gameManager.currentSession != nil {
            recordTestShot()
        }
    }
    
    private func shareCurrentScore() {
        guard let session = gameManager.currentSession else { return }
        
        let totalPoints = session.players.first?.stats.totalPoints ?? 0
        let message = socialManager.generateTrickShotMessage(
            playerName: gameManager.currentUser.username,
            points: totalPoints
        )
        
        // Create a simple share sheet
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
    
    private func shareAchievement() {
        let message = socialManager.generateAchievementMessage(
            playerName: gameManager.currentUser.username,
            achievement: "First Shot!"
        )
        
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

// MARK: - Supporting Views

struct GameModeButton: View {
    let mode: GameSession.GameMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct QuickActionButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var bluetoothManager: ESP32BluetoothManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Bluetooth Settings and Device Management")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Game Setup View

struct GameSetupView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Game Setup")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Configure your game session")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Game Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

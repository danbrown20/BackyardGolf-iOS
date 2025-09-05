//
//  GameView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameManager = GameManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Game Tab
            MainGameView(gameManager: gameManager)
                .tabItem {
                    Image(systemName: "target")
                    Text("Game")
                }
                .tag(0)
            
            // LED Control Tab
            LEDControlView(gameManager: gameManager)
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("LED Control")
                }
                .tag(1)
            
            // Competitions Tab
            CompetitionsView(gameManager: gameManager)
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Competitions")
                }
                .tag(2)
            
            // Prizes Tab
            PrizeGalleryView(prizeManager: gameManager.prizeManager)
                .tabItem {
                    Image(systemName: "gift.fill")
                    Text("Prizes")
                }
                .tag(3)
            
            // Leaderboard Tab
            LeaderboardView(gameManager: gameManager)
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Leaderboard")
                }
                .tag(4)
            
            // Social Tab
            SocialView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Social")
                }
                .tag(5)
            
            // Profile Tab
            ProfileView(gameManager: gameManager)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(6)
        }
        .accentColor(.green)
        .overlay(
            // Achievement notification overlay
            Group {
                if gameManager.achievementManager.showingAchievementNotification,
                   let achievement = gameManager.achievementManager.currentNotificationAchievement {
                    VStack {
                        AchievementNotificationView(achievement: achievement)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: gameManager.achievementManager.showingAchievementNotification)
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                }
            }
        )
    }
}

// MARK: - Main Game View

struct MainGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showingGameModeSelection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Connection Status
                ConnectionStatusView(gameManager: gameManager)
                
                // Smart Hole Status
                SmartHoleStatusView(smartHole: gameManager.smartHole)
                
                // Video Recording Status (for Trick Shot mode)
                if gameManager.currentSession?.gameMode == .trickShot {
                    VideoRecordingStatusView(gameManager: gameManager)
                }
                
                Spacer()
                
                // Game Mode Selection
                VStack(spacing: 15) {
                    Text("Choose Your Game Mode")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(GameSession.GameMode.allCases, id: \.self) { mode in
                        GameModeButton(mode: mode) {
                            startGame(mode: mode)
                        }
                    }
                }
                
                Spacer()
                
                // Recent Shots
                if !gameManager.recentShots.isEmpty {
                    RecentShotsView(shots: gameManager.recentShots)
                }
            }
            .padding()
            .navigationTitle("Backyard Golf")
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
    
    private func startGame(mode: GameSession.GameMode) {
        let player = Player(
            id: gameManager.currentUser.id,
            username: gameManager.currentUser.username,
            avatar: gameManager.currentUser.avatar
        )
        gameManager.startGame(mode: mode, players: [player])
    }
}

// MARK: - Connection Status View

struct ConnectionStatusView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        HStack {
            Circle()
                .fill(gameManager.isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            Text(connectionStatusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if !gameManager.isConnected {
                Button("Connect") {
                    gameManager.connectToSmartHole()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var connectionStatusText: String {
        switch gameManager.connectionStatus {
        case .disconnected:
            return "Smart Hole Disconnected"
        case .scanning:
            return "Scanning for Smart Hole..."
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Smart Hole Connected"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}

// MARK: - Smart Hole Status View

struct SmartHoleStatusView: View {
    let smartHole: SmartHole
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Smart Hole Status")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(smartHole.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("LED: \(smartHole.isLEDOn ? "ON" : "OFF")")
                    Text("Color: \(smartHole.ledColor.rawValue)")
                    Text("Battery: \(Int(smartHole.batteryLevel * 100))%")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                // LED Color Preview
                Circle()
                    .fill(smartHole.ledColor.color)
                    .frame(width: 30, height: 30)
                    .opacity(smartHole.isLEDOn ? smartHole.ledBrightness : 0.3)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Game Mode Button

struct GameModeButton: View {
    let mode: GameSession.GameMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Recent Shots View

struct RecentShotsView: View {
    let shots: [Shot]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Shots")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(shots.prefix(10), id: \.id) { shot in
                        ShotIndicatorView(shot: shot)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ShotIndicatorView: View {
    let shot: Shot
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: shot.isSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(shot.isSuccessful ? .green : .red)
                .font(.title2)
            
            Text(timeAgo)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: shot.timestamp, relativeTo: Date())
    }
}

// MARK: - Video Recording Status View

struct VideoRecordingStatusView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: gameManager.videoRecorder.isRecording ? "video.fill" : "video.slash")
                    .foregroundColor(gameManager.videoRecorder.isRecording ? .red : .gray)
                
                Text(gameManager.videoRecorder.isRecording ? "Recording Trick Shot..." : "Ready to Record")
                    .font(.headline)
                    .foregroundColor(gameManager.videoRecorder.isRecording ? .red : .primary)
                
                Spacer()
            }
            
            if gameManager.videoRecorder.isRecording {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(0.8)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: gameManager.videoRecorder.isRecording)
                    
                    Text("Tap to stop recording when shot is complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // Recording Controls
            HStack(spacing: 15) {
                if !gameManager.videoRecorder.isRecording {
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
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    GameView()
}

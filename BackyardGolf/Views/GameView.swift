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
            
            // Leaderboard Tab
            LeaderboardView(gameManager: gameManager)
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Leaderboard")
                }
                .tag(3)
            
            // Profile Tab
            ProfileView(gameManager: gameManager)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.green)
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
            HStack {
                VStack(alignment: .leading) {
                    Text(mode.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(modeDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private var modeDescription: String {
        switch mode {
        case .practice:
            return "Practice your chipping skills"
        case .quickMatch:
            return "Quick 5-minute games"
        case .tournament:
            return "Competitive tournaments"
        case .challenge:
            return "Challenge friends"
        case .party:
            return "Fun party games"
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

#Preview {
    GameView()
}

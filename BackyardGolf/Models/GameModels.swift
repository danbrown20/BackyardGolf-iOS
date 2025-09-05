//
//  GameModels.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI
import Foundation
import CoreBluetooth

// MARK: - Hardware Models

struct SmartHole {
    let id: String
    var isConnected: Bool = false
    var ledColor: LEDColor = .white
    var ledBrightness: Double = 1.0
    var isLEDOn: Bool = true
    var batteryLevel: Double = 1.0
    var signalStrength: Double = 1.0
    
    enum LEDColor: String, CaseIterable {
        case red = "Red"
        case green = "Green"
        case blue = "Blue"
        case yellow = "Yellow"
        case purple = "Purple"
        case orange = "Orange"
        case white = "White"
        case rainbow = "Rainbow"
        
        var color: Color {
            switch self {
            case .red: return .red
            case .green: return .green
            case .blue: return .blue
            case .yellow: return .yellow
            case .purple: return .purple
            case .orange: return .orange
            case .white: return .white
            case .rainbow: return .white // Will be handled specially
            }
        }
    }
}

// MARK: - Game Models

struct GameSession {
    let id: String
    let gameMode: GameMode
    var players: [Player]
    let startTime: Date
    var endTime: Date?
    var isActive: Bool = true
    var currentRound: Int = 1
    var maxRounds: Int = 10
    
    enum GameMode: String, CaseIterable {
        case practice = "Practice"
        case quickMatch = "Quick Match"
        case tournament = "Tournament"
        case challenge = "Challenge"
        case party = "Party Mode"
    }
}

struct Player {
    let id: String
    let username: String
    let avatar: String
    var score: Int = 0
    var successfulShots: Int = 0
    var totalShots: Int = 0
    var accuracy: Double = 0.0
    var isOnline: Bool = true
    var rank: Int = 0
}

struct Shot {
    let id: String
    let playerId: String
    let timestamp: Date
    let isSuccessful: Bool
    let distance: Double?
    let power: Double?
    let angle: Double?
}

struct Competition {
    let id: String
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let entryFee: Double
    let prizePool: Double
    let maxParticipants: Int
    var participants: [Player] = []
    var isActive: Bool = true
    let gameMode: GameSession.GameMode
}

struct Prize {
    let id: String
    let name: String
    let description: String
    let value: Double
    let imageURL: String?
    let isClaimed: Bool = false
}

// MARK: - Social Models

struct UserProfile {
    let id: String
    let username: String
    let email: String
    let avatar: String
    var totalGamesPlayed: Int = 0
    var totalShots: Int = 0
    var successfulShots: Int = 0
    var bestAccuracy: Double = 0.0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var level: Int = 1
    var experience: Int = 0
    var friends: [String] = []
    var achievements: [Achievement] = []
    var isOnline: Bool = false
    var lastActive: Date = Date()
}

struct Achievement {
    let id: String
    let name: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    let rarity: AchievementRarity
    
    enum AchievementRarity: String, CaseIterable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
    }
}

struct LeaderboardEntry {
    let player: Player
    let rank: Int
    let score: Int
    let accuracy: Double
    let gamesPlayed: Int
}

// MARK: - Game State

class GameManager: ObservableObject {
    @Published var smartHole: SmartHole
    @Published var currentSession: GameSession?
    @Published var currentUser: UserProfile
    @Published var isConnected: Bool = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var recentShots: [Shot] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var activeCompetitions: [Competition] = []
    @Published var friends: [UserProfile] = []
    
    enum ConnectionStatus {
        case disconnected
        case scanning
        case connecting
        case connected
        case error(String)
    }
    
    init() {
        self.smartHole = SmartHole(id: "default-hole")
        self.currentUser = UserProfile(
            id: "user-1",
            username: "Player",
            email: "player@example.com",
            avatar: "person.circle.fill"
        )
        
        setupMockData()
    }
    
    private func setupMockData() {
        // Mock leaderboard data
        leaderboard = [
            LeaderboardEntry(
                player: Player(id: "1", username: "ProGolfer", avatar: "person.circle.fill"),
                rank: 1,
                score: 95,
                accuracy: 0.87,
                gamesPlayed: 45
            ),
            LeaderboardEntry(
                player: Player(id: "2", username: "ChipMaster", avatar: "person.circle.fill"),
                rank: 2,
                score: 89,
                accuracy: 0.82,
                gamesPlayed: 38
            ),
            LeaderboardEntry(
                player: Player(id: "3", username: "BackyardKing", avatar: "person.circle.fill"),
                rank: 3,
                score: 84,
                accuracy: 0.79,
                gamesPlayed: 52
            )
        ]
        
        // Mock competitions
        activeCompetitions = [
            Competition(
                id: "comp-1",
                name: "Weekend Warriors",
                description: "Weekly tournament for all skill levels",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                entryFee: 5.0,
                prizePool: 100.0,
                maxParticipants: 20,
                gameMode: .tournament
            )
        ]
    }
    
    // MARK: - Hardware Control
    
    func connectToSmartHole() {
        connectionStatus = .scanning
        // Simulate connection process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connectionStatus = .connected
            self.isConnected = true
            self.smartHole.isConnected = true
        }
    }
    
    func disconnectFromSmartHole() {
        connectionStatus = .disconnected
        isConnected = false
        smartHole.isConnected = false
    }
    
    func setLEDColor(_ color: SmartHole.LEDColor) {
        smartHole.ledColor = color
        // Send command to hardware
        sendLEDCommand()
    }
    
    func setLEDBrightness(_ brightness: Double) {
        smartHole.ledBrightness = max(0, min(1, brightness))
        // Send command to hardware
        sendLEDCommand()
    }
    
    func toggleLED() {
        smartHole.isLEDOn.toggle()
        // Send command to hardware
        sendLEDCommand()
    }
    
    private func sendLEDCommand() {
        // This would send the actual Bluetooth/UWB command to the hardware
        print("Sending LED command: Color=\(smartHole.ledColor), Brightness=\(smartHole.ledBrightness), On=\(smartHole.isLEDOn)")
    }
    
    // MARK: - Game Management
    
    func startGame(mode: GameSession.GameMode, players: [Player]) {
        let session = GameSession(
            id: UUID().uuidString,
            gameMode: mode,
            players: players,
            startTime: Date()
        )
        currentSession = session
    }
    
    func endGame() {
        currentSession?.isActive = false
        currentSession?.endTime = Date()
        currentSession = nil
    }
    
    func recordShot(playerId: String, isSuccessful: Bool, distance: Double? = nil, power: Double? = nil, angle: Double? = nil) {
        let shot = Shot(
            id: UUID().uuidString,
            playerId: playerId,
            timestamp: Date(),
            isSuccessful: isSuccessful,
            distance: distance,
            power: power,
            angle: angle
        )
        
        recentShots.insert(shot, at: 0)
        if recentShots.count > 50 {
            recentShots.removeLast()
        }
        
        // Update player stats
        if let playerIndex = currentSession?.players.firstIndex(where: { $0.id == playerId }) {
            currentSession?.players[playerIndex].totalShots += 1
            if isSuccessful {
                currentSession?.players[playerIndex].successfulShots += 1
                currentSession?.players[playerIndex].score += 10
            }
            
            let player = currentSession?.players[playerIndex]
            currentSession?.players[playerIndex].accuracy = Double(player?.successfulShots ?? 0) / Double(player?.totalShots ?? 1)
        }
    }
    
    // MARK: - Social Features
    
    func joinCompetition(_ competition: Competition) {
        if !competition.participants.contains(where: { $0.id == currentUser.id }) {
            var updatedCompetition = competition
            let player = Player(
                id: currentUser.id,
                username: currentUser.username,
                avatar: currentUser.avatar
            )
            updatedCompetition.participants.append(player)
            
            if let index = activeCompetitions.firstIndex(where: { $0.id == competition.id }) {
                activeCompetitions[index] = updatedCompetition
            }
        }
    }
    
    func addFriend(_ user: UserProfile) {
        if !currentUser.friends.contains(user.id) {
            currentUser.friends.append(user.id)
            friends.append(user)
        }
    }
}

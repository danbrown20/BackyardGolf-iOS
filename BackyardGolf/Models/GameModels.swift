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
        case trickShot = "Trick Shot"
        
        var icon: String {
            switch self {
            case .practice: return "figure.golf"
            case .quickMatch: return "bolt"
            case .tournament: return "trophy"
            case .challenge: return "target"
            case .party: return "person.2"
            case .trickShot: return "video"
            }
        }
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
    var stats: PlayerStats = PlayerStats()
}

struct Target {
    let id: String
    let name: String
    let points: Int
    let position: CGPoint
    let radius: Double
}

struct PlayerStats {
    var totalShots: Int = 0
    var totalPoints: Int = 0
    var gamesPlayed: Int = 0
    var averageAccuracy: Double = 0
    var bestScore: Int = 0
    var longestShot: Double = 0
}

struct Shot: Identifiable {
    let id: String
    let playerId: String
    let targetId: String
    let timestamp: Date
    let isSuccessful: Bool
    let distance: Double?
    let power: Double?
    let angle: Double?
    let points: Int
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

struct UserProfile: Identifiable {
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
    
    // Achievement tracking properties
    var longestShot: Double? = nil
    var bestScore: Int = 0
    var tournamentWins: Int = 0
    var trickShotsCompleted: Int = 0
    var challengesCompleted: Int = 0
    var friendsCount: Int = 0
    var challengesCreated: Int = 0
    var videosShared: Int = 0
}

struct Achievement {
    let id: String
    let name: String
    let description: String
    let icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    let rarity: AchievementRarity
    let category: AchievementCategory
    let requirements: AchievementRequirement
    var progress: Int = 0
    
    enum AchievementRarity: String, CaseIterable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
        
        var glowColor: Color {
            switch self {
            case .common: return .clear
            case .rare: return .blue.opacity(0.3)
            case .epic: return .purple.opacity(0.4)
            case .legendary: return .orange.opacity(0.5)
            }
        }
    }
    
    enum AchievementCategory: String, CaseIterable {
        case beginner = "Beginner"
        case accuracy = "Accuracy"
        case streak = "Streak"
        case distance = "Distance"
        case gameMode = "Game Mode"
        case social = "Social"
        case milestone = "Milestone"
        case dedication = "Dedication"
        
        var icon: String {
            switch self {
            case .beginner: return "star.fill"
            case .accuracy: return "scope"
            case .streak: return "flame.fill"
            case .distance: return "arrow.up.right"
            case .gameMode: return "gamecontroller.fill"
            case .social: return "person.2.fill"
            case .milestone: return "trophy.fill"
            case .dedication: return "heart.fill"
            }
        }
    }
}

struct AchievementRequirement {
    let type: RequirementType
    let target: Int
    
    enum RequirementType {
        case totalShots
        case successfulShots
        case currentStreak
        case longestShot
        case singleGameAccuracy
        case singleGameScore
        case gamesPlayed
        case tournamentWins
        case trickShotsCompleted
        case challengesCompleted
        case friendsCount
        case challengesCreated
        case videosShared
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
    @Published var isGameActive: Bool = false
    
    // Video and Social Features
    @Published var videoRecorder = VideoRecorder()
    @Published var socialManager = SocialMediaManager()
    @Published var showingVideoShare = false
    @Published var lastTrickShotVideo: URL?
    
    // Achievement System
    @Published var achievementManager = AchievementManager()
    
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
        
        // Initialize achievement manager with current user
        achievementManager.updateUserProfile(currentUser)
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
        isGameActive = true
        print("🎮 Started \(mode.rawValue) game with \(players.count) players")
    }
    
    func endGame() {
        // Calculate final score and accuracy for achievement tracking
        if let session = currentSession {
            let totalScore = session.players.reduce(0) { $0 + $1.score }
            let accuracy = session.players.isEmpty ? 0.0 : Double(session.players.reduce(0) { $0 + $1.successfulShots }) / Double(session.players.reduce(0) { $0 + $1.totalShots })
            
            // Update user stats
            currentUser.totalGamesPlayed += 1
            currentUser.experience += totalScore / 10
            if totalScore > currentUser.bestScore {
                currentUser.bestScore = totalScore
            }
            
            // Record game completion for achievements
            achievementManager.recordGameCompleted(
                score: totalScore,
                accuracy: accuracy * 100,
                gameMode: session.gameMode
            )
        }
        
        currentSession?.isActive = false
        currentSession?.endTime = Date()
        currentSession = nil
        isGameActive = false
        print("🏁 Game ended")
    }
    
    func recordShot(playerId: String, isSuccessful: Bool, distance: Double? = nil, power: Double? = nil, angle: Double? = nil) {
        let shot = Shot(
            id: UUID().uuidString,
            playerId: playerId,
            targetId: "default",
            timestamp: Date(),
            isSuccessful: isSuccessful,
            distance: distance,
            power: power,
            angle: angle,
            points: isSuccessful ? 10 : 0
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
        
        // Update current user stats and achievement progress
        currentUser.totalShots += 1
        if isSuccessful {
            currentUser.successfulShots += 1
            currentUser.currentStreak += 1
            if let distance = distance, distance > (currentUser.longestShot ?? 0) {
                currentUser.longestShot = distance
            }
        } else {
            currentUser.currentStreak = 0
        }
        
        if currentUser.currentStreak > currentUser.longestStreak {
            currentUser.longestStreak = currentUser.currentStreak
        }
        
        currentUser.bestAccuracy = max(currentUser.bestAccuracy, Double(currentUser.successfulShots) / Double(currentUser.totalShots))
        
        // Update achievement manager
        achievementManager.recordShot(
            isSuccessful: isSuccessful,
            distance: distance,
            gameMode: currentSession?.gameMode
        )
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
    
    // MARK: - Video Recording Features
    
    func startTrickShotRecording() {
        guard currentSession?.gameMode == .trickShot else { return }
        videoRecorder.startRecording()
        print("🎬 Started recording for trick shot mode")
    }
    
    func stopTrickShotRecording() {
        videoRecorder.stopRecording()
        print("⏹️ Stopped recording for trick shot")
    }
    
    func handleTrickShotSuccess(player: Player, points: Int) {
        // Stop recording and prepare for sharing
        stopTrickShotRecording()
        
        // Wait a moment for video to be processed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let videoURL = self.videoRecorder.lastVideoURL {
                self.lastTrickShotVideo = videoURL
                self.showingVideoShare = true
                
                // Generate share message
                let message = self.socialManager.generateTrickShotMessage(
                    playerName: player.username,
                    points: points
                )
                
                print("🎯 Trick shot success! Video ready for sharing: \(message)")
            }
        }
    }
    
    func shareTrickShot() {
        guard let videoURL = lastTrickShotVideo else { return }
        
        let message = socialManager.generateTrickShotMessage(
            playerName: currentUser.username,
            points: 0 // You can pass actual points here
        )
        
        socialManager.shareVideo(url: videoURL, message: message, from: nil)
        showingVideoShare = false
    }
    
    // MARK: - Enhanced Game Management Methods
    
    func recordShot(for player: Player, target: Target, distance: Double) {
        let shot = Shot(
            id: UUID().uuidString,
            playerId: player.id,
            targetId: target.id,
            timestamp: Date(),
            isSuccessful: true,
            distance: distance,
            power: nil,
            angle: nil,
            points: target.points
        )
        
        recentShots.insert(shot, at: 0)
        if recentShots.count > 10 {
            recentShots.removeLast()
        }
        
        // Update player stats
        if let index = currentSession?.players.firstIndex(where: { $0.id == player.id }) {
            currentSession?.players[index].stats.totalShots += 1
            currentSession?.players[index].stats.totalPoints += shot.points
            if distance > currentSession?.players[index].stats.longestShot ?? 0 {
                currentSession?.players[index].stats.longestShot = distance
            }
        }
        
        print("🏌️ Shot recorded: \(player.username) scored \(shot.points) points")
    }
}

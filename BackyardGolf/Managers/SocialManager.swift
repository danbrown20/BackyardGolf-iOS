//
//  SocialManager.swift
//  BackyardGolf
//
//  Created by Dan on 9/5/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Social Manager

class SocialManager: ObservableObject {
    @Published var friends: [UserProfile] = []
    @Published var pendingFriendRequests: [FriendRequest] = []
    @Published var activeChallenges: [Challenge] = []
    @Published var globalLeaderboard: [LeaderboardEntry] = []
    @Published var recentActivity: [Activity] = []
    @Published var isConnected: Bool = false
    @Published var connectionStatus: String = "Disconnected"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
        simulateRealTimeUpdates()
    }
    
    // MARK: - Friend Management
    
    func sendFriendRequest(to user: UserProfile) {
        let request = FriendRequest(
            id: UUID().uuidString,
            fromUser: getCurrentUser(),
            toUser: user,
            timestamp: Date(),
            status: .pending
        )
        
        // Simulate sending request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.pendingFriendRequests.append(request)
            print("📤 Friend request sent to \(user.username)")
        }
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        if let index = pendingFriendRequests.firstIndex(where: { $0.id == request.id }) {
            pendingFriendRequests.remove(at: index)
            friends.append(request.fromUser)
            print("✅ Accepted friend request from \(request.fromUser.username)")
        }
    }
    
    func declineFriendRequest(_ request: FriendRequest) {
        if let index = pendingFriendRequests.firstIndex(where: { $0.id == request.id }) {
            pendingFriendRequests.remove(at: index)
            print("❌ Declined friend request from \(request.fromUser.username)")
        }
    }
    
    // MARK: - Challenge System
    
    func createChallenge(to friend: UserProfile, gameMode: GameSession.GameMode, target: Int) {
        let challenge = Challenge(
            id: UUID().uuidString,
            fromUser: getCurrentUser(),
            toUser: friend,
            gameMode: gameMode,
            target: target,
            status: .pending,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(24 * 60 * 60) // 24 hours
        )
        
        activeChallenges.append(challenge)
        print("🎯 Challenge created: \(gameMode.rawValue) - Target: \(target) points")
    }
    
    func acceptChallenge(_ challenge: Challenge) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].status = .accepted
            print("✅ Challenge accepted from \(challenge.fromUser.username)")
        }
    }
    
    func completeChallenge(_ challenge: Challenge, score: Int) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallenges[index].status = .completed
            activeChallenges[index].finalScore = score
            activeChallenges[index].completedAt = Date()
            
            // Add to activity feed
            let activity = Activity(
                id: UUID().uuidString,
                type: .challengeCompleted,
                user: getCurrentUser(),
                message: "Completed \(challenge.gameMode.rawValue) challenge with \(score) points!",
                timestamp: Date(),
                challenge: challenge
            )
            recentActivity.insert(activity, at: 0)
            
            print("🏆 Challenge completed with \(score) points!")
        }
    }
    
    // MARK: - Leaderboard
    
    func updateLeaderboard() {
        // Simulate leaderboard updates
        let mockEntries = [
            LeaderboardEntry(
                player: Player(id: "1", username: "GolfPro2024", avatar: "person.circle.fill"),
                rank: 1,
                score: 1250,
                accuracy: 0.85,
                gamesPlayed: 45
            ),
            LeaderboardEntry(
                player: Player(id: "2", username: "ChipMaster", avatar: "person.circle.fill"),
                rank: 2,
                score: 1180,
                accuracy: 0.82,
                gamesPlayed: 38
            ),
            LeaderboardEntry(
                player: Player(id: "3", username: "BackyardKing", avatar: "person.circle.fill"),
                rank: 3,
                score: 1100,
                accuracy: 0.80,
                gamesPlayed: 42
            ),
            LeaderboardEntry(
                player: Player(id: "current", username: "You", avatar: "person.circle.fill"),
                rank: 4,
                score: 950,
                accuracy: 0.75,
                gamesPlayed: 28
            ),
            LeaderboardEntry(
                player: Player(id: "5", username: "TrickShotQueen", avatar: "person.circle.fill"),
                rank: 5,
                score: 890,
                accuracy: 0.78,
                gamesPlayed: 35
            )
        ]
        
        globalLeaderboard = mockEntries
    }
    
    // MARK: - Activity Feed
    
    func addActivity(_ activity: Activity) {
        recentActivity.insert(activity, at: 0)
        if recentActivity.count > 50 {
            recentActivity.removeLast()
        }
    }
    
    // MARK: - Mock Data & Simulation
    
    private func loadMockData() {
        // Mock friends
        friends = [
            UserProfile(id: "friend1", username: "GolfBuddy", email: "golfbuddy@example.com", avatar: "person.circle.fill"),
            UserProfile(id: "friend2", username: "ChipChamp", email: "chipchamp@example.com", avatar: "person.circle.fill"),
            UserProfile(id: "friend3", username: "BackyardPro", email: "backyardpro@example.com", avatar: "person.circle.fill")
        ]
        
        // Mock pending requests
        pendingFriendRequests = [
            FriendRequest(
                id: "req1",
                fromUser: UserProfile(id: "new1", username: "NewPlayer", email: "newplayer@example.com", avatar: "person.circle.fill"),
                toUser: getCurrentUser(),
                timestamp: Date().addingTimeInterval(-3600),
                status: .pending
            )
        ]
        
        // Mock challenges
        activeChallenges = [
            Challenge(
                id: "challenge1",
                fromUser: friends[0],
                toUser: getCurrentUser(),
                gameMode: .tournament,
                target: 100,
                status: .pending,
                createdAt: Date().addingTimeInterval(-1800),
                expiresAt: Date().addingTimeInterval(22 * 60 * 60)
            )
        ]
        
        // Mock activity
        recentActivity = [
            Activity(
                id: "act1",
                type: .achievementUnlocked,
                user: friends[0],
                message: "GolfBuddy unlocked the 'Perfect Shot' achievement!",
                timestamp: Date().addingTimeInterval(-300)
            ),
            Activity(
                id: "act2",
                type: .highScore,
                user: friends[1],
                message: "ChipChamp set a new high score: 150 points!",
                timestamp: Date().addingTimeInterval(-600)
            )
        ]
        
        updateLeaderboard()
    }
    
    private func simulateRealTimeUpdates() {
        // Simulate real-time friend activity
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.simulateRandomActivity()
            }
            .store(in: &cancellables)
    }
    
    private func simulateRandomActivity() {
        let activities = [
            "just completed a trick shot challenge!",
            "unlocked a new achievement!",
            "set a new personal best!",
            "shared an amazing trick shot video!"
        ]
        
        if let randomFriend = friends.randomElement(),
           let randomActivity = activities.randomElement() {
            let activity = Activity(
                id: UUID().uuidString,
                type: .friendActivity,
                user: randomFriend,
                message: "\(randomFriend.username) \(randomActivity)",
                timestamp: Date()
            )
            addActivity(activity)
        }
    }
    
    private func getCurrentUser() -> UserProfile {
        return UserProfile(id: "current", username: "You", email: "you@example.com", avatar: "person.circle.fill")
    }
}

// MARK: - Social Models

// Using existing UserProfile from GameModels.swift

struct FriendRequest: Identifiable {
    let id: String
    let fromUser: UserProfile
    let toUser: UserProfile
    let timestamp: Date
    var status: RequestStatus
    
    enum RequestStatus: String, CaseIterable {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
    }
}

struct Challenge: Identifiable {
    let id: String
    let fromUser: UserProfile
    let toUser: UserProfile
    let gameMode: GameSession.GameMode
    let target: Int
    var status: ChallengeStatus
    let createdAt: Date
    let expiresAt: Date
    var finalScore: Int?
    var completedAt: Date?
    
    enum ChallengeStatus: String, CaseIterable {
        case pending = "Pending"
        case accepted = "Accepted"
        case completed = "Completed"
        case expired = "Expired"
    }
    
    var isExpired: Bool {
        return Date() > expiresAt && status != .completed
    }
}

struct Activity: Identifiable {
    let id: String
    let type: ActivityType
    let user: UserProfile
    let message: String
    let timestamp: Date
    var challenge: Challenge?
    var videoURL: URL?
    
    enum ActivityType: String, CaseIterable {
        case friendActivity = "Friend Activity"
        case achievementUnlocked = "Achievement"
        case highScore = "High Score"
        case challengeCompleted = "Challenge"
        case videoShared = "Video Shared"
        case friendRequest = "Friend Request"
    }
}

// Using existing LeaderboardEntry from GameModels.swift

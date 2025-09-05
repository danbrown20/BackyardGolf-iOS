//
//  AchievementManager.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import Foundation
import SwiftUI

// MARK: - Achievement Manager

class AchievementManager: ObservableObject {
    @Published var allAchievements: [Achievement] = []
    @Published var unlockedAchievements: [Achievement] = []
    @Published var recentUnlocks: [Achievement] = []
    @Published var showingAchievementNotification = false
    @Published var currentNotificationAchievement: Achievement?
    
    private var userProfile: UserProfile?
    
    init() {
        loadAllAchievements()
    }
    
    // MARK: - Achievement Definitions
    
    private func loadAllAchievements() {
        allAchievements = [
            // MARK: - Beginner Achievements
            Achievement(
                id: "first_shot",
                name: "First Shot",
                description: "Take your very first shot",
                icon: "target",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .common,
                category: .beginner,
                requirements: AchievementRequirement(type: .totalShots, target: 1),
                progress: 0
            ),
            
            Achievement(
                id: "first_success",
                name: "Bullseye!",
                description: "Make your first successful shot",
                icon: "checkmark.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .common,
                category: .beginner,
                requirements: AchievementRequirement(type: .successfulShots, target: 1),
                progress: 0
            ),
            
            Achievement(
                id: "practice_makes_perfect",
                name: "Practice Makes Perfect",
                description: "Complete 10 practice shots",
                icon: "figure.golf",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .common,
                category: .beginner,
                requirements: AchievementRequirement(type: .totalShots, target: 10),
                progress: 0
            ),
            
            // MARK: - Accuracy Achievements
            Achievement(
                id: "sharpshooter",
                name: "Sharpshooter",
                description: "Achieve 80% accuracy in a single game",
                icon: "scope",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .accuracy,
                requirements: AchievementRequirement(type: .singleGameAccuracy, target: 80),
                progress: 0
            ),
            
            Achievement(
                id: "eagle_eye",
                name: "Eagle Eye",
                description: "Achieve 90% accuracy in a single game",
                icon: "eye.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .epic,
                category: .accuracy,
                requirements: AchievementRequirement(type: .singleGameAccuracy, target: 90),
                progress: 0
            ),
            
            Achievement(
                id: "perfect_game",
                name: "Perfect Game",
                description: "Achieve 100% accuracy in a single game",
                icon: "star.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .legendary,
                category: .accuracy,
                requirements: AchievementRequirement(type: .singleGameAccuracy, target: 100),
                progress: 0
            ),
            
            // MARK: - Streak Achievements
            Achievement(
                id: "hot_streak",
                name: "Hot Streak",
                description: "Make 5 successful shots in a row",
                icon: "flame.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .streak,
                requirements: AchievementRequirement(type: .currentStreak, target: 5),
                progress: 0
            ),
            
            Achievement(
                id: "on_fire",
                name: "On Fire!",
                description: "Make 10 successful shots in a row",
                icon: "flame.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .epic,
                category: .streak,
                requirements: AchievementRequirement(type: .currentStreak, target: 10),
                progress: 0
            ),
            
            Achievement(
                id: "unstoppable",
                name: "Unstoppable",
                description: "Make 20 successful shots in a row",
                icon: "bolt.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .legendary,
                category: .streak,
                requirements: AchievementRequirement(type: .currentStreak, target: 20),
                progress: 0
            ),
            
            // MARK: - Distance Achievements
            Achievement(
                id: "long_drive",
                name: "Long Drive",
                description: "Make a shot from 30+ feet",
                icon: "arrow.up.right",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .distance,
                requirements: AchievementRequirement(type: .longestShot, target: 30),
                progress: 0
            ),
            
            Achievement(
                id: "power_shot",
                name: "Power Shot",
                description: "Make a shot from 50+ feet",
                icon: "bolt.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .epic,
                category: .distance,
                requirements: AchievementRequirement(type: .longestShot, target: 50),
                progress: 0
            ),
            
            Achievement(
                id: "legendary_distance",
                name: "Legendary Distance",
                description: "Make a shot from 75+ feet",
                icon: "arrow.up.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .legendary,
                category: .distance,
                requirements: AchievementRequirement(type: .longestShot, target: 75),
                progress: 0
            ),
            
            // MARK: - Game Mode Achievements
            Achievement(
                id: "tournament_champion",
                name: "Tournament Champion",
                description: "Win your first tournament",
                icon: "trophy.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .epic,
                category: .gameMode,
                requirements: AchievementRequirement(type: .tournamentWins, target: 1),
                progress: 0
            ),
            
            Achievement(
                id: "trick_shot_master",
                name: "Trick Shot Master",
                description: "Complete 10 trick shots",
                icon: "video.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .gameMode,
                requirements: AchievementRequirement(type: .trickShotsCompleted, target: 10),
                progress: 0
            ),
            
            Achievement(
                id: "challenge_accepted",
                name: "Challenge Accepted",
                description: "Complete 5 daily challenges",
                icon: "target",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .gameMode,
                requirements: AchievementRequirement(type: .challengesCompleted, target: 5),
                progress: 0
            ),
            
            // MARK: - Social Achievements
            Achievement(
                id: "social_butterfly",
                name: "Social Butterfly",
                description: "Add 5 friends",
                icon: "person.2.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .social,
                requirements: AchievementRequirement(type: .friendsCount, target: 5),
                progress: 0
            ),
            
            Achievement(
                id: "challenge_creator",
                name: "Challenge Creator",
                description: "Create 10 challenges",
                icon: "plus.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .epic,
                category: .social,
                requirements: AchievementRequirement(type: .challengesCreated, target: 10),
                progress: 0
            ),
            
            Achievement(
                id: "video_star",
                name: "Video Star",
                description: "Share 5 trick shot videos",
                icon: "video.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .social,
                requirements: AchievementRequirement(type: .videosShared, target: 5),
                progress: 0
            ),
            
            // MARK: - Milestone Achievements
            Achievement(
                id: "century_club",
                name: "Century Club",
                description: "Score 100+ points in a single game",
                icon: "100.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .milestone,
                requirements: AchievementRequirement(type: .singleGameScore, target: 100),
                progress: 0
            ),
            
            Achievement(
                id: "grand_master",
                name: "Grand Master",
                description: "Score 500+ points in a single game",
                icon: "500.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .epic,
                category: .milestone,
                requirements: AchievementRequirement(type: .singleGameScore, target: 500),
                progress: 0
            ),
            
            Achievement(
                id: "golf_legend",
                name: "Golf Legend",
                description: "Score 1000+ points in a single game",
                icon: "1000.circle.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .legendary,
                category: .milestone,
                requirements: AchievementRequirement(type: .singleGameScore, target: 1000),
                progress: 0
            ),
            
            // MARK: - Dedication Achievements
            Achievement(
                id: "dedicated_player",
                name: "Dedicated Player",
                description: "Play 50 games",
                icon: "gamecontroller.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .rare,
                category: .dedication,
                requirements: AchievementRequirement(type: .gamesPlayed, target: 50),
                progress: 0
            ),
            
            Achievement(
                id: "golf_enthusiast",
                name: "Golf Enthusiast",
                description: "Play 100 games",
                icon: "heart.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .epic,
                category: .dedication,
                requirements: AchievementRequirement(type: .gamesPlayed, target: 100),
                progress: 0
            ),
            
            Achievement(
                id: "backyard_legend",
                name: "Backyard Legend",
                description: "Play 500 games",
                icon: "crown.fill",
                isUnlocked: false,
                unlockedDate: nil,
                rarity: .legendary,
                category: .dedication,
                requirements: AchievementRequirement(type: .gamesPlayed, target: 500),
                progress: 0
            )
        ]
    }
    
    // MARK: - Achievement Tracking
    
    func updateUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
        updateAchievementProgress()
    }
    
    func recordShot(isSuccessful: Bool, distance: Double? = nil, gameMode: GameSession.GameMode? = nil) {
        guard var profile = userProfile else { return }
        
        profile.totalShots += 1
        if isSuccessful {
            profile.successfulShots += 1
            profile.currentStreak += 1
            if let distance = distance, distance > (profile.longestShot ?? 0) {
                profile.longestShot = distance
            }
        } else {
            profile.currentStreak = 0
        }
        
        if profile.currentStreak > profile.longestStreak {
            profile.longestStreak = profile.currentStreak
        }
        
        profile.bestAccuracy = max(profile.bestAccuracy, Double(profile.successfulShots) / Double(profile.totalShots))
        
        userProfile = profile
        updateAchievementProgress()
    }
    
    func recordGameCompleted(score: Int, accuracy: Double, gameMode: GameSession.GameMode) {
        guard var profile = userProfile else { return }
        
        profile.totalGamesPlayed += 1
        profile.experience += score / 10 // Experience based on score
        
        // Check for game mode specific achievements
        switch gameMode {
        case .tournament:
            if score > 0 { // Assuming positive score means win
                profile.tournamentWins += 1
            }
        case .trickShot:
            profile.trickShotsCompleted += 1
        case .challenge:
            profile.challengesCompleted += 1
        default:
            break
        }
        
        userProfile = profile
        updateAchievementProgress()
    }
    
    func recordSocialAction(type: SocialActionType) {
        guard var profile = userProfile else { return }
        
        switch type {
        case .friendAdded:
            profile.friendsCount += 1
        case .challengeCreated:
            profile.challengesCreated += 1
        case .videoShared:
            profile.videosShared += 1
        }
        
        userProfile = profile
        updateAchievementProgress()
    }
    
    private func updateAchievementProgress() {
        guard let profile = userProfile else { return }
        
        for i in 0..<allAchievements.count {
            let achievement = allAchievements[i]
            if !achievement.isUnlocked {
                let progress = calculateProgress(for: achievement, profile: profile)
                allAchievements[i].progress = progress
                
                if progress >= 100 {
                    unlockAchievement(at: i)
                }
            }
        }
    }
    
    private func calculateProgress(for achievement: Achievement, profile: UserProfile) -> Int {
        let requirement = achievement.requirements
        
        switch requirement.type {
        case .totalShots:
            return min(100, Int((Double(profile.totalShots) / Double(requirement.target)) * 100))
        case .successfulShots:
            return min(100, Int((Double(profile.successfulShots) / Double(requirement.target)) * 100))
        case .currentStreak:
            return min(100, Int((Double(profile.currentStreak) / Double(requirement.target)) * 100))
        case .longestShot:
            return min(100, Int(((profile.longestShot ?? 0) / Double(requirement.target)) * 100))
        case .singleGameAccuracy:
            return profile.bestAccuracy >= Double(requirement.target) ? 100 : 0
        case .singleGameScore:
            return profile.bestScore >= requirement.target ? 100 : 0
        case .gamesPlayed:
            return min(100, Int((Double(profile.totalGamesPlayed) / Double(requirement.target)) * 100))
        case .tournamentWins:
            return min(100, Int((Double(profile.tournamentWins) / Double(requirement.target)) * 100))
        case .trickShotsCompleted:
            return min(100, Int((Double(profile.trickShotsCompleted) / Double(requirement.target)) * 100))
        case .challengesCompleted:
            return min(100, Int((Double(profile.challengesCompleted) / Double(requirement.target)) * 100))
        case .friendsCount:
            return min(100, Int((Double(profile.friendsCount) / Double(requirement.target)) * 100))
        case .challengesCreated:
            return min(100, Int((Double(profile.challengesCreated) / Double(requirement.target)) * 100))
        case .videosShared:
            return min(100, Int((Double(profile.videosShared) / Double(requirement.target)) * 100))
        }
    }
    
    private func unlockAchievement(at index: Int) {
        var achievement = allAchievements[index]
        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        achievement.progress = 100
        
        allAchievements[index] = achievement
        unlockedAchievements.append(achievement)
        recentUnlocks.insert(achievement, at: 0)
        
        // Show notification
        currentNotificationAchievement = achievement
        showingAchievementNotification = true
        
        // Auto-hide notification after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showingAchievementNotification = false
        }
        
        print("🏆 Achievement Unlocked: \(achievement.name)")
    }
    
    // MARK: - Helper Methods
    
    func getAchievementsByCategory(_ category: Achievement.AchievementCategory) -> [Achievement] {
        return allAchievements.filter { $0.category == category }
    }
    
    func getUnlockedAchievementsByCategory(_ category: Achievement.AchievementCategory) -> [Achievement] {
        return unlockedAchievements.filter { $0.category == category }
    }
    
    func getAchievementProgress(_ achievement: Achievement) -> Double {
        return Double(achievement.progress) / 100.0
    }
    
    func getTotalUnlockedCount() -> Int {
        return unlockedAchievements.count
    }
    
    func getTotalAchievementCount() -> Int {
        return allAchievements.count
    }
    
    func getCompletionPercentage() -> Double {
        return Double(getTotalUnlockedCount()) / Double(getTotalAchievementCount())
    }
}

enum SocialActionType {
    case friendAdded
    case challengeCreated
    case videoShared
}

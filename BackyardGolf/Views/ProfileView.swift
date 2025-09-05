//
//  ProfileView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showingEditProfile = false
    @State private var showingAchievements = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeaderView(user: gameManager.currentUser)
                    
                    // Stats Overview
                    StatsOverviewView(user: gameManager.currentUser)
                    
                    // Achievements Preview
                    AchievementsPreviewView(
                        achievements: gameManager.currentUser.achievements,
                        showingAchievements: $showingAchievements
                    )
                    
                    // Friends Section
                    FriendsSectionView(friends: gameManager.friends)
                    
                    // Settings
                    SettingsSectionView(gameManager: gameManager)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(user: gameManager.currentUser)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(achievements: gameManager.currentUser.achievements)
            }
        }
    }
}

// MARK: - Profile Header

struct ProfileHeaderView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 15) {
            // Avatar and Basic Info
            HStack(spacing: 20) {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: user.avatar)
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Level \(user.level)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    // Experience Bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("XP: \(user.experience)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Next: \(user.experience + 100)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: Double(user.experience % 100), total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                }
                
                Spacer()
            }
            
            // Online Status
            HStack {
                Circle()
                    .fill(user.isOnline ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(user.isOnline ? "Online" : "Offline")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Last active: \(formatLastActive(user.lastActive))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func formatLastActive(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Stats Overview

struct StatsOverviewView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatCard(
                    title: "Games Played",
                    value: "\(user.totalGamesPlayed)",
                    icon: "gamecontroller",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Shots",
                    value: "\(user.totalShots)",
                    icon: "target",
                    color: .green
                )
                
                StatCard(
                    title: "Best Accuracy",
                    value: "\(Int(user.bestAccuracy * 100))%",
                    icon: "checkmark.circle",
                    color: .orange
                )
                
                StatCard(
                    title: "Longest Streak",
                    value: "\(user.longestStreak)",
                    icon: "flame",
                    color: .red
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Achievements Preview

struct AchievementsPreviewView: View {
    let achievements: [Achievement]
    @Binding var showingAchievements: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                
                Spacer()
                
                Button("View All") {
                    showingAchievements = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievements.prefix(5), id: \.id) { achievement in
                        AchievementBadgeView(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AchievementBadgeView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            Text(achievement.name)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 60, height: 60)
        .background(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
        .opacity(achievement.isUnlocked ? 1.0 : 0.5)
    }
}

// MARK: - Friends Section

struct FriendsSectionView: View {
    let friends: [UserProfile]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Friends")
                    .font(.headline)
                
                Spacer()
                
                Text("\(friends.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if friends.isEmpty {
                EmptyFriendsView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(friends.prefix(10), id: \.id) { friend in
                            FriendCardView(friend: friend)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct EmptyFriendsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.2")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("No friends yet")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Add friends to compete together!")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct FriendCardView: View {
    let friend: UserProfile
    
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: friend.avatar)
                        .font(.title3)
                        .foregroundColor(.blue)
                )
            
            Text(friend.username)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Circle()
                .fill(friend.isOnline ? Color.green : Color.gray)
                .frame(width: 6, height: 6)
        }
        .frame(width: 60)
    }
}

// MARK: - Settings Section

struct SettingsSectionView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Settings")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "bell",
                    title: "Notifications",
                    action: {}
                )
                
                SettingsRow(
                    icon: "gear",
                    title: "Game Settings",
                    action: {}
                )
                
                SettingsRow(
                    icon: "wifi",
                    title: "Connection Settings",
                    action: {}
                )
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    action: {}
                )
                
                SettingsRow(
                    icon: "info.circle",
                    title: "About",
                    action: {}
                )
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    let user: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save profile changes
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            username = user.username
            email = user.email
        }
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    let achievements: [Achievement]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(achievements, id: \.id) { achievement in
                        AchievementDetailView(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
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

struct AchievementDetailView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if achievement.isUnlocked, let date = achievement.unlockedDate {
                    Text("Unlocked: \(formatDate(date))")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Text(achievement.rarity.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(rarityColor.opacity(0.2))
                .foregroundColor(rarityColor)
                .cornerRadius(6)
        }
        .padding()
        .background(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
    
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ProfileView(gameManager: GameManager())
}

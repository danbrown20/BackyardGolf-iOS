//
//  LeaderboardView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedTimeframe: Timeframe = .allTime
    @State private var selectedCategory: Category = .score
    
    enum Timeframe: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case allTime = "All Time"
    }
    
    enum Category: String, CaseIterable {
        case score = "Score"
        case accuracy = "Accuracy"
        case gamesPlayed = "Games Played"
        case streak = "Streak"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Controls
                FilterControlsView(
                    selectedTimeframe: $selectedTimeframe,
                    selectedCategory: $selectedCategory
                )
                
                // Leaderboard Content
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Top 3 Podium
                        if !gameManager.leaderboard.isEmpty {
                            PodiumView(leaderboard: gameManager.leaderboard)
                        }
                        
                        // Full Leaderboard
                        ForEach(Array(gameManager.leaderboard.enumerated()), id: \.element.player.id) { index, entry in
                            LeaderboardRowView(
                                entry: entry,
                                rank: index + 1,
                                isCurrentUser: entry.player.id == gameManager.currentUser.id
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Leaderboard")
        }
    }
}

// MARK: - Filter Controls

struct FilterControlsView: View {
    @Binding var selectedTimeframe: LeaderboardView.Timeframe
    @Binding var selectedCategory: LeaderboardView.Category
    
    var body: some View {
        VStack(spacing: 12) {
            // Timeframe Picker
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(LeaderboardView.Timeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Category Picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(LeaderboardView.Category.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Podium View

struct PodiumView: View {
    let leaderboard: [LeaderboardEntry]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🏆 Top Players")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(alignment: .bottom, spacing: 20) {
                // 2nd Place
                if leaderboard.count > 1 {
                    PodiumPositionView(
                        entry: leaderboard[1],
                        rank: 2,
                        height: 60
                    )
                }
                
                // 1st Place
                if !leaderboard.isEmpty {
                    PodiumPositionView(
                        entry: leaderboard[0],
                        rank: 1,
                        height: 80
                    )
                }
                
                // 3rd Place
                if leaderboard.count > 2 {
                    PodiumPositionView(
                        entry: leaderboard[2],
                        rank: 3,
                        height: 40
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct PodiumPositionView: View {
    let entry: LeaderboardEntry
    let rank: Int
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            // Player Avatar
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: entry.player.avatar)
                        .font(.title2)
                        .foregroundColor(.blue)
                )
            
            // Player Name
            Text(entry.player.username)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            // Score
            Text("\(entry.score)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            // Podium Base
            Rectangle()
                .fill(podiumColor)
                .frame(width: 60, height: height)
                .overlay(
                    Text(rankText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
        }
    }
    
    private var podiumColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    private var rankText: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
}

// MARK: - Leaderboard Row View

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    let rank: Int
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            Text("\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(rankColor)
                .frame(width: 30, alignment: .center)
            
            // Player Avatar
            Circle()
                .fill(isCurrentUser ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: entry.player.avatar)
                        .font(.title3)
                        .foregroundColor(isCurrentUser ? .green : .blue)
                )
            
            // Player Info
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.player.username)
                    .font(.headline)
                    .fontWeight(isCurrentUser ? .bold : .medium)
                    .foregroundColor(isCurrentUser ? .green : .primary)
                
                Text("\(entry.gamesPlayed) games")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.score)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("\(Int(entry.accuracy * 100))% accuracy")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(isCurrentUser ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentUser ? Color.green : Color.clear, lineWidth: 2)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }
}

// MARK: - User Stats View

struct UserStatsView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Your Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                LeaderboardStatCard(
                    title: "Games Played",
                    value: "\(user.totalGamesPlayed)",
                    icon: "gamecontroller"
                )
                
                LeaderboardStatCard(
                    title: "Best Accuracy",
                    value: "\(Int(user.bestAccuracy * 100))%",
                    icon: "target"
                )
            }
            
            HStack(spacing: 20) {
                LeaderboardStatCard(
                    title: "Current Streak",
                    value: "\(user.currentStreak)",
                    icon: "flame"
                )
                
                LeaderboardStatCard(
                    title: "Longest Streak",
                    value: "\(user.longestStreak)",
                    icon: "trophy"
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct LeaderboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
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
    }
}

#Preview {
    LeaderboardView(gameManager: GameManager())
}

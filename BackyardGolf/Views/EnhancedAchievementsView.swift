//
//  EnhancedAchievementsView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct EnhancedAchievementsView: View {
    @ObservedObject var achievementManager: AchievementManager
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    @State private var showingNotification = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with progress
                AchievementHeaderView(achievementManager: achievementManager)
                
                // Category filter
                CategoryFilterView(selectedCategory: $selectedCategory)
                
                // Achievements list
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredAchievements, id: \.id) { achievement in
                            EnhancedAchievementCardView(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                // Achievement notification overlay
                Group {
                    if achievementManager.showingAchievementNotification,
                       let achievement = achievementManager.currentNotificationAchievement {
                        AchievementNotificationView(achievement: achievement)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: achievementManager.showingAchievementNotification)
                    }
                }
            )
        }
    }
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementManager.getAchievementsByCategory(category)
        }
        return achievementManager.allAchievements
    }
}

// MARK: - Achievement Header

struct AchievementHeaderView: View {
    @ObservedObject var achievementManager: AchievementManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: achievementManager.getCompletionPercentage())
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: achievementManager.getCompletionPercentage())
                
                VStack(spacing: 4) {
                    Text("\(achievementManager.getTotalUnlockedCount())")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("of \(achievementManager.getTotalAchievementCount())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(achievementManager.getCompletionPercentage() * 100))%")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
            }
            
            // Stats row
            HStack(spacing: 20) {
                StatItem(
                    title: "Unlocked",
                    value: "\(achievementManager.getTotalUnlockedCount())",
                    color: .green
                )
                
                StatItem(
                    title: "In Progress",
                    value: "\(achievementManager.allAchievements.filter { !$0.isUnlocked && $0.progress > 0 }.count)",
                    color: .orange
                )
                
                StatItem(
                    title: "Locked",
                    value: "\(achievementManager.allAchievements.filter { !$0.isUnlocked && $0.progress == 0 }.count)",
                    color: .gray
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Category Filter

struct CategoryFilterView: View {
    @Binding var selectedCategory: Achievement.AchievementCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                CategoryButton(
                    title: "All",
                    icon: "star.fill",
                    isSelected: selectedCategory == nil,
                    color: .blue
                ) {
                    selectedCategory = nil
                }
                
                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: categoryColor(category)
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private func categoryColor(_ category: Achievement.AchievementCategory) -> Color {
        switch category {
        case .beginner: return .green
        case .accuracy: return .blue
        case .streak: return .red
        case .distance: return .orange
        case .gameMode: return .purple
        case .social: return .pink
        case .milestone: return .yellow
        case .dedication: return .indigo
        }
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Enhanced Achievement Card

struct EnhancedAchievementCardView: View {
    let achievement: Achievement
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            HStack(spacing: 15) {
                // Achievement icon with glow effect
                ZStack {
                    Circle()
                        .fill(achievement.rarity.glowColor)
                        .frame(width: 60, height: 60)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                }
                
                // Achievement info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(achievement.name)
                            .font(.headline)
                            .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                        
                        Spacer()
                        
                        // Rarity badge
                        Text(achievement.rarity.rawValue)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(achievement.rarity.color.opacity(0.2))
                            .foregroundColor(achievement.rarity.color)
                            .cornerRadius(8)
                    }
                    
                    Text(achievement.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Progress bar for locked achievements
                    if !achievement.isUnlocked && achievement.progress > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Progress")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(achievement.progress)%")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            
                            ProgressView(value: Double(achievement.progress), total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .scaleEffect(y: 0.5)
                        }
                    }
                    
                    // Unlock date for unlocked achievements
                    if achievement.isUnlocked, let date = achievement.unlockedDate {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            
                            Text("Unlocked \(formatDate(date))")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(achievement.rarity.color.opacity(achievement.isUnlocked ? 0.3 : 0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
            .opacity(achievement.isUnlocked ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            AchievementDetailSheetView(achievement: achievement)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Achievement Detail Sheet

struct AchievementDetailSheetView: View {
    let achievement: Achievement
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Large achievement icon
                ZStack {
                    Circle()
                        .fill(achievement.rarity.glowColor)
                        .frame(width: 150, height: 150)
                        .blur(radius: 20)
                    
                    Circle()
                        .fill(achievement.isUnlocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                }
                
                VStack(spacing: 15) {
                    Text(achievement.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(achievement.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Rarity and category
                    HStack(spacing: 20) {
                        VStack {
                            Text("Rarity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(achievement.rarity.rawValue)
                                .font(.headline)
                                .foregroundColor(achievement.rarity.color)
                        }
                        
                        VStack {
                            Text("Category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(achievement.category.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Progress or unlock info
                    if achievement.isUnlocked {
                        if let date = achievement.unlockedDate {
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                
                                Text("Unlocked")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Text(formatDate(date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        VStack(spacing: 15) {
                            Text("Progress: \(achievement.progress)%")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            ProgressView(value: Double(achievement.progress), total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .scaleEffect(y: 2)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Achievement")
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// MARK: - Achievement Notification

struct AchievementNotificationView: View {
    let achievement: Achievement
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Glowing achievement icon
            ZStack {
                Circle()
                    .fill(achievement.rarity.glowColor)
                    .frame(width: 50, height: 50)
                    .blur(radius: 8)
                    .scaleEffect(animate ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)
                
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Unlocked!")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    EnhancedAchievementsView(achievementManager: AchievementManager())
}

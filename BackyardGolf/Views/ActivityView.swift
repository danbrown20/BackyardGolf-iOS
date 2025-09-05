//
//  ActivityView.swift
//  BackyardGolf
//
//  Created by Dan on 9/5/25.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var socialManager: SocialManager
    @State private var selectedFilter: ActivityFilter = .all
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Tabs
            filterTabsView
            
            // Activity List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredActivities) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding()
            }
        }
    }
    
    private var filterTabsView: some View {
        HStack(spacing: 0) {
            ForEach(ActivityFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(filter.title)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Rectangle()
                            .fill(selectedFilter == filter ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                    .foregroundColor(selectedFilter == filter ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private var filteredActivities: [Activity] {
        switch selectedFilter {
        case .all:
            return socialManager.recentActivity
        case .friends:
            return socialManager.recentActivity.filter { $0.type == .friendActivity }
        case .achievements:
            return socialManager.recentActivity.filter { $0.type == .achievementUnlocked }
        case .challenges:
            return socialManager.recentActivity.filter { $0.type == .challengeCompleted }
        }
    }
}

// MARK: - Activity Filter

enum ActivityFilter: String, CaseIterable {
    case all = "All"
    case friends = "Friends"
    case achievements = "Achievements"
    case challenges = "Challenges"
    
    var title: String {
        return self.rawValue
    }
}

// MARK: - Activity Card

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity Icon
            activityIcon
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.message)
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Activity Type Badge
                    activityTypeBadge
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var activityIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 40, height: 40)
            
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(iconColor)
        }
    }
    
    private var iconName: String {
        switch activity.type {
        case .friendActivity:
            return "person.2"
        case .achievementUnlocked:
            return "trophy.fill"
        case .highScore:
            return "star.fill"
        case .challengeCompleted:
            return "target"
        case .videoShared:
            return "video.fill"
        case .friendRequest:
            return "person.badge.plus"
        }
    }
    
    private var iconColor: Color {
        switch activity.type {
        case .friendActivity:
            return .blue
        case .achievementUnlocked:
            return .yellow
        case .highScore:
            return .orange
        case .challengeCompleted:
            return .green
        case .videoShared:
            return .red
        case .friendRequest:
            return .purple
        }
    }
    
    private var iconBackgroundColor: Color {
        return iconColor.opacity(0.1)
    }
    
    private var activityTypeBadge: some View {
        Text(activity.type.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(iconColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(iconBackgroundColor)
            .cornerRadius(4)
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: activity.timestamp, relativeTo: Date())
    }
}

#Preview {
    ActivityView(socialManager: SocialManager())
}

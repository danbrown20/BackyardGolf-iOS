//
//  ChallengesView.swift
//  BackyardGolf
//
//  Created by Dan on 9/5/25.
//

import SwiftUI

struct ChallengesView: View {
    @ObservedObject var socialManager: SocialManager
    @State private var showingCreateChallenge = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Active Challenges
                if !socialManager.activeChallenges.isEmpty {
                    activeChallengesSection
                } else {
                    emptyStateView
                }
                
                // Create Challenge Button
                createChallengeButton
            }
            .padding()
        }
        .sheet(isPresented: $showingCreateChallenge) {
            CreateChallengeView(friend: UserProfile(id: "temp", username: "Select Friend", email: "temp@example.com", avatar: "person.circle.fill"), socialManager: socialManager)
        }
    }
    
    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Challenges")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(socialManager.activeChallenges) { challenge in
                ChallengeCard(challenge: challenge, socialManager: socialManager)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Active Challenges")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Challenge your friends to compete and see who's the best golfer!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    private var createChallengeButton: some View {
        Button(action: { showingCreateChallenge = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Create New Challenge")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(12)
        }
    }
}

// MARK: - Challenge Card

struct ChallengeCard: View {
    let challenge: Challenge
    @ObservedObject var socialManager: SocialManager
    @State private var showingAcceptDialog = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.gameMode.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Target: \(challenge.target) points")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                statusBadge
            }
            
            // Participants
            HStack {
                // From User
                HStack(spacing: 8) {
                    Image(systemName: challenge.fromUser.avatar)
                        .foregroundColor(.blue)
                    
                    Text(challenge.fromUser.username)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // To User
                HStack(spacing: 8) {
                    Image(systemName: challenge.toUser.avatar)
                        .foregroundColor(.green)
                    
                    Text(challenge.toUser.username)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // Time Info
            HStack {
                Text(timeInfo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if challenge.isExpired {
                    Text("EXPIRED")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            // Action Buttons
            if challenge.status == .pending && challenge.toUser.username == "You" {
                HStack(spacing: 12) {
                    Button("Accept") {
                        socialManager.acceptChallenge(challenge)
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Decline") {
                        // Handle decline
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if challenge.status == .accepted {
                Button("Start Game") {
                    // Navigate to game with challenge parameters
                }
                .font(.caption)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else if challenge.status == .completed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Completed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    if let score = challenge.finalScore {
                        Text("(\(score) pts)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private var statusBadge: some View {
        Text(challenge.status.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .cornerRadius(6)
    }
    
    private var statusColor: Color {
        switch challenge.status {
        case .pending: return .orange
        case .accepted: return .blue
        case .completed: return .green
        case .expired: return .red
        }
    }
    
    private var timeInfo: String {
        if challenge.isExpired {
            return "Expired \(timeAgo(challenge.expiresAt))"
        } else {
            return "Expires \(timeAgo(challenge.expiresAt))"
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Friend Selection Card

struct FriendSelectionCard: View {
    let friend: UserProfile
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: friend.avatar)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.orange : Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(friend.username)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .padding()
            .background(isSelected ? Color.orange : Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    ChallengesView(socialManager: SocialManager())
}

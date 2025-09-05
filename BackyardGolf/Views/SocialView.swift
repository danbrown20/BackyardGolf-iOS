//
//  SocialView.swift
//  BackyardGolf
//
//  Created by Dan on 9/5/25.
//

import SwiftUI

struct SocialView: View {
    @StateObject private var socialManager = SocialManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection Status
                connectionStatusView
                
                // Tab Selection
                tabSelectionView
                
                // Content
                TabView(selection: $selectedTab) {
                    // Friends Tab
                    FriendsView(socialManager: socialManager)
                        .tag(0)
                    
                    // Challenges Tab
                    ChallengesView(socialManager: socialManager)
                        .tag(1)
                    
                    // Leaderboard Tab
                    LeaderboardView(gameManager: GameManager())
                        .tag(2)
                    
                    // Activity Tab
                    ActivityView(socialManager: socialManager)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Social")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(socialManager.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(socialManager.connectionStatus)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if !socialManager.isConnected {
                Button("Connect") {
                    // Simulate connection
                    socialManager.isConnected = true
                    socialManager.connectionStatus = "Connected"
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(tabTitle(for: index))
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "person.2"
        case 1: return "target"
        case 2: return "trophy"
        case 3: return "bell"
        default: return "circle"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Friends"
        case 1: return "Challenges"
        case 2: return "Leaderboard"
        case 3: return "Activity"
        default: return ""
        }
    }
}

// MARK: - Friends View

struct FriendsView: View {
    @ObservedObject var socialManager: SocialManager
    @State private var showingAddFriend = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Friend Requests
                if !socialManager.pendingFriendRequests.isEmpty {
                    friendRequestsSection
                }
                
                // Friends List
                friendsListSection
                
                // Add Friend Button
                addFriendSection
            }
            .padding()
        }
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView(socialManager: socialManager)
        }
    }
    
    private var friendRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friend Requests")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(socialManager.pendingFriendRequests) { request in
                FriendRequestCard(request: request, socialManager: socialManager)
            }
        }
    }
    
    private var friendsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Friends (\(socialManager.friends.count))")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(socialManager.friends) { friend in
                    FriendCard(friend: friend, socialManager: socialManager)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var addFriendSection: some View {
        Button(action: { showingAddFriend = true }) {
            HStack {
                Image(systemName: "person.badge.plus")
                Text("Add Friend")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// MARK: - Friend Request Card

struct FriendRequestCard: View {
    let request: FriendRequest
    @ObservedObject var socialManager: SocialManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Image(systemName: request.fromUser.avatar)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(request.fromUser.username)
                    .font(.headline)
                
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button("Accept") {
                    socialManager.acceptFriendRequest(request)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Decline") {
                    socialManager.declineFriendRequest(request)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: request.timestamp, relativeTo: Date())
    }
}

// MARK: - Friend Card

struct FriendCard: View {
    let friend: UserProfile
    @ObservedObject var socialManager: SocialManager
    @State private var showingChallenge = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Avatar & Status
            ZStack {
                Image(systemName: friend.avatar)
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                // Online indicator
                if friend.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .offset(x: 18, y: 18)
                }
            }
            
            // Username
            Text(friend.username)
                .font(.headline)
                .lineLimit(1)
            
            // Stats
            VStack(spacing: 4) {
                Text("\(friend.totalShots) shots")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(friend.totalGamesPlayed) games")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Challenge Button
            Button("Challenge") {
                showingChallenge = true
            }
            .font(.caption)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingChallenge) {
            CreateChallengeView(friend: friend, socialManager: socialManager)
        }
    }
}

// MARK: - Add Friend View

struct AddFriendView: View {
    @ObservedObject var socialManager: SocialManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var searchResults: [UserProfile] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search by username...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: searchText) { _ in
                            searchUsers()
                        }
                }
                .padding()
                
                // Search Results
                if !searchResults.isEmpty {
                    List(searchResults) { user in
                        HStack {
                            Image(systemName: user.avatar)
                                .foregroundColor(.blue)
                            
                            Text(user.username)
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Add") {
                                socialManager.sendFriendRequest(to: user)
                                presentationMode.wrappedValue.dismiss()
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                    }
                } else if !searchText.isEmpty {
                    Text("No users found")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func searchUsers() {
        // Mock search results
        let mockUsers = [
            UserProfile(id: "search1", username: "GolfPro2024", email: "golfpro@example.com", avatar: "person.circle.fill"),
            UserProfile(id: "search2", username: "ChipMaster", email: "chipmaster@example.com", avatar: "person.circle.fill"),
            UserProfile(id: "search3", username: "BackyardKing", email: "backyardking@example.com", avatar: "person.circle.fill"),
            UserProfile(id: "search4", username: "TrickShotQueen", email: "trickshot@example.com", avatar: "person.circle.fill")
        ]
        
        if searchText.isEmpty {
            searchResults = []
        } else {
            searchResults = mockUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
    }
}

// MARK: - Create Challenge View

struct CreateChallengeView: View {
    let friend: UserProfile
    @ObservedObject var socialManager: SocialManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedGameMode: GameSession.GameMode = .tournament
    @State private var targetScore = 100
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Friend Info
                HStack {
                    Image(systemName: friend.avatar)
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Challenge \(friend.username)")
                            .font(.headline)
                        Text("Create a challenge to compete!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Game Mode Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Game Mode")
                        .font(.headline)
                    
                    Picker("Game Mode", selection: $selectedGameMode) {
                        ForEach(GameSession.GameMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Target Score
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Score: \(targetScore)")
                        .font(.headline)
                    
                    Slider(value: Binding(
                        get: { Double(targetScore) },
                        set: { targetScore = Int($0) }
                    ), in: 50...200, step: 10)
                    .accentColor(.blue)
                }
                
                Spacer()
                
                // Send Challenge Button
                Button(action: {
                    socialManager.createChallenge(
                        to: friend,
                        gameMode: selectedGameMode,
                        target: targetScore
                    )
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Send Challenge")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Create Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    SocialView()
}

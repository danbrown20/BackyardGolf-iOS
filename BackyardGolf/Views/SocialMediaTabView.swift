//
//  SocialMediaTabView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct SocialMediaTabView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Clubhouse Tab
            ClubhouseView(socialManager: socialManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Clubhouse")
                }
                .tag(0)
            
            // Forum Tab
            ForumView(socialManager: socialManager)
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Forum")
                }
                .tag(1)
            
            // Communities Tab
            CommunitiesView(socialManager: socialManager)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Communities")
                }
                .tag(2)
            
            // Friends Tab
            SocialFriendsView(socialManager: socialManager)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

// MARK: - Friends View

struct SocialFriendsView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @State private var showingAddFriend = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Friends list
                ScrollView {
                    LazyVStack(spacing: 15) {
                        // Online friends
                        if !onlineFriends.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Online Now")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                
                                ForEach(onlineFriends) { friend in
                                    FriendRow(friend: friend, socialManager: socialManager)
                                }
                            }
                        }
                        
                        // All friends
                        VStack(alignment: .leading, spacing: 10) {
                            Text("All Friends")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ForEach(filteredFriends) { friend in
                                FriendRow(friend: friend, socialManager: socialManager)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFriend = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                SocialAddFriendView(socialManager: socialManager)
            }
        }
    }
    
    private var onlineFriends: [SocialUser] {
        // Mock online friends - in real app, this would filter by online status
        return socialManager.posts.map { $0.author }.prefix(3).map { $0 }
    }
    
    private var filteredFriends: [SocialUser] {
        let allFriends = socialManager.posts.map { $0.author }
        
        if searchText.isEmpty {
            return allFriends
        } else {
            return allFriends.filter { 
                $0.username.localizedCaseInsensitiveContains(searchText) ||
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct FriendRow: View {
    let friend: SocialUser
    @ObservedObject var socialManager: SocialMediaManager
    @State private var showingProfile = false
    
    var body: some View {
        Button(action: { showingProfile = true }) {
            HStack(spacing: 15) {
                // Avatar
                AsyncImage(url: URL(string: friend.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.green, lineWidth: 2)
                        .opacity(isOnline ? 1 : 0)
                )
                
                // Friend info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(friend.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if friend.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("@\(friend.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !friend.bio.isEmpty {
                        Text(friend.bio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(friend.followers)")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("followers")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("HCP: \(String(format: "%.1f", friend.handicap))")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingProfile) {
            FriendProfileView(friend: friend, socialManager: socialManager)
        }
    }
    
    private var isOnline: Bool {
        // Mock online status - in real app, this would check actual online status
        return friend.username == "ChipMaster" || friend.username == "GolfGuru"
    }
}

// MARK: - Add Friend View

struct SocialAddFriendView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var searchResults: [SocialUser] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search bar
                HStack {
                    TextField("Search by username or email...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            searchUsers()
                        }
                    
                    Button("Search") {
                        searchUsers()
                    }
                    .disabled(searchText.isEmpty)
                }
                .padding()
                
                // Search results
                if isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(searchResults) { user in
                                SearchResultRow(user: user, socialManager: socialManager)
                            }
                        }
                        .padding()
                    }
                } else if !searchText.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No users found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching with a different username or email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Find Friends")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Search for friends by username or email to connect and play together")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Add Friends")
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
    
    private func searchUsers() {
        isSearching = true
        
        // Mock search - in real app, this would make an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            searchResults = socialManager.posts.map { $0.author }.filter { 
                $0.username.localizedCaseInsensitiveContains(searchText) ||
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
            isSearching = false
        }
    }
}

struct SearchResultRow: View {
    let user: SocialUser
    @ObservedObject var socialManager: SocialMediaManager
    @State private var isFollowing = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            AsyncImage(url: URL(string: user.avatar)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Follow button
            Button(action: { 
                isFollowing.toggle()
                // In real app, this would make an API call
            }) {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isFollowing ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Friend Profile View

struct FriendProfileView: View {
    let friend: SocialUser
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Profile header
                FriendProfileHeaderView(friend: friend)
                
                // Tab selector
                Picker("Content Type", selection: $selectedTab) {
                    Text("Posts").tag(0)
                    Text("Achievements").tag(1)
                    Text("Stats").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Posts
                    FriendPostsView(friend: friend, socialManager: socialManager)
                        .tag(0)
                    
                    // Achievements
                    FriendAchievementsView(friend: friend)
                        .tag(1)
                    
                    // Stats
                    FriendStatsView(friend: friend)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle(friend.displayName)
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

struct FriendProfileHeaderView: View {
    let friend: SocialUser
    
    var body: some View {
        VStack(spacing: 15) {
            // Avatar and basic info
            VStack(spacing: 8) {
                AsyncImage(url: URL(string: friend.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.green, lineWidth: 3)
                        .opacity(isOnline ? 1 : 0)
                )
                
                VStack(spacing: 4) {
                    HStack {
                        Text(friend.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if friend.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("@\(friend.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Bio
            if !friend.bio.isEmpty {
                Text(friend.bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(friend.followers)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(friend.following)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(friend.posts)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Posts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(String(format: "%.1f", friend.handicap))")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Handicap")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Location
            if !friend.location.isEmpty {
                HStack {
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(friend.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    private var isOnline: Bool {
        // Mock online status
        return friend.username == "ChipMaster" || friend.username == "GolfGuru"
    }
}

struct FriendPostsView: View {
    let friend: SocialUser
    @ObservedObject var socialManager: SocialMediaManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(socialManager.posts.filter { $0.author.id == friend.id }) { post in
                    SocialPostCard(post: post, socialManager: socialManager)
                }
            }
            .padding()
        }
    }
}

struct FriendAchievementsView: View {
    let friend: SocialUser
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mock achievements
                ForEach(0..<5) { index in
                    AchievementCard(
                        title: "Achievement \(index + 1)",
                        description: "This is a sample achievement description",
                        icon: "trophy.fill",
                        isUnlocked: index < 3
                    )
                }
            }
            .padding()
        }
    }
}

struct AchievementCard: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .yellow : .gray)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .opacity(isUnlocked ? 1 : 0.6)
    }
}

struct FriendStatsView: View {
    let friend: SocialUser
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mock stats
                SocialStatCard(title: "Games Played", value: "\(Int.random(in: 50...200))", icon: "gamecontroller.fill", color: .blue)
                SocialStatCard(title: "Best Score", value: "\(Int.random(in: 10...50))", icon: "star.fill", color: .yellow)
                SocialStatCard(title: "Accuracy", value: "\(String(format: "%.1f", Double.random(in: 60...95)))%", icon: "target", color: .green)
                SocialStatCard(title: "Longest Shot", value: "\(String(format: "%.1f", Double.random(in: 20...40)))ft", icon: "arrow.up", color: .orange)
            }
            .padding()
        }
    }
}

struct SocialStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SocialMediaTabView(socialManager: SocialMediaManager())
}

//
//  ClubhouseView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct ClubhouseView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @State private var selectedTab = 0
    @State private var showingCreatePost = false
    @State private var showingCreateStory = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with user info
                ClubhouseHeaderView(socialManager: socialManager)
                
                // Tab selector
                Picker("Content Type", selection: $selectedTab) {
                    Text("Feed").tag(0)
                    Text("Stories").tag(1)
                    Text("Trending").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Social Feed
                    SocialFeedView(socialManager: socialManager)
                        .tag(0)
                    
                    // Stories
                    StoriesView(socialManager: socialManager)
                        .tag(1)
                    
                    // Trending
                    TrendingView(socialManager: socialManager)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Clubhouse")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreatePost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView(socialManager: socialManager)
            }
        }
    }
}

// MARK: - Clubhouse Header

struct ClubhouseHeaderView: View {
    @ObservedObject var socialManager: SocialMediaManager
    
    var body: some View {
        VStack(spacing: 15) {
            // User stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(socialManager.currentUser?.followers ?? 0)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(socialManager.currentUser?.following ?? 0)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(socialManager.currentUser?.posts ?? 0)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Posts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick actions
            HStack(spacing: 15) {
                QuickActionButton(
                    icon: "camera.fill",
                    title: "Story",
                    color: .purple
                ) {
                    // Create story action
                }
                
                QuickActionButton(
                    icon: "photo.fill",
                    title: "Photo",
                    color: .blue
                ) {
                    // Create photo post action
                }
                
                QuickActionButton(
                    icon: "video.fill",
                    title: "Video",
                    color: .red
                ) {
                    // Create video post action
                }
                
                QuickActionButton(
                    icon: "gamecontroller.fill",
                    title: "Game",
                    color: .green
                ) {
                    // Share game result action
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Social Feed

struct SocialFeedView: View {
    @ObservedObject var socialManager: SocialMediaManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(socialManager.posts) { post in
                    SocialPostCard(post: post, socialManager: socialManager)
                }
            }
            .padding()
        }
    }
}

struct SocialPostCard: View {
    let post: SocialPost
    @ObservedObject var socialManager: SocialMediaManager
    @State private var showingComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Author info
            HStack {
                AsyncImage(url: URL(string: post.author.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(post.author.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if post.author.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("@\(post.author.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgoString(from: post.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Post content
            Text(post.content)
                .font(.body)
                .lineLimit(nil)
            
            // Game data if available
            if let gameData = post.gameData {
                GameDataCard(gameData: gameData)
            }
            
            // Images
            if !post.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(post.images, id: \.self) { imageName in
                            Image(systemName: imageName)
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                                .frame(width: 100, height: 100)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Hashtags
            if !post.hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.hashtags, id: \.self) { hashtag in
                            Text(hashtag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Actions
            HStack(spacing: 30) {
                Button(action: { socialManager.likePost(post) }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .gray)
                        Text("\(post.likes)")
                            .font(.caption)
                    }
                }
                
                Button(action: { showingComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("\(post.comments)")
                            .font(.caption)
                    }
                }
                
                Button(action: { socialManager.sharePost(post) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                        Text("\(post.shares)")
                            .font(.caption)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post, socialManager: socialManager)
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct GameDataCard: View {
    let gameData: GamePostData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Game Result")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(gameData.score)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(String(format: "%.1f", gameData.accuracy))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(String(format: "%.1f", gameData.distance))ft")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(gameData.gameMode)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Stories View

struct StoriesView: View {
    @ObservedObject var socialManager: SocialMediaManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add story button
                AddStoryButton()
                
                // Stories grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(socialManager.stories) { story in
                        StoryCard(story: story, socialManager: socialManager)
                    }
                }
                .padding()
            }
        }
    }
}

struct AddStoryButton: View {
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Text("Your Story")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
    }
}

struct StoryCard: View {
    let story: Story
    @ObservedObject var socialManager: SocialMediaManager
    
    var body: some View {
        Button(action: { socialManager.viewStory(story) }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(story.isViewed ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: story.image)
                        .font(.title2)
                        .foregroundColor(story.isViewed ? .gray : .blue)
                }
                
                Text(story.author.username)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Trending View

struct TrendingView: View {
    @ObservedObject var socialManager: SocialMediaManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Trending hashtags
                VStack(alignment: .leading, spacing: 15) {
                    Text("Trending Hashtags")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(socialManager.trendingHashtags) { hashtag in
                        TrendingHashtagRow(hashtag: hashtag)
                    }
                }
                
                // Popular posts
                VStack(alignment: .leading, spacing: 15) {
                    Text("Popular Posts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(socialManager.posts.prefix(3)) { post in
                        SocialPostCard(post: post, socialManager: socialManager)
                    }
                }
            }
            .padding()
        }
    }
}

struct TrendingHashtagRow: View {
    let hashtag: Hashtag
    
    var body: some View {
        HStack {
            Text(hashtag.name)
                .font(.headline)
                .foregroundColor(.blue)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(hashtag.postCount) posts")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: trendIcon)
                        .font(.caption)
                        .foregroundColor(trendColor)
                    Text(trendText)
                        .font(.caption)
                        .foregroundColor(trendColor)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var trendIcon: String {
        switch hashtag.trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    private var trendColor: Color {
        switch hashtag.trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
    
    private var trendText: String {
        switch hashtag.trend {
        case .up: return "Trending"
        case .down: return "Declining"
        case .stable: return "Stable"
        }
    }
}

// MARK: - Create Post View

struct CreatePostView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var postContent = ""
    @State private var selectedImages: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Content input
                TextEditor(text: $postContent)
                    .frame(minHeight: 200)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // Image selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedImages, id: \.self) { imageName in
                            Image(systemName: imageName)
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        socialManager.createPost(content: postContent, images: selectedImages)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(postContent.isEmpty)
                }
            }
        }
    }
}

// MARK: - Comments View

struct CommentsView: View {
    let post: SocialPost
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var commentText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Comments list (mock data)
                List {
                    ForEach(0..<5) { index in
                        CommentRow(
                            author: "User\(index)",
                            content: "This is a sample comment \(index + 1)",
                            timestamp: Date().addingTimeInterval(-Double(index) * 60 * 60)
                        )
                    }
                }
                
                // Comment input
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Post") {
                        // Add comment logic
                        commentText = ""
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Comments")
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

struct CommentRow: View {
    let author: String
    let content: String
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(author)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(timeAgoString(from: timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(content)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ClubhouseView(socialManager: SocialMediaManager())
}

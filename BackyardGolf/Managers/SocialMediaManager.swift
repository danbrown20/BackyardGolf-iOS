//
//  SocialMediaManager.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import Foundation
import SwiftUI

// MARK: - Social Media Manager

class SocialMediaManager: ObservableObject {
    @Published var posts: [SocialPost] = []
    @Published var stories: [Story] = []
    @Published var forumTopics: [ForumTopic] = []
    @Published var communities: [Community] = []
    @Published var trendingHashtags: [Hashtag] = []
    @Published var notifications: [SocialNotification] = []
    @Published var currentUser: SocialUser?
    
    init() {
        setupMockData()
        createCurrentUser()
    }
    
    private func createCurrentUser() {
        currentUser = SocialUser(
            id: "user_1",
            username: "GolfPro",
            displayName: "Golf Pro",
            avatar: "person.circle.fill",
            bio: "Passionate about backyard golf and helping others improve their game!",
            followers: 1250,
            following: 340,
            posts: 45,
            isVerified: true,
            joinDate: Date().addingTimeInterval(-365 * 24 * 60 * 60),
            location: "San Francisco, CA",
            handicap: 8.5
        )
    }
    
    private func setupMockData() {
        // Mock posts
        posts = [
            SocialPost(
                id: "post_1",
                author: SocialUser(
                    id: "user_2",
                    username: "ChipMaster",
                    displayName: "Chip Master",
                    avatar: "person.circle.fill",
                    bio: "Golf enthusiast and trick shot specialist",
                    followers: 890,
                    following: 120,
                    posts: 23,
                    isVerified: false,
                    joinDate: Date().addingTimeInterval(-200 * 24 * 60 * 60),
                    location: "Austin, TX",
                    handicap: 12.0
                ),
                content: "Just hit my first hole-in-one in the backyard! 🏌️‍♂️⛳ The feeling is incredible! #HoleInOne #BackyardGolf #Amazing",
                images: ["golf.ball.fill"],
                videoURL: nil,
                likes: 45,
                comments: 12,
                shares: 8,
                timestamp: Date().addingTimeInterval(-2 * 60 * 60),
                hashtags: ["#HoleInOne", "#BackyardGolf", "#Amazing"],
                isLiked: false,
                gameData: GamePostData(
                    score: 1,
                    accuracy: 100.0,
                    distance: 25.5,
                    gameMode: "Practice"
                )
            ),
            
            SocialPost(
                id: "post_2",
                author: SocialUser(
                    id: "user_3",
                    username: "GolfGuru",
                    displayName: "Golf Guru",
                    avatar: "person.circle.fill",
                    bio: "Professional golf instructor sharing tips and tricks",
                    followers: 2100,
                    following: 450,
                    posts: 156,
                    isVerified: true,
                    joinDate: Date().addingTimeInterval(-500 * 24 * 60 * 60),
                    location: "Pinehurst, NC",
                    handicap: 2.5
                ),
                content: "Tip of the day: Focus on your follow-through! 🎯 A smooth follow-through leads to better accuracy and distance. Practice this drill daily! #GolfTips #Improvement #BackyardGolf",
                images: ["figure.golf"],
                videoURL: nil,
                likes: 78,
                comments: 23,
                shares: 15,
                timestamp: Date().addingTimeInterval(-4 * 60 * 60),
                hashtags: ["#GolfTips", "#Improvement", "#BackyardGolf"],
                isLiked: true,
                gameData: nil
            ),
            
            SocialPost(
                id: "post_3",
                author: SocialUser(
                    id: "user_4",
                    username: "TrickShotQueen",
                    displayName: "Trick Shot Queen",
                    avatar: "person.circle.fill",
                    bio: "Master of impossible golf shots and creative challenges",
                    followers: 3200,
                    following: 280,
                    posts: 89,
                    isVerified: true,
                    joinDate: Date().addingTimeInterval(-300 * 24 * 60 * 60),
                    location: "Las Vegas, NV",
                    handicap: 15.0
                ),
                content: "New trick shot challenge: Can you chip over the house and land in the pool? 🏠🏊‍♀️ Tag your attempts! #TrickShot #Challenge #BackyardGolf #Impossible",
                images: ["house.fill", "figure.pool.swim"],
                videoURL: "trick_shot_video.mp4",
                likes: 156,
                comments: 45,
                shares: 32,
                timestamp: Date().addingTimeInterval(-6 * 60 * 60),
                hashtags: ["#TrickShot", "#Challenge", "#BackyardGolf", "#Impossible"],
                isLiked: false,
                gameData: GamePostData(
                    score: 0,
                    accuracy: 0.0,
                    distance: 0.0,
                    gameMode: "Trick Shot"
                )
            )
        ]
        
        // Mock stories
        stories = [
            Story(
                id: "story_1",
                author: SocialUser(
                    id: "user_5",
                    username: "GolfDad",
                    displayName: "Golf Dad",
                    avatar: "person.circle.fill",
                    bio: "Teaching my kids the love of golf",
                    followers: 450,
                    following: 200,
                    posts: 34,
                    isVerified: false,
                    joinDate: Date().addingTimeInterval(-150 * 24 * 60 * 60),
                    location: "Denver, CO",
                    handicap: 18.0
                ),
                content: "Teaching my 8-year-old her first swing! She's a natural! 👧⛳",
                image: "figure.golf",
                timestamp: Date().addingTimeInterval(-30 * 60),
                isViewed: false
            ),
            
            Story(
                id: "story_2",
                author: SocialUser(
                    id: "user_6",
                    username: "NightGolfer",
                    displayName: "Night Golfer",
                    avatar: "person.circle.fill",
                    bio: "Golfing under the stars with LED balls",
                    followers: 1200,
                    following: 180,
                    posts: 67,
                    isVerified: false,
                    joinDate: Date().addingTimeInterval(-100 * 24 * 60 * 60),
                    location: "Phoenix, AZ",
                    handicap: 14.0
                ),
                content: "Night golf with LED balls is absolutely magical! ✨🌙",
                image: "moon.stars.fill",
                timestamp: Date().addingTimeInterval(-45 * 60),
                isViewed: true
            )
        ]
        
        // Mock forum topics
        forumTopics = [
            ForumTopic(
                id: "topic_1",
                title: "Best Backyard Golf Setup Tips",
                author: SocialUser(
                    id: "user_7",
                    username: "SetupExpert",
                    displayName: "Setup Expert",
                    avatar: "person.circle.fill",
                    bio: "Backyard golf setup specialist",
                    followers: 800,
                    following: 150,
                    posts: 45,
                    isVerified: false,
                    joinDate: Date().addingTimeInterval(-180 * 24 * 60 * 60),
                    location: "Portland, OR",
                    handicap: 10.0
                ),
                content: "What's your go-to backyard golf setup? I'm looking for tips on creating the perfect practice area in a small space. Share your setups and any creative solutions you've found!",
                category: "Setup & Equipment",
                replies: 23,
                views: 456,
                lastActivity: Date().addingTimeInterval(-1 * 60 * 60),
                isPinned: true,
                tags: ["setup", "equipment", "tips"]
            ),
            
            ForumTopic(
                id: "topic_2",
                title: "LED Ball Recommendations",
                author: SocialUser(
                    id: "user_8",
                    username: "LEDGolfer",
                    displayName: "LED Golfer",
                    avatar: "person.circle.fill",
                    bio: "Night golf enthusiast",
                    followers: 650,
                    following: 120,
                    posts: 28,
                    isVerified: false,
                    joinDate: Date().addingTimeInterval(-120 * 24 * 60 * 60),
                    location: "Miami, FL",
                    handicap: 16.0
                ),
                content: "Looking for the best LED golf balls for night play. What brands have you tried? Durability and brightness are my main concerns.",
                category: "Equipment",
                replies: 15,
                views: 234,
                lastActivity: Date().addingTimeInterval(-2 * 60 * 60),
                isPinned: false,
                tags: ["led", "balls", "night-golf"]
            )
        ]
        
        // Mock communities
        communities = [
            Community(
                id: "community_1",
                name: "Backyard Golf Masters",
                description: "For serious backyard golfers looking to improve their game",
                memberCount: 1250,
                postCount: 340,
                isPrivate: false,
                category: "Competitive",
                rules: ["Be respectful", "Share helpful tips", "No spam"],
                moderators: ["GolfGuru", "ChipMaster"],
                joinDate: Date().addingTimeInterval(-365 * 24 * 60 * 60)
            ),
            
            Community(
                id: "community_2",
                name: "Trick Shot Enthusiasts",
                description: "Share and discover amazing trick shots and creative challenges",
                memberCount: 890,
                postCount: 156,
                isPrivate: false,
                category: "Creative",
                rules: ["Post original content", "Tag your attempts", "Be creative"],
                moderators: ["TrickShotQueen"],
                joinDate: Date().addingTimeInterval(-200 * 24 * 60 * 60)
            ),
            
            Community(
                id: "community_3",
                name: "San Francisco Golfers",
                description: "Local community for SF area backyard golfers",
                memberCount: 340,
                postCount: 89,
                isPrivate: false,
                category: "Local",
                rules: ["SF area only", "Share local events", "Meetup friendly"],
                moderators: ["GolfPro"],
                joinDate: Date().addingTimeInterval(-100 * 24 * 60 * 60)
            )
        ]
        
        // Mock trending hashtags
        trendingHashtags = [
            Hashtag(name: "#BackyardGolf", postCount: 1250, trend: .up),
            Hashtag(name: "#TrickShot", postCount: 890, trend: .up),
            Hashtag(name: "#GolfTips", postCount: 670, trend: .stable),
            Hashtag(name: "#HoleInOne", postCount: 450, trend: .up),
            Hashtag(name: "#NightGolf", postCount: 320, trend: .down)
        ]
    }
    
    // MARK: - Post Management
    
    func createPost(content: String, images: [String]? = nil, videoURL: String? = nil, gameData: GamePostData? = nil) {
        guard let user = currentUser else { return }
        
        let hashtags = extractHashtags(from: content)
        let post = SocialPost(
            id: UUID().uuidString,
            author: user,
            content: content,
            images: images ?? [],
            videoURL: videoURL,
            likes: 0,
            comments: 0,
            shares: 0,
            timestamp: Date(),
            hashtags: hashtags,
            isLiked: false,
            gameData: gameData
        )
        
        posts.insert(post, at: 0)
        updateHashtagTrends(hashtags)
    }
    
    func likePost(_ post: SocialPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            if posts[index].isLiked {
                posts[index].likes -= 1
                posts[index].isLiked = false
            } else {
                posts[index].likes += 1
                posts[index].isLiked = true
            }
        }
    }
    
    func sharePost(_ post: SocialPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].shares += 1
        }
    }
    
    // MARK: - Story Management
    
    func createStory(content: String, image: String) {
        guard let user = currentUser else { return }
        
        let story = Story(
            id: UUID().uuidString,
            author: user,
            content: content,
            image: image,
            timestamp: Date(),
            isViewed: false
        )
        
        stories.insert(story, at: 0)
    }
    
    func viewStory(_ story: Story) {
        if let index = stories.firstIndex(where: { $0.id == story.id }) {
            stories[index].isViewed = true
        }
    }
    
    // MARK: - Forum Management
    
    func createForumTopic(title: String, content: String, category: String, tags: [String]) {
        guard let user = currentUser else { return }
        
        let topic = ForumTopic(
            id: UUID().uuidString,
            title: title,
            author: user,
            content: content,
            category: category,
            replies: 0,
            views: 0,
            lastActivity: Date(),
            isPinned: false,
            tags: tags
        )
        
        forumTopics.insert(topic, at: 0)
    }
    
    // MARK: - Community Management
    
    func joinCommunity(_ community: Community) {
        // In a real app, this would make an API call
        print("Joined community: \(community.name)")
    }
    
    func leaveCommunity(_ community: Community) {
        // In a real app, this would make an API call
        print("Left community: \(community.name)")
    }
    
    // MARK: - Helper Methods
    
    private func extractHashtags(from text: String) -> [String] {
        let hashtagPattern = "#\\w+"
        let regex = try? NSRegularExpression(pattern: hashtagPattern)
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []
        
        return matches.compactMap { match in
            if let range = Range(match.range, in: text) {
                return String(text[range])
            }
            return nil
        }
    }
    
    private func updateHashtagTrends(_ hashtags: [String]) {
        for hashtag in hashtags {
            if let index = trendingHashtags.firstIndex(where: { $0.name == hashtag }) {
                trendingHashtags[index].postCount += 1
            } else {
                trendingHashtags.append(Hashtag(name: hashtag, postCount: 1, trend: .up))
            }
        }
    }
}

// MARK: - Social Media Models

struct SocialPost: Identifiable {
    let id: String
    let author: SocialUser
    let content: String
    let images: [String]
    let videoURL: String?
    var likes: Int
    var comments: Int
    var shares: Int
    let timestamp: Date
    let hashtags: [String]
    var isLiked: Bool
    let gameData: GamePostData?
}

struct SocialUser: Identifiable {
    let id: String
    let username: String
    let displayName: String
    let avatar: String
    let bio: String
    let followers: Int
    let following: Int
    let posts: Int
    let isVerified: Bool
    let joinDate: Date
    let location: String
    let handicap: Double
}

struct Story: Identifiable {
    let id: String
    let author: SocialUser
    let content: String
    let image: String
    let timestamp: Date
    var isViewed: Bool
}

struct ForumTopic: Identifiable {
    let id: String
    let title: String
    let author: SocialUser
    let content: String
    let category: String
    var replies: Int
    var views: Int
    let lastActivity: Date
    let isPinned: Bool
    let tags: [String]
}

struct Community: Identifiable {
    let id: String
    let name: String
    let description: String
    let memberCount: Int
    let postCount: Int
    let isPrivate: Bool
    let category: String
    let rules: [String]
    let moderators: [String]
    let joinDate: Date
}

struct Hashtag: Identifiable {
    let id = UUID()
    let name: String
    var postCount: Int
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
    }
}

struct GamePostData {
    let score: Int
    let accuracy: Double
    let distance: Double
    let gameMode: String
}

struct SocialNotification: Identifiable {
    let id: String
    let type: NotificationType
    let message: String
    let timestamp: Date
    let isRead: Bool
    
    enum NotificationType {
        case like, comment, follow, mention, achievement
    }
}

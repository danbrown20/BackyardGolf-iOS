//
//  CommunitiesView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct CommunitiesView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @State private var selectedCategory = "All"
    @State private var showingCreateCommunity = false
    @State private var searchText = ""
    
    let categories = ["All", "Local", "Competitive", "Creative", "Beginner", "Professional"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CommunityCategoryButton(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Communities list
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredCommunities) { community in
                            CommunityCard(community: community, socialManager: socialManager)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Communities")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateCommunity = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateCommunity) {
                CreateCommunityView(socialManager: socialManager)
            }
        }
    }
    
    private var filteredCommunities: [Community] {
        var communities = socialManager.communities
        
        if selectedCategory != "All" {
            communities = communities.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            communities = communities.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return communities
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search communities...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CommunityCategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct CommunityCard: View {
    let community: Community
    @ObservedObject var socialManager: SocialMediaManager
    @State private var showingCommunityDetail = false
    @State private var isJoined = false
    
    var body: some View {
        Button(action: { showingCommunityDetail = true }) {
            VStack(alignment: .leading, spacing: 15) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(community.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(community.category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(categoryColor.opacity(0.1))
                                .foregroundColor(categoryColor)
                                .cornerRadius(6)
                            
                            if community.isPrivate {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timeAgoString(from: community.joinDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if community.isPrivate {
                            Text("Private")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Description
                Text(community.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Stats
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("\(community.memberCount)")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("members")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("\(community.postCount)")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("posts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Join button
                    Button(action: { 
                        isJoined.toggle()
                        if isJoined {
                            socialManager.joinCommunity(community)
                        } else {
                            socialManager.leaveCommunity(community)
                        }
                    }) {
                        Text(isJoined ? "Joined" : "Join")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isJoined ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                // Moderators
                if !community.moderators.isEmpty {
                    HStack {
                        Text("Moderators:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(community.moderators.prefix(3), id: \.self) { moderator in
                            Text(moderator)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        
                        if community.moderators.count > 3 {
                            Text("+\(community.moderators.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingCommunityDetail) {
            CommunityDetailView(community: community, socialManager: socialManager)
        }
    }
    
    private var categoryColor: Color {
        switch community.category {
        case "Local": return .green
        case "Competitive": return .red
        case "Creative": return .purple
        case "Beginner": return .blue
        case "Professional": return .orange
        default: return .gray
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Create Community View

struct CreateCommunityView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory = "General"
    @State private var isPrivate = false
    @State private var rules = ""
    
    let categories = ["Local", "Competitive", "Creative", "Beginner", "Professional", "General"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Community Details")) {
                    TextField("Community Name", text: $name)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    Toggle("Private Community", isOn: $isPrivate)
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Community Rules")) {
                    TextEditor(text: $rules)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Create Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        // Create community logic
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

// MARK: - Community Detail View

struct CommunityDetailView: View {
    let community: Community
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var isJoined = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                CommunityHeaderView(community: community, isJoined: $isJoined, socialManager: socialManager)
                
                // Tab selector
                Picker("Content Type", selection: $selectedTab) {
                    Text("Posts").tag(0)
                    Text("Members").tag(1)
                    Text("Rules").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Posts
                    CommunityPostsView(community: community)
                        .tag(0)
                    
                    // Members
                    CommunityMembersView(community: community)
                        .tag(1)
                    
                    // Rules
                    CommunityRulesView(community: community)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle(community.name)
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

struct CommunityHeaderView: View {
    let community: Community
    @Binding var isJoined: Bool
    @ObservedObject var socialManager: SocialMediaManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Community info
            VStack(spacing: 8) {
                Text(community.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(community.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(community.memberCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(community.postCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Posts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(community.category)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Join/Leave button
            Button(action: { 
                isJoined.toggle()
                if isJoined {
                    socialManager.joinCommunity(community)
                } else {
                    socialManager.leaveCommunity(community)
                }
            }) {
                Text(isJoined ? "Leave Community" : "Join Community")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isJoined ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct CommunityPostsView: View {
    let community: Community
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                // Mock community posts
                ForEach(0..<5) { index in
                    CommunityPostCard(
                        author: "Member\(index + 1)",
                        content: "This is a sample post from a community member. It could be about golf tips, equipment reviews, or local events.",
                        timestamp: Date().addingTimeInterval(-Double(index) * 60 * 60),
                        likes: Int.random(in: 5...50),
                        comments: Int.random(in: 0...15)
                    )
                }
            }
            .padding()
        }
    }
}

struct CommunityPostCard: View {
    let author: String
    let content: String
    let timestamp: Date
    let likes: Int
    let comments: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                .lineSpacing(2)
            
            HStack(spacing: 20) {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.caption)
                        Text("\(likes)")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.caption)
                        Text("\(comments)")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CommunityMembersView: View {
    let community: Community
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                // Mock community members
                ForEach(0..<min(community.memberCount, 20)) { index in
                    CommunityMemberRow(
                        username: "Member\(index + 1)",
                        joinDate: Date().addingTimeInterval(-Double(index) * 24 * 60 * 60),
                        isModerator: community.moderators.contains("Member\(index + 1)")
                    )
                }
            }
            .padding()
        }
    }
}

struct CommunityMemberRow: View {
    let username: String
    let joinDate: Date
    let isModerator: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(username)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if isModerator {
                        Text("Moderator")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
                Text("Joined \(timeAgoString(from: joinDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CommunityRulesView: View {
    let community: Community
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Community Rules")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ForEach(community.rules, id: \.self) { rule in
                    HStack(alignment: .top, spacing: 12) {
                        Text("•")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(rule)
                            .font(.body)
                            .lineSpacing(2)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    CommunitiesView(socialManager: SocialMediaManager())
}

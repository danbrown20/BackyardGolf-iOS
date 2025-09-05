//
//  ForumView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct ForumView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @State private var selectedCategory = "All"
    @State private var showingCreateTopic = false
    @State private var searchText = ""
    
    let categories = ["All", "Setup & Equipment", "Tips & Techniques", "Tournaments", "General Discussion", "Equipment"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                ForumSearchBar(text: $searchText)
                    .padding()
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            ForumCategoryButton(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Topics list
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredTopics) { topic in
                            ForumTopicCard(topic: topic, socialManager: socialManager)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Forum")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateTopic = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateTopic) {
                CreateTopicView(socialManager: socialManager)
            }
        }
    }
    
    private var filteredTopics: [ForumTopic] {
        var topics = socialManager.forumTopics
        
        if selectedCategory != "All" {
            topics = topics.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            topics = topics.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return topics
    }
}

struct ForumSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search topics...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ForumCategoryButton: View {
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

struct ForumTopicCard: View {
    let topic: ForumTopic
    @ObservedObject var socialManager: SocialMediaManager
    @State private var showingTopicDetail = false
    
    var body: some View {
        Button(action: { showingTopicDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(topic.category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                            
                            if topic.isPinned {
                                Image(systemName: "pin.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timeAgoString(from: topic.lastActivity))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if topic.isPinned {
                            Text("Pinned")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Content preview
                Text(topic.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Author info
                HStack {
                    AsyncImage(url: URL(string: topic.author.avatar)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    
                    Text(topic.author.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if topic.author.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("\(topic.author.handicap)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
                
                // Stats
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(topic.replies)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(topic.views)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Tags
                    HStack(spacing: 4) {
                        ForEach(topic.tags.prefix(2), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.secondary)
                                .cornerRadius(4)
                        }
                        
                        if topic.tags.count > 2 {
                            Text("+\(topic.tags.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingTopicDetail) {
            TopicDetailView(topic: topic, socialManager: socialManager)
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Create Topic View

struct CreateTopicView: View {
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory = "General Discussion"
    @State private var tags = ""
    
    let categories = ["Setup & Equipment", "Tips & Techniques", "Tournaments", "General Discussion", "Equipment"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Topic Details")) {
                    TextField("Topic Title", text: $title)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Tags (comma separated)", text: $tags)
                        .font(.caption)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("New Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        let tagArray = tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        socialManager.createForumTopic(
                            title: title,
                            content: content,
                            category: selectedCategory,
                            tags: tagArray
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Topic Detail View

struct TopicDetailView: View {
    let topic: ForumTopic
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    @State private var replyText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Original post
                    VStack(alignment: .leading, spacing: 15) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(topic.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Text(topic.category)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(6)
                                    
                                    if topic.isPinned {
                                        Image(systemName: "pin.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(timeAgoString(from: topic.lastActivity))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(topic.views) views")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Author info
                        HStack {
                            AsyncImage(url: URL(string: topic.author.avatar)) { image in
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
                                    Text(topic.author.displayName)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    if topic.author.isVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Text("@\(topic.author.username)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Handicap")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(topic.author.handicap)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Content
                        Text(topic.content)
                            .font(.body)
                            .lineSpacing(4)
                        
                        // Tags
                        if !topic.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(topic.tags, id: \.self) { tag in
                                        Text("#\(tag)")
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
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Replies section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Replies (\(topic.replies))")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Mock replies
                        ForEach(0..<min(topic.replies, 5)) { index in
                            ReplyCard(
                                author: "User\(index + 1)",
                                content: "This is a sample reply \(index + 1) to the topic. It provides additional information or asks follow-up questions.",
                                timestamp: Date().addingTimeInterval(-Double(index) * 60 * 60),
                                isHelpful: index % 3 == 0
                            )
                        }
                        
                        if topic.replies > 5 {
                            Button("View All Replies") {
                                // Show all replies
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Reply input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add Reply")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $replyText)
                            .frame(minHeight: 100)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        HStack {
                            Spacer()
                            
                            Button("Post Reply") {
                                // Post reply logic
                                replyText = ""
                            }
                            .disabled(replyText.isEmpty)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Topic")
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
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ReplyCard: View {
    let author: String
    let content: String
    let timestamp: Date
    let isHelpful: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(author)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    if isHelpful {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("Helpful")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(timeAgoString(from: timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(content)
                .font(.body)
                .lineSpacing(2)
            
            HStack {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup")
                            .font(.caption)
                        Text("Helpful")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.caption)
                        Text("Reply")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ForumView(socialManager: SocialMediaManager())
}

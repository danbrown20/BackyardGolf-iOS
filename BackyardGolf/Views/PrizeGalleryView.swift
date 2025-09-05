//
//  PrizeGalleryView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct PrizeGalleryView: View {
    @ObservedObject var prizeManager: PrizeManager
    @State private var selectedCategory: Prize.PrizeCategory? = nil
    @State private var selectedTier: Prize.PrizeTier? = nil
    @State private var showingPrizeDetail = false
    @State private var selectedPrize: Prize?
    @State private var showingARTrophies = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with user's prize stats
                PrizeStatsHeaderView(prizeManager: prizeManager)
                
                // Filter controls
                PrizeFilterView(
                    selectedCategory: $selectedCategory,
                    selectedTier: $selectedTier
                )
                
                // Prizes grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(filteredPrizes, id: \.id) { prize in
                            PrizeCardView(prize: prize) {
                                selectedPrize = prize
                                showingPrizeDetail = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Prize Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingARTrophies = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arkit")
                            Text("AR")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                }
            }
            .sheet(isPresented: $showingPrizeDetail) {
                if let prize = selectedPrize {
                    PrizeDetailView(prize: prize, prizeManager: prizeManager)
                }
            }
            .sheet(isPresented: $showingARTrophies) {
                ARTrophyView(prizeManager: prizeManager)
            }
        }
    }
    
    private var filteredPrizes: [Prize] {
        var prizes = prizeManager.availablePrizes
        
        if let category = selectedCategory {
            prizes = prizes.filter { $0.category == category }
        }
        
        if let tier = selectedTier {
            prizes = prizes.filter { $0.tier == tier }
        }
        
        return prizes
    }
}

// MARK: - Prize Stats Header

struct PrizeStatsHeaderView: View {
    @ObservedObject var prizeManager: PrizeManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Total prize value
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Prize Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.0f", prizeManager.getTotalPrizeValue()))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Unclaimed Prizes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(prizeManager.getUnclaimedPrizeCount())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            
            // Prize breakdown
            HStack(spacing: 20) {
                PrizeStatItem(
                    title: "Available",
                    value: "\(prizeManager.availablePrizes.count)",
                    color: .blue
                )
                
                PrizeStatItem(
                    title: "Earned",
                    value: "\(prizeManager.userPrizes.count)",
                    color: .green
                )
                
                PrizeStatItem(
                    title: "Claimed",
                    value: "\(prizeManager.getUserPrizesByStatus(.claimed).count)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct PrizeStatItem: View {
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

// MARK: - Prize Filter

struct PrizeFilterView: View {
    @Binding var selectedCategory: Prize.PrizeCategory?
    @Binding var selectedTier: Prize.PrizeTier?
    
    var body: some View {
        VStack(spacing: 12) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterButton(
                        title: "All Categories",
                        isSelected: selectedCategory == nil,
                        color: .blue
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(Prize.PrizeCategory.allCases, id: \.self) { category in
                        FilterButton(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            color: categoryColor(category)
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Tier filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterButton(
                        title: "All Tiers",
                        isSelected: selectedTier == nil,
                        color: .gray
                    ) {
                        selectedTier = nil
                    }
                    
                    ForEach(Prize.PrizeTier.allCases, id: \.self) { tier in
                        FilterButton(
                            title: tier.rawValue,
                            isSelected: selectedTier == tier,
                            color: tier.color
                        ) {
                            selectedTier = tier
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func categoryColor(_ category: Prize.PrizeCategory) -> Color {
        switch category {
        case .monetary: return .green
        case .equipment: return .blue
        case .membership: return .purple
        case .cosmetic: return .pink
        case .education: return .orange
        case .experience: return .yellow
        case .special: return .red
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
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
                        .fill(isSelected ? color : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Prize Card

struct PrizeCardView: View {
    let prize: Prize
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Prize icon with glow effect
                ZStack {
                    Circle()
                        .fill(prize.tier.glowColor)
                        .frame(width: 60, height: 60)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(prize.type.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: prize.imageURL)
                        .font(.title2)
                        .foregroundColor(prize.type.color)
                }
                
                // Prize info
                VStack(spacing: 6) {
                    Text(prize.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text("$\(String(format: "%.0f", prize.value))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    // Tier badge
                    Text(prize.tier.rawValue)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(prize.tier.color.opacity(0.2))
                        .foregroundColor(prize.tier.color)
                        .cornerRadius(8)
                }
                
                // Sponsor info
                if let sponsor = prize.sponsor {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        
                        Text(sponsor.name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Prize Detail View

struct PrizeDetailView: View {
    let prize: Prize
    @ObservedObject var prizeManager: PrizeManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Large prize icon
                    ZStack {
                        Circle()
                            .fill(prize.tier.glowColor)
                            .frame(width: 150, height: 150)
                            .blur(radius: 20)
                        
                        Circle()
                            .fill(prize.type.color.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: prize.imageURL)
                            .font(.system(size: 50))
                            .foregroundColor(prize.type.color)
                    }
                    
                    VStack(spacing: 20) {
                        Text(prize.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(prize.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Prize details
                        VStack(spacing: 15) {
                            HStack {
                                VStack {
                                    Text("Value")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("$\(String(format: "%.0f", prize.value))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("Type")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(prize.type.rawValue)
                                        .font(.headline)
                                        .foregroundColor(prize.type.color)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("Tier")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(prize.tier.rawValue)
                                        .font(.headline)
                                        .foregroundColor(prize.tier.color)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Sponsor info
                            if let sponsor = prize.sponsor {
                                VStack(spacing: 10) {
                                    HStack {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.blue)
                                        
                                        Text("Sponsored by")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(sponsor.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Text(sponsor.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            // Requirements
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Requirements")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("To earn this prize: \(formatRequirement(prize.requirements))")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Prize Details")
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
    
    private func formatRequirement(_ requirement: PrizeRequirement) -> String {
        switch requirement.type {
        case .tournamentWin:
            return "Win \(requirement.target) tournament\(requirement.target == 1 ? "" : "s")"
        case .accuracy:
            return "Achieve \(requirement.target)% accuracy"
        case .streak:
            return "Get a streak of \(requirement.target) successful shots"
        case .social:
            return "Add \(requirement.target) friends"
        case .improvement:
            return "Improve your score by \(requirement.target) points"
        case .leaderboard:
            return "Reach rank \(requirement.target) on the leaderboard"
        }
    }
}

#Preview {
    PrizeGalleryView(prizeManager: PrizeManager())
}

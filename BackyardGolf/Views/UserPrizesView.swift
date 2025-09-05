//
//  UserPrizesView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct UserPrizesView: View {
    @ObservedObject var prizeManager: PrizeManager
    @State private var selectedStatus: UserPrize.PrizeStatus? = nil
    @State private var showingPrizeClaim = false
    @State private var selectedUserPrize: UserPrize?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with prize summary
                UserPrizesHeaderView(prizeManager: prizeManager)
                
                // Status filter
                PrizeStatusFilterView(selectedStatus: $selectedStatus)
                
                // Prizes list
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredUserPrizes, id: \.id) { userPrize in
                            UserPrizeCardView(
                                userPrize: userPrize,
                                prize: getPrize(for: userPrize),
                                onClaim: {
                                    selectedUserPrize = userPrize
                                    showingPrizeClaim = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Prizes")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPrizeClaim) {
                if let userPrize = selectedUserPrize,
                   let prize = getPrize(for: userPrize) {
                    PrizeClaimView(userPrize: userPrize, prize: prize, prizeManager: prizeManager)
                }
            }
        }
    }
    
    private var filteredUserPrizes: [UserPrize] {
        if let status = selectedStatus {
            return prizeManager.userPrizes.filter { $0.status == status }
        }
        return prizeManager.userPrizes
    }
    
    private func getPrize(for userPrize: UserPrize) -> Prize? {
        return prizeManager.availablePrizes.first { $0.id == userPrize.prizeId }
    }
}

// MARK: - User Prizes Header

struct UserPrizesHeaderView: View {
    @ObservedObject var prizeManager: PrizeManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Total value
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
                    Text("Unclaimed")
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
                PrizeStatusItem(
                    title: "Unclaimed",
                    value: "\(prizeManager.getUserPrizesByStatus(.unclaimed).count)",
                    color: .orange
                )
                
                PrizeStatusItem(
                    title: "Claimed",
                    value: "\(prizeManager.getUserPrizesByStatus(.claimed).count)",
                    color: .green
                )
                
                PrizeStatusItem(
                    title: "Expired",
                    value: "\(prizeManager.getUserPrizesByStatus(.expired).count)",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct PrizeStatusItem: View {
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

// MARK: - Prize Status Filter

struct PrizeStatusFilterView: View {
    @Binding var selectedStatus: UserPrize.PrizeStatus?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatusFilterButton(
                    title: "All",
                    isSelected: selectedStatus == nil,
                    color: .blue
                ) {
                    selectedStatus = nil
                }
                
                ForEach(UserPrize.PrizeStatus.allCases, id: \.self) { status in
                    StatusFilterButton(
                        title: status.rawValue,
                        isSelected: selectedStatus == status,
                        color: statusColor(status)
                    ) {
                        selectedStatus = status
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private func statusColor(_ status: UserPrize.PrizeStatus) -> Color {
        switch status {
        case .unclaimed: return .orange
        case .claimed: return .green
        case .expired: return .red
        }
    }
}

struct StatusFilterButton: View {
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

// MARK: - User Prize Card

struct UserPrizeCardView: View {
    let userPrize: UserPrize
    let prize: Prize?
    let onClaim: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Prize icon
            if let prize = prize {
                ZStack {
                    Circle()
                        .fill(prize.tier.glowColor)
                        .frame(width: 50, height: 50)
                        .blur(radius: 6)
                    
                    Circle()
                        .fill(prize.type.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: prize.imageURL)
                        .font(.title3)
                        .foregroundColor(prize.type.color)
                }
            }
            
            // Prize info
            VStack(alignment: .leading, spacing: 6) {
                if let prize = prize {
                    Text(prize.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text("$\(String(format: "%.0f", prize.value))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                // Status and date
                HStack {
                    Text(userPrize.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Text("Awarded \(formatDate(userPrize.awardedDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action button
            if userPrize.status == .unclaimed {
                Button("Claim") {
                    onClaim()
                }
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else if userPrize.status == .claimed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
    
    private var statusColor: Color {
        switch userPrize.status {
        case .unclaimed: return .orange
        case .claimed: return .green
        case .expired: return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Prize Claim View

struct PrizeClaimView: View {
    let userPrize: UserPrize
    let prize: Prize
    @ObservedObject var prizeManager: PrizeManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Prize icon
                ZStack {
                    Circle()
                        .fill(prize.tier.glowColor)
                        .frame(width: 120, height: 120)
                        .blur(radius: 15)
                    
                    Circle()
                        .fill(prize.type.color.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: prize.imageURL)
                        .font(.system(size: 40))
                        .foregroundColor(prize.type.color)
                }
                
                VStack(spacing: 20) {
                    Text("Congratulations!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("You've earned:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(prize.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("$\(String(format: "%.0f", prize.value))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(prize.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Claim code
                VStack(spacing: 10) {
                    Text("Your Claim Code:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(userPrize.claimCode)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Claim button
                Button("Claim Prize") {
                    prizeManager.claimPrize(userPrize)
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(15)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Claim Prize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UserPrizesView(prizeManager: PrizeManager())
}

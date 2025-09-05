//
//  PrizeManager.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import Foundation
import SwiftUI

// MARK: - Prize Manager

class PrizeManager: ObservableObject {
    @Published var availablePrizes: [Prize] = []
    @Published var userPrizes: [UserPrize] = []
    @Published var activeTournaments: [Tournament] = []
    @Published var prizeHistory: [PrizeTransaction] = []
    @Published var sponsors: [Sponsor] = []
    @Published var showingPrizeClaim = false
    @Published var currentPrizeToClaim: Prize?
    
    private var userProfile: UserProfile?
    
    init() {
        loadAllPrizes()
        loadSponsors()
        setupMockTournaments()
    }
    
    // MARK: - Prize Definitions
    
    private func loadAllPrizes() {
        availablePrizes = [
            // MARK: - Cash Prizes
            Prize(
                id: "cash_100",
                name: "$100 Cash Prize",
                description: "Direct cash transfer to your account",
                value: 100.0,
                type: .cash,
                tier: .gold,
                category: .monetary,
                imageURL: "dollarsign.circle.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .tournamentWin, target: 1),
                sponsor: sponsors.first { $0.id == "sponsor_1" }
            ),
            
            Prize(
                id: "cash_500",
                name: "$500 Cash Prize",
                description: "Major tournament cash prize",
                value: 500.0,
                type: .cash,
                tier: .platinum,
                category: .monetary,
                imageURL: "dollarsign.circle.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .tournamentWin, target: 3),
                sponsor: sponsors.first { $0.id == "sponsor_1" }
            ),
            
            // MARK: - Golf Equipment
            Prize(
                id: "golf_balls_premium",
                name: "Premium Golf Ball Set",
                description: "12-pack of professional golf balls",
                value: 75.0,
                type: .physical,
                tier: .silver,
                category: .equipment,
                imageURL: "circle.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .accuracy, target: 85),
                sponsor: sponsors.first { $0.id == "sponsor_2" }
            ),
            
            Prize(
                id: "golf_clubs_set",
                name: "Professional Golf Club Set",
                description: "Complete set of premium golf clubs",
                value: 1200.0,
                type: .physical,
                tier: .platinum,
                category: .equipment,
                imageURL: "sportscourt.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .tournamentWin, target: 5),
                sponsor: sponsors.first { $0.id == "sponsor_2" }
            ),
            
            // MARK: - Digital Rewards
            Prize(
                id: "premium_membership",
                name: "Premium App Membership",
                description: "1-year premium membership with exclusive features",
                value: 50.0,
                type: .digital,
                tier: .gold,
                category: .membership,
                imageURL: "crown.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .streak, target: 10),
                sponsor: sponsors.first { $0.id == "sponsor_3" }
            ),
            
            Prize(
                id: "exclusive_avatar",
                name: "Exclusive Avatar Frame",
                description: "Limited edition avatar frame for your profile",
                value: 25.0,
                type: .digital,
                tier: .silver,
                category: .cosmetic,
                imageURL: "person.circle.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .social, target: 5),
                sponsor: sponsors.first { $0.id == "sponsor_3" }
            ),
            
            // MARK: - Experience Prizes
            Prize(
                id: "golf_lesson",
                name: "Professional Golf Lesson",
                description: "1-hour lesson with a PGA professional",
                value: 150.0,
                type: .experience,
                tier: .gold,
                category: .education,
                imageURL: "graduationcap.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .improvement, target: 20),
                sponsor: sponsors.first { $0.id == "sponsor_4" }
            ),
            
            Prize(
                id: "golf_course_voucher",
                name: "Golf Course Voucher",
                description: "Free round at a premium golf course",
                value: 200.0,
                type: .experience,
                tier: .platinum,
                category: .experience,
                imageURL: "leaf.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .tournamentWin, target: 2),
                sponsor: sponsors.first { $0.id == "sponsor_4" }
            ),
            
            // MARK: - Special Prizes
            Prize(
                id: "meet_pro_golfer",
                name: "Meet & Greet with Pro Golfer",
                description: "Exclusive meet and greet with a professional golfer",
                value: 500.0,
                type: .experience,
                tier: .legendary,
                category: .special,
                imageURL: "star.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .tournamentWin, target: 10),
                sponsor: sponsors.first { $0.id == "sponsor_5" }
            ),
            
            Prize(
                id: "golf_tournament_tickets",
                name: "PGA Tournament Tickets",
                description: "VIP tickets to a major PGA tournament",
                value: 800.0,
                type: .experience,
                tier: .legendary,
                category: .special,
                imageURL: "ticket.fill",
                isClaimed: false,
                requirements: PrizeRequirement(type: .leaderboard, target: 1),
                sponsor: sponsors.first { $0.id == "sponsor_5" }
            )
        ]
    }
    
    private func loadSponsors() {
        sponsors = [
            Sponsor(
                id: "sponsor_1",
                name: "BackyardGolf Pro",
                logo: "building.2.fill",
                description: "Premium golf equipment and accessories",
                website: "backyardgolfpro.com",
                isVerified: true
            ),
            
            Sponsor(
                id: "sponsor_2",
                name: "Eagle Eye Golf",
                logo: "eye.fill",
                description: "Professional golf equipment manufacturer",
                website: "eagleeyegolf.com",
                isVerified: true
            ),
            
            Sponsor(
                id: "sponsor_3",
                name: "BackyardGolf",
                logo: "app.fill",
                description: "Official BackyardGolf app rewards",
                website: "backyardgolf.app",
                isVerified: true
            ),
            
            Sponsor(
                id: "sponsor_4",
                name: "Green Valley Golf Academy",
                logo: "graduationcap.fill",
                description: "Professional golf instruction and courses",
                website: "greenvalleygolf.com",
                isVerified: true
            ),
            
            Sponsor(
                id: "sponsor_5",
                name: "PGA Tour",
                logo: "trophy.fill",
                description: "Official PGA Tour experiences",
                website: "pgatour.com",
                isVerified: true
            )
        ]
    }
    
    private func setupMockTournaments() {
        activeTournaments = [
            Tournament(
                id: "tournament_1",
                name: "Weekly Championship",
                description: "Weekly tournament with cash prizes",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                entryFee: 10.0,
                prizePool: 500.0,
                maxParticipants: 50,
                participants: [],
                isActive: true,
                gameMode: .tournament,
                prizeDistribution: [
                    PrizeDistribution(rank: 1, percentage: 0.5, prize: availablePrizes.first { $0.id == "cash_100" }),
                    PrizeDistribution(rank: 2, percentage: 0.3, prize: availablePrizes.first { $0.id == "golf_balls_premium" }),
                    PrizeDistribution(rank: 3, percentage: 0.2, prize: availablePrizes.first { $0.id == "exclusive_avatar" })
                ],
                sponsor: sponsors.first { $0.id == "sponsor_1" }
            ),
            
            Tournament(
                id: "tournament_2",
                name: "Monthly Masters",
                description: "Monthly tournament with premium prizes",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                entryFee: 25.0,
                prizePool: 2000.0,
                maxParticipants: 100,
                participants: [],
                isActive: true,
                gameMode: .tournament,
                prizeDistribution: [
                    PrizeDistribution(rank: 1, percentage: 0.4, prize: availablePrizes.first { $0.id == "cash_500" }),
                    PrizeDistribution(rank: 2, percentage: 0.25, prize: availablePrizes.first { $0.id == "golf_lesson" }),
                    PrizeDistribution(rank: 3, percentage: 0.15, prize: availablePrizes.first { $0.id == "golf_course_voucher" }),
                    PrizeDistribution(rank: 4, percentage: 0.1, prize: availablePrizes.first { $0.id == "premium_membership" }),
                    PrizeDistribution(rank: 5, percentage: 0.1, prize: availablePrizes.first { $0.id == "golf_balls_premium" })
                ],
                sponsor: sponsors.first { $0.id == "sponsor_2" }
            )
        ]
    }
    
    // MARK: - Prize Management
    
    func updateUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
        checkPrizeEligibility()
    }
    
    func checkPrizeEligibility() {
        guard let profile = userProfile else { return }
        
        for i in 0..<availablePrizes.count {
            let prize = availablePrizes[i]
            if !prize.isClaimed && !userPrizes.contains(where: { $0.prizeId == prize.id }) {
                let isEligible = checkPrizeRequirement(prize.requirements, profile: profile)
                if isEligible {
                    awardPrize(prize)
                }
            }
        }
    }
    
    private func checkPrizeRequirement(_ requirement: PrizeRequirement, profile: UserProfile) -> Bool {
        switch requirement.type {
        case .tournamentWin:
            return profile.tournamentWins >= requirement.target
        case .accuracy:
            return Int(profile.bestAccuracy * 100) >= requirement.target
        case .streak:
            return profile.longestStreak >= requirement.target
        case .social:
            return profile.friendsCount >= requirement.target
        case .improvement:
            // Simulate improvement calculation
            return profile.bestScore >= requirement.target
        case .leaderboard:
            // Check if user is in top N of leaderboard
            return requirement.target == 1 // Simplified for demo
        }
    }
    
    private func awardPrize(_ prize: Prize) {
        let userPrize = UserPrize(
            id: UUID().uuidString,
            prizeId: prize.id,
            userId: userProfile?.id ?? "",
            awardedDate: Date(),
            status: .unclaimed,
            claimCode: generateClaimCode()
        )
        
        userPrizes.append(userPrize)
        
        // Add to prize history
        let transaction = PrizeTransaction(
            id: UUID().uuidString,
            userId: userProfile?.id ?? "",
            prizeId: prize.id,
            type: .awarded,
            amount: prize.value,
            timestamp: Date(),
            description: "Prize awarded: \(prize.name)"
        )
        prizeHistory.insert(transaction, at: 0)
        
        print("🏆 Prize awarded: \(prize.name)")
    }
    
    func claimPrize(_ userPrize: UserPrize) {
        guard let index = userPrizes.firstIndex(where: { $0.id == userPrize.id }) else { return }
        
        userPrizes[index].status = .claimed
        userPrizes[index].claimedDate = Date()
        
        // Add to prize history
        if let prize = availablePrizes.first(where: { $0.id == userPrize.prizeId }) {
            let transaction = PrizeTransaction(
                id: UUID().uuidString,
                userId: userProfile?.id ?? "",
                prizeId: prize.id,
                type: .claimed,
                amount: prize.value,
                timestamp: Date(),
                description: "Prize claimed: \(prize.name)"
            )
            prizeHistory.insert(transaction, at: 0)
        }
        
        print("✅ Prize claimed: \(userPrize.id)")
    }
    
    func joinTournament(_ tournament: Tournament) {
        guard let profile = userProfile else { return }
        
        if let index = activeTournaments.firstIndex(where: { $0.id == tournament.id }) {
            let player = Player(
                id: profile.id,
                username: profile.username,
                avatar: profile.avatar
            )
            
            if !activeTournaments[index].participants.contains(where: { $0.id == profile.id }) {
                activeTournaments[index].participants.append(player)
                
                // Add transaction for entry fee
                let transaction = PrizeTransaction(
                    id: UUID().uuidString,
                    userId: profile.id,
                    prizeId: "",
                    type: .entryFee,
                    amount: -tournament.entryFee,
                    timestamp: Date(),
                    description: "Tournament entry fee: \(tournament.name)"
                )
                prizeHistory.insert(transaction, at: 0)
                
                print("🎯 Joined tournament: \(tournament.name)")
            }
        }
    }
    
    func distributeTournamentPrizes(_ tournament: Tournament) {
        let sortedParticipants = tournament.participants.sorted { $0.score > $1.score }
        
        for (index, distribution) in tournament.prizeDistribution.enumerated() {
            if index < sortedParticipants.count {
                let winner = sortedParticipants[index]
                
                if let prize = distribution.prize {
                    let userPrize = UserPrize(
                        id: UUID().uuidString,
                        prizeId: prize.id,
                        userId: winner.id,
                        awardedDate: Date(),
                        status: .unclaimed,
                        claimCode: generateClaimCode()
                    )
                    
                    userPrizes.append(userPrize)
                    
                    // Add to prize history
                    let transaction = PrizeTransaction(
                        id: UUID().uuidString,
                        userId: winner.id,
                        prizeId: prize.id,
                        type: .tournamentWin,
                        amount: prize.value,
                        timestamp: Date(),
                        description: "Tournament win: \(tournament.name) - Rank \(distribution.rank)"
                    )
                    prizeHistory.insert(transaction, at: 0)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateClaimCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in characters.randomElement()! })
    }
    
    func getPrizesByCategory(_ category: Prize.PrizeCategory) -> [Prize] {
        return availablePrizes.filter { $0.category == category }
    }
    
    func getUserPrizesByStatus(_ status: UserPrize.PrizeStatus) -> [UserPrize] {
        return userPrizes.filter { $0.status == status }
    }
    
    func getTotalPrizeValue() -> Double {
        return userPrizes.compactMap { userPrize in
            availablePrizes.first { $0.id == userPrize.prizeId }?.value
        }.reduce(0, +)
    }
    
    func getUnclaimedPrizeCount() -> Int {
        return userPrizes.filter { $0.status == .unclaimed }.count
    }
}

// MARK: - Enhanced Prize Models

struct Prize: Identifiable {
    let id: String
    let name: String
    let description: String
    let value: Double
    let type: PrizeType
    let tier: PrizeTier
    let category: PrizeCategory
    let imageURL: String
    var isClaimed: Bool
    let requirements: PrizeRequirement
    let sponsor: Sponsor?
    
    enum PrizeType: String, CaseIterable {
        case cash = "Cash"
        case physical = "Physical"
        case digital = "Digital"
        case experience = "Experience"
        
        var icon: String {
            switch self {
            case .cash: return "dollarsign.circle.fill"
            case .physical: return "shippingbox.fill"
            case .digital: return "laptopcomputer"
            case .experience: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .cash: return .green
            case .physical: return .blue
            case .digital: return .purple
            case .experience: return .orange
            }
        }
    }
    
    enum PrizeTier: String, CaseIterable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        case platinum = "Platinum"
        case legendary = "Legendary"
        
        var color: Color {
            switch self {
            case .bronze: return .brown
            case .silver: return .gray
            case .gold: return .yellow
            case .platinum: return .blue
            case .legendary: return .purple
            }
        }
        
        var glowColor: Color {
            switch self {
            case .bronze: return .brown.opacity(0.3)
            case .silver: return .gray.opacity(0.3)
            case .gold: return .yellow.opacity(0.4)
            case .platinum: return .blue.opacity(0.4)
            case .legendary: return .purple.opacity(0.5)
            }
        }
    }
    
    enum PrizeCategory: String, CaseIterable {
        case monetary = "Monetary"
        case equipment = "Equipment"
        case membership = "Membership"
        case cosmetic = "Cosmetic"
        case education = "Education"
        case experience = "Experience"
        case special = "Special"
        
        var icon: String {
            switch self {
            case .monetary: return "dollarsign.circle.fill"
            case .equipment: return "sportscourt.fill"
            case .membership: return "crown.fill"
            case .cosmetic: return "paintbrush.fill"
            case .education: return "graduationcap.fill"
            case .experience: return "star.fill"
            case .special: return "gift.fill"
            }
        }
    }
}

struct PrizeRequirement {
    let type: RequirementType
    let target: Int
    
    enum RequirementType {
        case tournamentWin
        case accuracy
        case streak
        case social
        case improvement
        case leaderboard
    }
}

struct UserPrize: Identifiable {
    let id: String
    let prizeId: String
    let userId: String
    let awardedDate: Date
    var status: PrizeStatus
    var claimedDate: Date?
    let claimCode: String
    
    enum PrizeStatus: String, CaseIterable {
        case unclaimed = "Unclaimed"
        case claimed = "Claimed"
        case expired = "Expired"
    }
}

struct PrizeTransaction: Identifiable {
    let id: String
    let userId: String
    let prizeId: String
    let type: TransactionType
    let amount: Double
    let timestamp: Date
    let description: String
    
    enum TransactionType: String, CaseIterable {
        case awarded = "Awarded"
        case claimed = "Claimed"
        case entryFee = "Entry Fee"
        case tournamentWin = "Tournament Win"
        case refund = "Refund"
    }
}

struct Sponsor: Identifiable {
    let id: String
    let name: String
    let logo: String
    let description: String
    let website: String
    let isVerified: Bool
}

struct Tournament: Identifiable {
    let id: String
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let entryFee: Double
    let prizePool: Double
    let maxParticipants: Int
    var participants: [Player]
    var isActive: Bool
    let gameMode: GameSession.GameMode
    let prizeDistribution: [PrizeDistribution]
    let sponsor: Sponsor?
}

struct PrizeDistribution {
    let rank: Int
    let percentage: Double
    let prize: Prize?
}

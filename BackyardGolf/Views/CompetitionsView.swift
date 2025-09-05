//
//  CompetitionsView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct CompetitionsView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showingCreateCompetition = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Active Competitions
                    ActiveCompetitionsSection(gameManager: gameManager)
                    
                    // Prize Pool
                    PrizePoolSection(prizeManager: gameManager.prizeManager)
                    
                    // Create Competition Button
                    CreateCompetitionButton(showingCreateCompetition: $showingCreateCompetition)
                }
                .padding()
            }
            .navigationTitle("Competitions")
            .sheet(isPresented: $showingCreateCompetition) {
                CreateCompetitionView(gameManager: gameManager)
            }
        }
    }
}

// MARK: - Active Competitions Section

struct ActiveCompetitionsSection: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Active Competitions")
                .font(.headline)
            
            if gameManager.prizeManager.activeTournaments.isEmpty {
                EmptyCompetitionsView()
            } else {
                ForEach(gameManager.prizeManager.activeTournaments, id: \.id) { tournament in
                    TournamentCard(tournament: tournament, gameManager: gameManager)
                }
            }
        }
    }
}

struct EmptyCompetitionsView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "trophy")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Active Competitions")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Create a new competition or wait for others to start one!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct TournamentCard: View {
    let tournament: Tournament
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tournament.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(tournament.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.0f", tournament.prizePool))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Prize Pool")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Tournament Details
            HStack {
                TournamentDetail(icon: "calendar", text: formatDate(tournament.startDate))
                Spacer()
                TournamentDetail(icon: "person.2", text: "\(tournament.participants.count)/\(tournament.maxParticipants)")
                Spacer()
                TournamentDetail(icon: "dollarsign.circle", text: "$\(String(format: "%.0f", tournament.entryFee))")
            }
            
            // Progress Bar
            ProgressView(value: Double(tournament.participants.count), total: Double(tournament.maxParticipants))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
            
            // Prize Distribution Preview
            if !tournament.prizeDistribution.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prize Distribution")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(tournament.prizeDistribution.prefix(3), id: \.rank) { distribution in
                            PrizeDistributionBadge(distribution: distribution)
                        }
                        
                        if tournament.prizeDistribution.count > 3 {
                            Text("+\(tournament.prizeDistribution.count - 3) more")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 10) {
                if tournament.participants.contains(where: { $0.id == gameManager.currentUser.id }) {
                    Button("View Details") {
                        // Navigate to tournament details
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                } else {
                    Button("Join Tournament") {
                        gameManager.prizeManager.joinTournament(tournament)
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Text(tournament.gameMode.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct TournamentDetail: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PrizeDistributionBadge: View {
    let distribution: PrizeDistribution
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(distribution.rank)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let prize = distribution.prize {
                Image(systemName: prize.imageURL)
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.blue)
        .cornerRadius(6)
    }
}

// MARK: - Prize Pool Section

struct PrizePoolSection: View {
    @ObservedObject var prizeManager: PrizeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Current Prize Pool")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("$\(String(format: "%.0f", getTotalPrizePool()))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Total Available Prizes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(getTotalParticipants())")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("Active Players")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
        }
    }
    
    private func getTotalPrizePool() -> Double {
        return prizeManager.activeTournaments.reduce(0) { $0 + $1.prizePool }
    }
    
    private func getTotalParticipants() -> Int {
        return prizeManager.activeTournaments.reduce(0) { $0 + $1.participants.count }
    }
}

// MARK: - Create Competition Button

struct CreateCompetitionButton: View {
    @Binding var showingCreateCompetition: Bool
    
    var body: some View {
        Button(action: {
            showingCreateCompetition = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Create New Competition")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
        }
    }
}

// MARK: - Create Competition View

struct CreateCompetitionView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var competitionName = ""
    @State private var competitionDescription = ""
    @State private var entryFee = ""
    @State private var maxParticipants = ""
    @State private var selectedGameMode = GameSession.GameMode.tournament
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Competition Details")) {
                    TextField("Competition Name", text: $competitionName)
                    TextField("Description", text: $competitionDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Settings")) {
                    TextField("Entry Fee ($)", text: $entryFee)
                        .keyboardType(.decimalPad)
                    
                    TextField("Max Participants", text: $maxParticipants)
                        .keyboardType(.numberPad)
                    
                    Picker("Game Mode", selection: $selectedGameMode) {
                        ForEach(GameSession.GameMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }
            }
            .navigationTitle("Create Competition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createCompetition()
                    }
                    .disabled(competitionName.isEmpty || entryFee.isEmpty)
                }
            }
        }
    }
    
    private func createCompetition() {
        // Create new competition logic here
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    CompetitionsView(gameManager: GameManager())
}

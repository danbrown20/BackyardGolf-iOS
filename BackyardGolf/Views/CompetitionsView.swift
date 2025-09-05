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
                    PrizePoolSection()
                    
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
            
            if gameManager.activeCompetitions.isEmpty {
                EmptyCompetitionsView()
            } else {
                ForEach(gameManager.activeCompetitions, id: \.id) { competition in
                    CompetitionCard(competition: competition, gameManager: gameManager)
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

struct CompetitionCard: View {
    let competition: Competition
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(competition.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(competition.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.0f", competition.prizePool))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Prize Pool")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Competition Details
            HStack {
                CompetitionDetail(icon: "calendar", text: formatDate(competition.startDate))
                Spacer()
                CompetitionDetail(icon: "person.2", text: "\(competition.participants.count)/\(competition.maxParticipants)")
                Spacer()
                CompetitionDetail(icon: "dollarsign.circle", text: "$\(String(format: "%.0f", competition.entryFee))")
            }
            
            // Progress Bar
            ProgressView(value: Double(competition.participants.count), total: Double(competition.maxParticipants))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
            
            // Action Buttons
            HStack(spacing: 10) {
                if competition.participants.contains(where: { $0.id == gameManager.currentUser.id }) {
                    Button("View Details") {
                        // Navigate to competition details
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                } else {
                    Button("Join Competition") {
                        gameManager.joinCompetition(competition)
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Text(competition.gameMode.rawValue)
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

struct CompetitionDetail: View {
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

// MARK: - Prize Pool Section

struct PrizePoolSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Current Prize Pool")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("$1,250")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Total Available Prizes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("47")
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

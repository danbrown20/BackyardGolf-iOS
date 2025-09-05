import SwiftUI

struct ARTrophyView: View {
    @ObservedObject var prizeManager: PrizeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTrophy: Prize?
    @State private var showingTrophySelection = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "arkit")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("AR Trophy Viewer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Coming Soon!")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Trophy showcase
                    if let trophy = selectedTrophy {
                        VStack(spacing: 20) {
                            Text("Selected Trophy")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(trophy.tier.color.opacity(0.3))
                                        .frame(width: 120, height: 120)
                                    
                                    Circle()
                                        .fill(trophy.type.color.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: trophy.imageURL)
                                        .font(.system(size: 40))
                                        .foregroundColor(trophy.type.color)
                                }
                                
                                Text(trophy.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text(trophy.tier.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                        }
                    } else {
                        VStack(spacing: 15) {
                            Text("No Trophy Selected")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Tap 'Select Trophy' to choose a trophy to view in AR")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            showingTrophySelection = true
                        }) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                Text("Select Trophy")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(15)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Close")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingTrophySelection) {
            TrophySelectionView(prizeManager: prizeManager, selectedTrophy: $selectedTrophy)
        }
    }
}

struct TrophySelectionView: View {
    @ObservedObject var prizeManager: PrizeManager
    @Binding var selectedTrophy: Prize?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(prizeManager.userPrizes, id: \.id) { userPrize in
                        trophyCard(for: userPrize)
                    }
                }
                .padding()
            }
            .navigationTitle("Select Trophy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 2)
    }
    
    @ViewBuilder
    private func trophyCard(for userPrize: UserPrize) -> some View {
        if let prize = prizeManager.availablePrizes.first(where: { $0.id == userPrize.prizeId }) {
            TrophySelectionCard(
                prize: prize,
                userPrize: userPrize,
                isSelected: selectedTrophy?.id == prize.id
            ) {
                selectedTrophy = prize
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct TrophySelectionCard: View {
    let prize: Prize
    let userPrize: UserPrize
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                trophyIcon
                trophyInfo
                selectionIndicator
            }
            .padding()
            .background(cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var trophyIcon: some View {
        ZStack {
            Circle()
                .fill(prize.tier.color.opacity(0.3))
                .frame(width: 80, height: 80)
            
            Circle()
                .fill(prize.type.color.opacity(0.2))
                .frame(width: 70, height: 70)
            
            Image(systemName: prize.imageURL)
                .font(.title)
                .foregroundColor(prize.type.color)
        }
    }
    
    private var trophyInfo: some View {
        VStack(spacing: 4) {
            Text(prize.name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(prize.tier.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Earned Prize")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var selectionIndicator: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

// MARK: - Preview
struct ARTrophyView_Previews: PreviewProvider {
    static var previews: some View {
        ARTrophyView(prizeManager: PrizeManager())
    }
}

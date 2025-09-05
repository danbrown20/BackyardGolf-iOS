//
//  ContentView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingGame = false
    
    var body: some View {
        if showingGame {
            GameView()
        } else {
            VStack(spacing: 30) {
                Text("🏌️‍♂️")
                    .font(.system(size: 80))
                
                Text("Backyard Golf")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Smart Golf Chipping Companion")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    FeatureRow(icon: "wifi", text: "Bluetooth & UWB Connectivity")
                    FeatureRow(icon: "lightbulb", text: "LED Light Control")
                    FeatureRow(icon: "trophy", text: "Competitions & Prizes")
                    FeatureRow(icon: "person.2", text: "Social Gaming")
                }
                .padding(.vertical)
                
                Button("Start Playing") {
                    showingGame = true
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            }
            .padding()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}

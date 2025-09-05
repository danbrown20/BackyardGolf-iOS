//
//  LEDControlView.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI

struct LEDControlView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // LED Status Card
                    LEDStatusCard(smartHole: gameManager.smartHole)
                    
                    // LED Controls
                    LEDControlsView(gameManager: gameManager)
                    
                    // Preset Colors
                    PresetColorsView(gameManager: gameManager)
                    
                    // Brightness Control
                    BrightnessControlView(gameManager: gameManager)
                    
                    // Special Effects
                    SpecialEffectsView(gameManager: gameManager)
                }
                .padding()
            }
            .navigationTitle("LED Control")
        }
    }
}

// MARK: - LED Status Card

struct LEDStatusCard: View {
    let smartHole: SmartHole
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Smart Hole LED Status")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(smartHole.isLEDOn ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    StatusRow(title: "Status", value: smartHole.isLEDOn ? "ON" : "OFF")
                    StatusRow(title: "Color", value: smartHole.ledColor.rawValue)
                    StatusRow(title: "Brightness", value: "\(Int(smartHole.ledBrightness * 100))%")
                    StatusRow(title: "Battery", value: "\(Int(smartHole.batteryLevel * 100))%")
                }
                
                Spacer()
                
                // Large LED Preview
                Circle()
                    .fill(smartHole.ledColor.color)
                    .frame(width: 80, height: 80)
                    .opacity(smartHole.isLEDOn ? smartHole.ledBrightness : 0.3)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                    )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - LED Controls

struct LEDControlsView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Basic Controls")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                // Power Toggle
                Button(action: {
                    gameManager.toggleLED()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: gameManager.smartHole.isLEDOn ? "lightbulb.fill" : "lightbulb")
                            .font(.title2)
                        Text(gameManager.smartHole.isLEDOn ? "Turn Off" : "Turn On")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(gameManager.smartHole.isLEDOn ? Color.red : Color.green)
                    .cornerRadius(10)
                }
                
                // Disconnect Button
                Button(action: {
                    gameManager.disconnectFromSmartHole()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                            .font(.title2)
                        Text("Disconnect")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - Preset Colors

struct PresetColorsView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Preset Colors")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                ForEach(SmartHole.LEDColor.allCases, id: \.self) { color in
                    ColorButton(
                        color: color,
                        isSelected: gameManager.smartHole.ledColor == color,
                        action: {
                            gameManager.setLEDColor(color)
                        }
                    )
                }
            }
        }
    }
}

struct ColorButton: View {
    let color: SmartHole.LEDColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color.color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.gray, lineWidth: isSelected ? 3 : 1)
                    )
                
                Text(color.rawValue)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}

// MARK: - Brightness Control

struct BrightnessControlView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Brightness Control")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 10) {
                HStack {
                    Text("0%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(gameManager.smartHole.ledBrightness * 100))%")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("100%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: Binding(
                        get: { gameManager.smartHole.ledBrightness },
                        set: { gameManager.setLEDBrightness($0) }
                    ),
                    in: 0...1
                )
                .accentColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Special Effects

struct SpecialEffectsView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Special Effects")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                EffectButton(
                    title: "Rainbow",
                    icon: "rainbow",
                    action: {
                        gameManager.setLEDColor(.rainbow)
                    }
                )
                
                EffectButton(
                    title: "Party Mode",
                    icon: "party.popper",
                    action: {
                        // This would trigger a special party mode effect
                        print("Party mode activated!")
                    }
                )
                
                EffectButton(
                    title: "Success Flash",
                    icon: "checkmark.circle",
                    action: {
                        // Flash green for successful shot
                        gameManager.setLEDColor(.green)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            gameManager.setLEDColor(.white)
                        }
                    }
                )
                
                EffectButton(
                    title: "Miss Flash",
                    icon: "xmark.circle",
                    action: {
                        // Flash red for missed shot
                        gameManager.setLEDColor(.red)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            gameManager.setLEDColor(.white)
                        }
                    }
                )
            }
        }
    }
}

struct EffectButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    LEDControlView(gameManager: GameManager())
}

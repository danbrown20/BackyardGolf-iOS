//
//  ESP32BluetoothManager.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import SwiftUI
import CoreBluetooth
import Combine

class ESP32BluetoothManager: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var signalStrength: Double = 0.0
    @Published var connectionStatus: String = "Disconnected"
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard let centralManager = centralManager, centralManager.state == .poweredOn else {
            print("❌ Bluetooth not available")
            return
        }
        
        isScanning = true
        connectionStatus = "Scanning..."
        print("🔍 Starting Bluetooth scan...")
        
        // Scan for ESP32 devices (you can customize the service UUIDs)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        // Stop scanning after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.stopScanning()
        }
    }
    
    func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
        if !isConnected {
            connectionStatus = "No devices found"
        }
        print("⏹️ Stopped scanning")
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
        connectionStatus = "Connecting..."
        print("🔗 Connecting to \(peripheral.name ?? "Unknown Device")")
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        connectedPeripheral = nil
        isConnected = false
        connectionStatus = "Disconnected"
        print("🔌 Disconnected")
    }
    
    // MARK: - LED Control Methods
    
    func setLEDColor(_ color: String) {
        guard isConnected else {
            print("❌ Not connected to device")
            return
        }
        
        print("🎨 Setting LED color to \(color)")
        // Send command to ESP32
        sendCommand("LED_COLOR:\(color)")
    }
    
    func setLEDPattern(_ pattern: String) {
        guard isConnected else {
            print("❌ Not connected to device")
            return
        }
        
        print("✨ Setting LED pattern to \(pattern)")
        // Send command to ESP32
        sendCommand("LED_PATTERN:\(pattern)")
    }
    
    func celebrationMode() {
        guard isConnected else {
            print("❌ Not connected to device")
            return
        }
        
        print("🎉 Starting celebration mode!")
        // Send celebration command to ESP32
        sendCommand("CELEBRATION")
    }
    
    func turnOffLED() {
        guard isConnected else {
            print("❌ Not connected to device")
            return
        }
        
        print("💡 Turning off LED")
        // Send turn off command to ESP32
        sendCommand("LED_OFF")
    }
    
    private func sendCommand(_ command: String) {
        // This would send the actual command to the ESP32
        // For now, we'll just simulate it
        print("📤 Sending command: \(command)")
        
        // Simulate command processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("✅ Command processed: \(command)")
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension ESP32BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth is powered on")
        case .poweredOff:
            print("❌ Bluetooth is powered off")
            isConnected = false
            connectionStatus = "Bluetooth Off"
        case .resetting:
            print("🔄 Bluetooth is resetting")
        case .unauthorized:
            print("❌ Bluetooth is unauthorized")
        case .unsupported:
            print("❌ Bluetooth is unsupported")
        case .unknown:
            print("❓ Bluetooth state is unknown")
        @unknown default:
            print("❓ Unknown Bluetooth state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Look for ESP32 devices (you can customize this)
        if let name = peripheral.name, name.contains("ESP32") || name.contains("BackyardGolf") {
            print("🎯 Found ESP32 device: \(name)")
            
            // Auto-connect to the first ESP32 device found
            if !isConnected {
                connect(to: peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown Device")")
        isConnected = true
        connectionStatus = "Connected"
        signalStrength = 1.0 // Simulate full signal
        
        // Stop scanning once connected
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        connectionStatus = "Connection Failed"
        isConnected = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔌 Disconnected from \(peripheral.name ?? "Unknown Device")")
        isConnected = false
        connectionStatus = "Disconnected"
        signalStrength = 0.0
    }
}

import CoreBluetooth
import Foundation
import SwiftUI

/// ESP32 Bluetooth Manager for Backyard Golf
/// Handles LED control and shot tracking via Bluetooth Low Energy
class ESP32BluetoothManager: NSObject, ObservableObject {
    
    // MARK: - Properties
    private var centralManager: CBCentralManager!
    private var esp32Peripheral: CBPeripheral?
    private var ledControlCharacteristic: CBCharacteristic?
    private var shotSensorCharacteristic: CBCharacteristic?
    
    // MARK: - Service UUIDs (Customize for your ESP32)
    private let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    private let ledControlUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    private let shotSensorUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a9")
    
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var ledStatus = false
    @Published var lastShotDetected: Date?
    @Published var shotCount = 0
    @Published var connectionStatus = "Disconnected"
    @Published var rssi: NSNumber = 0
    
    // MARK: - Initialization
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    
    /// Start scanning for ESP32 devices
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            connectionStatus = "Bluetooth not available"
            return
        }
        
        isScanning = true
        connectionStatus = "Scanning for ESP32..."
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        // Auto-stop scanning after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isScanning {
                self.stopScanning()
            }
        }
    }
    
    /// Stop scanning for devices
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        if !isConnected {
            connectionStatus = "ESP32 not found"
        }
    }
    
    /// Disconnect from ESP32
    func disconnect() {
        guard let peripheral = esp32Peripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    /// Toggle LED strips on/off
    func toggleLEDs() {
        guard isConnected, let characteristic = ledControlCharacteristic else {
            print("Cannot control LEDs: Not connected")
            return
        }
        
        let command = ledStatus ? "LED_OFF" : "LED_ON"
        sendCommand(command, to: characteristic)
        ledStatus.toggle()
    }
    
    /// Set LED color (RED, GREEN, BLUE, YELLOW, etc.)
    func setLEDColor(_ color: String) {
        guard isConnected, let characteristic = ledControlCharacteristic else { return }
        sendCommand("COLOR_\(color.uppercased())", to: characteristic)
    }
    
    /// Set LED pattern (PULSE, FLASH, RAINBOW, etc.)
    func setLEDPattern(_ pattern: String) {
        guard isConnected, let characteristic = ledControlCharacteristic else { return }
        sendCommand("PATTERN_\(pattern.uppercased())", to: characteristic)
    }
    
    /// Celebration pattern for successful shots
    func celebrationMode() {
        setLEDColor("GREEN")
        setLEDPattern("FLASH")
        
        // Return to normal after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.setLEDPattern("SOLID")
        }
    }
    
    // MARK: - Private Methods
    
    private func sendCommand(_ command: String, to characteristic: CBCharacteristic) {
        guard let data = command.data(using: .utf8) else { return }
        esp32Peripheral?.writeValue(data, for: characteristic, type: .withResponse)
        print("Sent command: \(command)")
    }
}

// MARK: - CBCentralManagerDelegate
extension ESP32BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionStatus = "Bluetooth ready"
        case .poweredOff:
            connectionStatus = "Turn on Bluetooth"
        case .unauthorized:
            connectionStatus = "Bluetooth access denied"
        case .unsupported:
            connectionStatus = "Bluetooth not supported"
        default:
            connectionStatus = "Bluetooth unavailable"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Found ESP32: \(peripheral.name ?? "Unknown") - RSSI: \(RSSI)")
        
        self.rssi = RSSI
        esp32Peripheral = peripheral
        connectionStatus = "ESP32 found, connecting..."
        centralManager.connect(peripheral, options: nil)
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to ESP32!")
        
        isConnected = true
        connectionStatus = "Connected to ESP32"
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        connectionStatus = "Connection failed"
        isConnected = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from ESP32")
        isConnected = false
        connectionStatus = "Disconnected"
        esp32Peripheral = nil
        ledControlCharacteristic = nil
        shotSensorCharacteristic = nil
    }
}

// MARK: - CBPeripheralDelegate
extension ESP32BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([ledControlUUID, shotSensorUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            switch characteristic.uuid {
            case ledControlUUID:
                ledControlCharacteristic = characteristic
                print("✅ LED Control ready")
                
            case shotSensorUUID:
                shotSensorCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("✅ Shot Sensor ready")
                
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic.uuid == shotSensorUUID {
            guard let data = characteristic.value,
                  let message = String(data: data, encoding: .utf8) else { return }
            
            if message.contains("SHOT_DETECTED") {
                DispatchQueue.main.async {
                    self.lastShotDetected = Date()
                    self.shotCount += 1
                    print("🏌️ Shot #\(self.shotCount) detected!")
                    
                    // Trigger celebration
                    self.celebrationMode()
                }
            }
        }
    }
}

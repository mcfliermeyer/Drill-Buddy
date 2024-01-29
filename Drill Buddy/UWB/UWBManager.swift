//
//  UWBManager.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 1/8/24.
//

import Foundation
import EstimoteUWB

class UWBManager: ObservableObject, EstimoteUWBManagerDelegate {
    
    @Published var uwbDevices: [String: EstimoteUWBDevice] = [:]
    private var uwbManager: EstimoteUWBManager?
    private var vector: Vector?
    private var distance: Float?
    
    
    var shouldConnectAutomatically: Bool {
        return true
    }
    
    init() {
        uwbManager = EstimoteUWBManager(delegate: self, options: EstimoteUWBOptions(shouldHandleConnectivity: true, isCameraAssisted: false))
        uwbManager?.startScanning()
    }
    
    
    func didConnect(to device: UWBIdentifiable) {
        print("Connected to: \(device.publicIdentifier)")
        uwbDevices[device.publicIdentifier] = device as? EstimoteUWBDevice
    }
    
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        //
    }
    
    func didUpdatePosition(for device: EstimoteUWB.EstimoteUWBDevice) {
        
        self.vector = device.vector
        self.distance = device.distance
        
    }
    
    func getVectorAndDistance() -> (Vector?, Float?) {
        return (self.vector, self.distance)
    }
    
    func didRange(for beacon: EstimoteBLEDevice) {
        //
    }

    func didDisconnect(from device: UWBIdentifiable, error: (Error)?) {
        //
    }
    
    func didFailToConnect(to device: UWBIdentifiable, error: (Error)?) {
        //
    }
    
}

//
//  UWBManagerExample.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 11/16/23.
//

import Foundation
import EstimoteUWB

class UWBManagerExample: ObservableObject, EstimoteUWBManagerDelegate {
    
    @Published var uwbDevices: [String: EstimoteUWBDevice] = [:]
    private var uwbManager: EstimoteUWBManager?
    
    
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
        let distance = device.distance.formatDistanceString()
        print("id: \(device.id)")
        print("distance: \(distance)")
        guard let vector = device.vector else { return }
        print("Vector: \(vector)")
        
//        need to translate vector to estimated distance left right up down
//        also lets try to not use estimote library 
        
        
        guard let verticalDirection = device.verticalDirectionEstimate else { return }
        print("VerticalDirectionEstimate: \(verticalDirection)")
        guard let horizontalAngle = device.horizontalAngle else { return }
        print("angle: \(horizontalAngle))")
        
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

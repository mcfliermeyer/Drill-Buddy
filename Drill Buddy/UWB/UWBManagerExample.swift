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
        let distance = formatDistanceString(from: device.distance)
        print("id: \(device.id)")
        print("distance: \(distance)")
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
    
    func formatDistanceString(from distance: Float) -> String{
        
        let meters = Measurement(value: Double(distance), unit: UnitLength.meters)
        
        let feetFloorDouble = floor(meters.converted(to: .feet).value)
        let feet = Measurement(value: feetFloorDouble, unit: UnitLength.feet)
        
        let inchFloorDouble = floor((meters - feet).converted(to: .inches).value)
        let inches = Measurement(value: inchFloorDouble, unit: UnitLength.inches)
        
        let decimal = (meters - feet - inches).converted(to: .inches)
        let fractionalInch = decimal.convertDecimalToFraction()
        
        return "\(Int(feet.value))\'\(Int(inches.value))\(fractionalInch.symbol)"
    }
    
    
}

//
//  MeasureLine.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/9/23.
//

import RealityKit
import UIKit

class MeasureLine: Entity, HasAnchoring, NSCopying {
    
    var startTransform, stopTransform: Transform
    
    let startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    let stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    
    let measurementBubble = MeasurementBubble(length: 0.15, color: .white)
    
    var distance: Float = 0
    
    var mesh: MeshResource = .generateSphere(radius: 0)
    let lineMaterial = UnlitMaterial(color: .white.withAlphaComponent(0.5))
    var lineEntity = ModelEntity()
    
    static var isMeasuring = false
    
    var measurementText = ""
    
    init(startTransform: Transform, stopTransform: Transform) {
        
        self.startTransform = startTransform
        self.stopTransform = stopTransform
        super.init()
        
        let startPosition = startTransform.translation
        let stopPosition = stopTransform.translation
        
        let midpoint = (startPosition + stopPosition) / 2
        
        //set own anchor midpoint
        self.position = midpoint
        self.look(at: startPosition, from: midpoint, relativeTo: nil)
        
        distance = simd_distance(startPosition, stopPosition)
        
        mesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: distance)
        
        lineEntity = ModelEntity(mesh: mesh, materials: [lineMaterial])
        lineEntity.position = .init(x: 0, y: 0, z: 0)
        
        startSphere.transform = startTransform
        stopSphere.transform = stopTransform
        
        self.measurementBubble.position.y = 10
        
        lineEntity.addChild(measurementBubble)
        
        self.addChild(lineEntity)
        
        measurementBubble.billBoard(newStartPosition: stopPosition, midpoint: midpoint)
        
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = MeasureLine(startTransform: startTransform, stopTransform: stopTransform)
        
        let startPosition = startTransform.translation
        let stopPosition = stopTransform.translation
        
        let midpoint = (startPosition + stopPosition) / 2

        copy.look(at: startPosition, from: midpoint, relativeTo: nil)
        
        let distance = simd_distance(startPosition, stopPosition)
        
        let mesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: distance)
        
        let lineEntity = ModelEntity(mesh: mesh, materials: [copy.lineMaterial])
        lineEntity.position = .init(x: 0, y: 0, z: 0)
        
        copy.startSphere.transform = copy.startTransform
        copy.stopSphere.transform = copy.stopTransform
        
        copy.addChild(lineEntity)
        copy.addChild(copy.startSphere)
        copy.stopMeasuring()
        
        copy.measurementBubble.position = self.measurementBubble.position
//        copy.measurementBubble.bubbleText.changeText(text: self.measurementText)
        
        copy.measurementBubble.transform = measurementBubble.transform
        
        return copy
        
    }
    
    func changeLineTransform(with newStartTransform: Transform, newStopTransform: Transform) {
        
        startTransform = newStartTransform
        stopTransform = newStopTransform
        
        let newStartPosition = startTransform.translation
        let newStopPosition = stopTransform.translation
        
        
        let midpoint = (newStartPosition + newStopPosition) / 2
        
        self.position = midpoint
        self.look(at: newStartPosition, from: midpoint, relativeTo: nil)
        
        distance = simd_distance(newStartPosition, newStopPosition)
        
        startSphere.transform = newStartTransform
        stopSphere.transform = newStopTransform
        
        let replaceMesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: distance)
        let _ = mesh.replaceAsync(with: replaceMesh.contents)
        
        measurementText = formatDistanceString(from: distance)
        
        self.measurementBubble.position = midpoint
//        self.measurementBubble.bubbleText.changeText(text: measurementText)
        
        measurementBubble.billBoard(newStartPosition: newStopPosition, midpoint: midpoint)
        
        
    }
    
    func startMeasuring() {
        MeasureLine.isMeasuring = true
        self.addChild(startSphere)
    }
    
    func stopMeasuring() {
        MeasureLine.isMeasuring = false
        self.addChild(stopSphere)
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
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


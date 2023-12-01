//
//  MeasureLine.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/9/23.
//

import RealityKit
import UIKit

class MeasureLine: Entity, HasAnchoring, NSCopying {
    
    let startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    let stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    
    let measurementBubble = MeasurementBubble(length: 0.15, color: .white)
    
    var mesh: MeshResource = .generateSphere(radius: 0)
    let lineMaterial = UnlitMaterial(color: .white.withAlphaComponent(0.5))
    
    static var isMeasuring = false
    
    var measurementText = ""
    
    init(startTransform: Transform, stopTransform: Transform) {
        super.init()
        
        let startPosition = startTransform.translation
        let stopPosition = stopTransform.translation
        let midpointPosition = (startPosition + stopPosition) / 2
        
        //set own anchor midpoint
        self.position = midpointPosition
        self.look(at: startPosition, from: midpointPosition, relativeTo: nil)
        startSphere.transform = startTransform
        stopSphere.transform = stopTransform
        
        mesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: simd_distance(startPosition, stopPosition))
        let lineEntity = ModelEntity(mesh: mesh, materials: [lineMaterial])
        lineEntity.name = "lineEntity"
        lineEntity.position = .init(x: 0, y: 0, z: 0)
        
        measurementBubble.position.y = 10
        
        lineEntity.addChild(measurementBubble)
        
        self.addChild(lineEntity)
        
        measurementBubble.billBoard(newStartPosition: stopPosition, midpoint: midpointPosition)
        
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = MeasureLine(startTransform: self.startSphere.transform, stopTransform: self.stopSphere.transform)
        
        let startPosition = self.startSphere.transform.translation
        let stopPosition = self.stopSphere.transform.translation
        let midpoint = (startPosition + stopPosition) / 2

        copy.look(at: startPosition, from: midpoint, relativeTo: nil)
        
        let mesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: simd_distance(startPosition, stopPosition))
        
        let lineEntity = ModelEntity(mesh: mesh, materials: [copy.lineMaterial])
        lineEntity.position = .init(x: 0, y: 0, z: 0)
        
        copy.addChild(lineEntity)
        copy.addChild(copy.startSphere)
        copy.stopMeasuring()
        
        copy.measurementBubble.position = self.measurementBubble.position
        copy.measurementBubble.bubbleText.changeText(text: simd_distance(startPosition, stopPosition).formatDistanceString())
        
        copy.measurementBubble.transform = measurementBubble.transform
        
        return copy
        
    }
    
    func changeLineTransform(with newStartTransform: Transform, newStopTransform: Transform) {
        
        let newStartPosition = newStartTransform.translation
        let newStopPosition = newStopTransform.translation
        let midpoint = (newStartPosition + newStopPosition) / 2
        
        self.position = midpoint
        self.look(at: newStartPosition, from: midpoint, relativeTo: nil)
        
        startSphere.transform = newStartTransform
        stopSphere.transform = newStopTransform
        
        let replaceMesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: simd_distance(newStartPosition, newStopPosition))
        let _ = mesh.replaceAsync(with: replaceMesh.contents)
        
        self.measurementBubble.position = midpoint
        self.measurementBubble.bubbleText.changeText(text: simd_distance(newStartPosition, newStopPosition).formatDistanceString())
        
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
    
}


//
//  MeasureLine.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/9/23.
//

import RealityKit
import UIKit

class MeasureLine: Entity, HasAnchoring, NSCopying {
    
    var arView: ARView?
    var coordinatorsArchNode: ArchNode?
    var lineEntity: ModelEntity = ModelEntity()
    
    let startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    let stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    
    var midPoint: SIMD3<Float> {
        return (startSphere.position + stopSphere.position) / 2
    }
    var depth: Float {
        return simd_distance(startSphere.position, stopSphere.position)
    }
    
    let measurementBubble = MeasurementBubble(length: 0.15, color: .white)
    
    var mesh: MeshResource = .generateSphere(radius: 0)
    let lineMaterial = UnlitMaterial(color: .white.withAlphaComponent(0.5))
    
    static var isMeasuring = false
    
    init(startTransform: Transform, stopTransform: Transform) {
        
        super.init()
        
        self.startSphere.transform = startTransform
        self.stopSphere.transform = stopTransform
        
        let startVector = self.startSphere.transform.translation
        let endVector = self.stopSphere.transform.translation
        let lengthVector = simd_length(cross(startVector, endVector))
        let theta = atan2(lengthVector, dot(startVector, endVector))
        
        self.setPosition(self.midPoint, relativeTo: nil)
        
        let p1minusp2lol = abs(endVector - startVector)
        let crossProduct = p1minusp2lol
        
        mesh = MeshResource.generateBox(width: self.depth, height: 0.005, depth: 0.005)
        lineEntity = ModelEntity(mesh: mesh, materials: [lineMaterial])
        lineEntity.name = "lineEntity"
        lineEntity.position = .init(x: 0, y: 0, z: 0)
        lineEntity.orientation = .init(angle: theta, axis: crossProduct)
        print("init-LE: \(lineEntity.transform)")
        measurementBubble.position.y = 10

        lineEntity.addChild(measurementBubble)
        self.addChild(lineEntity)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        guard let archNode = coordinatorsArchNode else { return self }
        
        let copy = MeasureLine(startTransform: self.startSphere.transform, stopTransform: archNode.transform)
        
        copy.addChild(copy.startSphere)
        
        copy.stopMeasuring()
        copy.measurementBubble.bubbleText.changeText(text: self.measurementBubble.bubbleText.text)
        copy.measurementBubble.transform = measurementBubble.transform
        
        return copy
        
    }
    
    //as the 2DSphere turns, i think the measureline turns as well
    
    func changeLineTransform() {
        
        guard let archNode = coordinatorsArchNode else { return }

        self.stopSphere.transform = archNode.transform
        
        let startVector = self.startSphere.transform.translation
        let endVector = self.startSphere.transform.translation - midPoint
        let lengthVector = simd_length(cross(startSphere.position, archNode.position))
        let theta = atan2(lengthVector, dot(startVector, endVector))
        
        self.setPosition(self.midPoint, relativeTo: nil)
        
        
        let p1minusp2lol = abs(archNode.position - startSphere.position)
        let crossProduct = p1minusp2lol
        print("crossProduct: \(crossProduct)")
        print("theta: \(theta)")
        
        lineEntity.orientation = .init(angle: theta, axis: crossProduct)
        print(lineEntity.orientation)
        
        let replaceMesh = MeshResource.generateBox(width: self.depth, height: 0.005, depth: 0.005)
        let _ = mesh.replaceAsync(with: replaceMesh.contents)
        
        self.measurementBubble.bubbleText.changeText(text: self.depth.formatDistanceString())
        measurementBubble.look(at: startSphere.position, from: self.midPoint, relativeTo: nil)
        
    }
    
    func startMeasuring() {
        MeasureLine.isMeasuring = true
        startSphere.scale = SIMD3(x: 0.6, y: 0.6, z: 0.6)
        self.addChild(startSphere)
    }
    
    func stopMeasuring() {
        MeasureLine.isMeasuring = false
        stopSphere.scale = SIMD3(x: 0.6, y: 0.6, z: 0.6)
        self.addChild(stopSphere)
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
}


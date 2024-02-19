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
    var lineLookAnchor = AnchorEntity()
    var cameraLookAnchor = AnchorEntity()
    
    let startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    let stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    
    var midPoint: SIMD3<Float> {
        return (stopSphere.position(relativeTo: nil) + startSphere.position(relativeTo: nil)) / 2
    }
    var measureLineMiddlePosition: SIMD3<Float> {
        let startVector = startSphere.position(relativeTo: self)
        let endVector = stopSphere.position(relativeTo: self)
        return (startVector + endVector) / 2
    }
    
    var width: Float = 0.005
    var depth: Float {
        return simd_distance(startSphere.position(relativeTo: nil), stopSphere.position(relativeTo: nil))
    }
    var height: Float = 0.005
    
    let measurementBubble = MeasurementBubble(length: 0.15, color: .white)
    
    var mesh: MeshResource = .generateSphere(radius: 0)
    let lineMaterial = UnlitMaterial(color: .white.withAlphaComponent(0.5))
    
    static var isMeasuring = false
    
    init(startTransform: Transform, stopTransform: Transform) {
        
        super.init()
        
        self.startSphere.transform = startTransform
        self.stopSphere.transform = stopTransform
        let worldPositionMidpoint = (stopTransform.translation + startTransform.translation) / 2
        
        self.setPosition(worldPositionMidpoint, relativeTo: nil)
        
        mesh = MeshResource.generateBox(width: width, height: height, depth: depth)
        lineEntity = ModelEntity(mesh: mesh, materials: [lineMaterial])
        lineEntity.name = "lineEntity"
        lineEntity.position = measureLineMiddlePosition
        lineEntity.setOrientation(simd_quatf(from: startSphere.position(relativeTo: self), to: measureLineMiddlePosition), relativeTo: self)
        lineLookAnchor.setScale(SIMD3(x: 0.1, y: 0.1, z: 0.1), relativeTo: nil)
        self.addChild(measurementBubble)
        self.addChild(lineEntity)
        self.addChild(lineLookAnchor)
        self.addChild(cameraLookAnchor)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        guard let archNode = coordinatorsArchNode else { return self }
        
        let copy = MeasureLine(startTransform: self.startSphere.transform, stopTransform: archNode.transform)
        
        copy.addChild(copy.startSphere)
        copy.transform = self.transform
        copy.lineEntity.transform = self.lineEntity.transform
        
        copy.stopMeasuring()
        copy.measurementBubble.bubbleText.changeText(text: self.measurementBubble.bubbleText.text)
        copy.measurementBubble.transform = measurementBubble.transform
        
        return copy
        
    }
    
    func changeLineTransform() {
        
        guard let archNode = coordinatorsArchNode else { return }
        
        self.stopSphere.transform = archNode.transform//needed for line copy for multiple lines
        let stopLine = self.stopSphere.position(relativeTo: self)
        
        lineEntity.look(at: stopLine, from: measureLineMiddlePosition, upVector: SIMD3(x: 0, y: 0, z: 0), relativeTo: self)
        measurementBubble.bubbleText.changeText(text: depth.formatDistanceString())
        
        let bubblePos = measurementBubble.position(relativeTo: startSphere)
        if bubblePos.x > 0.03 {
            lineLookAnchor.look(at: startSphere.position, from: midPoint, upVector: SIMD3(x: 0, y: 1, z: 0), relativeTo: nil)
        }
        else if bubblePos.x <= 0.03 && bubblePos.x >= -0.03 {
            lineLookAnchor.look(at: startSphere.position, from: midPoint, upVector: SIMD3(x: 1, y: 0, z: 0), relativeTo: nil)
            if bubblePos.y > 0 {
                lineLookAnchor.transform.rotation *= simd_quatf(angle: 180.toRadian(), axis: SIMD3(x: 0, y: 0, z: 1))
                lineLookAnchor.transform.rotation *= simd_quatf(angle: 180.toRadian(), axis: SIMD3(x: 1, y: 0, z: 0))
            }
        }
        else {
            lineLookAnchor.look(at: startSphere.position, from: midPoint, upVector: SIMD3(x: 0, y: 1, z: 0), relativeTo: nil)
            lineLookAnchor.transform.rotation *= simd_quatf(angle: 180.toRadian(), axis: SIMD3(x: 0, y: 0, z: 1))
            lineLookAnchor.transform.rotation *= simd_quatf(angle: 180.toRadian(), axis: SIMD3(x: 1, y: 0, z: 0))
        }
        measurementBubble.move(to: lineLookAnchor.transform, relativeTo: nil, duration: 0.1)
        //X:1 as upvector = when +Y the bubble is flipped
        //Y:1 as upvector = when -X the bubble is flipped
        
        let replaceMesh = MeshResource.generateBox(width: width, height: height, depth: depth)
        let _ = mesh.replaceAsync(with: replaceMesh.contents)
        
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


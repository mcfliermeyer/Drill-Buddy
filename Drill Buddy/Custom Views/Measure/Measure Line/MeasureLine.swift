//
//  MeasureLine.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/9/23.
//

import RealityKit
import UIKit

class MeasureLine: Entity, HasAnchoring {
    
    let startTransform, stopTransform: Transform
    
    let startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    let stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    
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
        
        let distance = simd_distance(startPosition, stopPosition)
        
        let lineMaterial = UnlitMaterial(color: .white.withAlphaComponent(0.5))
        let mesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: distance)
        
        let lineEntity = ModelEntity(mesh: mesh, materials: [lineMaterial])
        lineEntity.position = .init(x: 0, y: 0, z: 0)
        
        startSphere.transform = startTransform
        stopSphere.transform = stopTransform
        
        self.addChild(lineEntity)
        self.addChild(startSphere)
        
    }
    
    func addStopSphere() {
        self.addChild(stopSphere)
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
}


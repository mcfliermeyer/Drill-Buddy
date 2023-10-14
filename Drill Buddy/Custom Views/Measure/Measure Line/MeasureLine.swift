//
//  MeasureLine.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/9/23.
//

import RealityKit
import UIKit

class MeasureLine: Entity, HasAnchoring {
    
    let startPosition, stopPosition: SIMD3<Float>
    
    var startSphere, stopSphere: TwoDimensionalSphere?
    
    init(startPosition: SIMD3<Float>, stopPosition: SIMD3<Float>) {
        
        self.startPosition = startPosition
        self.stopPosition = stopPosition
        super.init()
        
        let midpoint = (startPosition + stopPosition) / 2
        
        //set own anchor midpoint
        self.position = midpoint
        self.look(at: startPosition, from: midpoint, relativeTo: nil)
        
        let distance = simd_distance(startPosition, stopPosition)
        
        let lineMaterial = UnlitMaterial(color: .white.withAlphaComponent(0.5))
        let mesh = MeshResource.generateBox(width: 0.005, height: 0.005, depth: distance)
        
        let lineEntity = ModelEntity(mesh: mesh, materials: [lineMaterial])
        lineEntity.position = .init(x: 0, y: 0, z: 0)
        
        self.addChild(lineEntity)
        
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
}


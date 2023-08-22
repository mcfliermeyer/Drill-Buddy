//
//  ArchNode.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 8/2/23.
//

import RealityKit
import SceneKit
import ARKit

class ArchNode: Entity, HasAnchoring {
    
    let arView: ARView
    var radius: Float
    let color: UIColor
    let lineWidth: Float
    
    required init(arView: ARView, radius: Float, color: UIColor, lineWidth: Float) {
        self.arView = arView
        self.radius = radius
        self.color = color
        self.lineWidth = lineWidth
        super.init()
        
        self.displayGeometry(for: arView)
        
    }
    
    func changeRadius(radius: Float) {
        self.radius = radius
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
    private func displayGeometry(for arView: ARView) {
        
        var entities: [ModelEntity] = []
        
        for i in 0 ..< 4 {
            
            //the more triangles, the more round arcs will appear
            let (mesh, material) = drawArc(angle: 90, triangleDetailCount: 9)

            entities.append(ModelEntity(mesh: try! .generate(from: [mesh]), materials: [material]))
            
            //rotate each entity quadrant 90 degree for each loop
            entities[i].transform.rotation = simd_quatf(angle: (90 * i).toRadian(), axis: SIMD3(x: 0, y: 0, z: 1))
            
            self.addChild(entities[i])
            
        }
        
        self.name = "node_anchor"
        
        
        arView.scene.addAnchor(self)
        
    }
    
}

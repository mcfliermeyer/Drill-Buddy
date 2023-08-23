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
    
    var arcQuadrants: [ArchNodeQuadrant] = []
    
    required init() {
        super.init()
        let space: Float = 0.01
        
        for i in 0 ..< 4 {

            let quadrant = ArchNodeQuadrant(angle: 90, triangleDetailCount: 9, quadrant: i, radius: 0.8, color: .white, lineWidth: 0.05)
            
            self.addChild(quadrant)

            arcQuadrants.append(quadrant)

        }
        self.name = "archNode"
    }
    
    
    
}

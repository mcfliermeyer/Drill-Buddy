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
    
    required init() {
        super.init()
        
        for i in 0 ..< 4 {

            let quadrant = ArchNodeQuadrant(angle: 90, triangleDetailCount: 9, quadrant: i, radius: 0.8, color: .white, lineWidth: 0.04)
            
            self.addChild(quadrant)
        }
        
        let measurePoint = ArchNodePoint(triangleDetailCount: 50, radius: 0.1, color: .white)
        
        self.addChild(measurePoint)
        
    }
    
    func openAllQuadrants() {
        
        self.children.forEach{ entity in
            
            guard let quad = entity as? ArchNodeQuadrant else { return }
            quad.openQuadrant()
            
        }
        
    }
    
    func closeAllQuadrants() {
        
        self.children.forEach{ entity in
            
            guard let quad = entity as? ArchNodeQuadrant else { return }
            quad.closeQuadrant()
        }
        
    }
    
    
    
}

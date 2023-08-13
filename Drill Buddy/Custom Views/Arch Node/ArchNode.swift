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
    
    let quadrants: [ArchNode.Quadrant] = [
        ArchNode.Quadrant.topLeft(startAngleDegree: -182, endAngleDegree: -270),
        ArchNode.Quadrant.topRight(startAngleDegree: 84, endAngleDegree: 1),
        ArchNode.Quadrant.bottomLeft(startAngleDegree: -7, endAngleDegree: -89),
        ArchNode.Quadrant.bottomRight(startAngleDegree: -92, endAngleDegree: -176)
    ]
    
    
    
}

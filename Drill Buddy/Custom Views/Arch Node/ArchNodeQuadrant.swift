//
//  ArchNodeQuadrant.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 8/2/23.
//

import RealityKit
import SceneKit

extension ArchNode {
    
    enum Quadrant {
        case topLeft(startAngleDegree: Int, endAngleDegree: Int)
        case topRight(startAngleDegree: Int, endAngleDegree: Int)
        case bottomRight(startAngleDegree: Int, endAngleDegree: Int)
        case bottomLeft(startAngleDegree: Int, endAngleDegree: Int)
    }
    
}

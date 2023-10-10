//
//  MeasureButton.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/9/23.
//

import RealityKit
import SceneKit
import ARKit

class MeasureButton: Entity, HasAnchoring {
    
    var measurePoint: TwoDimensionalSphere?
    var radius: Float
    var color: UIColor
    var lineWidth: Float
    
    required init(measurePoint: TwoDimensionalSphere? = nil, radius: Float, color: UIColor, lineWidth: Float) {
        
        self.measurePoint = measurePoint
        self.radius = radius
        self.color = color
        self.lineWidth = lineWidth
        super.init()
        
        for i in 0 ..< 4 {

            let quadrant = ArchNodeQuadrant(angle: 90, triangleDetailCount: 9, quadrant: i, radius: self.radius, color: self.color, lineWidth: self.lineWidth)
            
            self.addChild(quadrant)
        }
        
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
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

//
//  2DSphere.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/9/23.
//

import RealityKit
import UIKit

class TwoDimensionalSphere: Entity, HasAnchoring, HasCollision {
    
    let triangleDetailCount: Int
    let radius: Float
    let color: UIColor
    
    init(triangleDetailCount: Int, radius: Float, color: UIColor) {
        
        self.triangleDetailCount = triangleDetailCount
        self.radius = radius
        self.color = color
        super.init()
        
        let (mesh, material) = self.drawCircle(with: triangleDetailCount, radius: radius, color: color)
        let model = ModelEntity(mesh: try! .generate(from: [mesh]), materials: [material])
        
        self.addChild(model)
        
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
    func drawCircle(with triangleDetailCount: Int, radius: Float, color: UIColor) -> (MeshDescriptor, PhysicallyBasedMaterial) {

        let triangleAngle: Float = (360 / Float(triangleDetailCount))
        
        let verticesCount = Int(triangleDetailCount + 1)
        
        var vertices: [SIMD3<Float>] {
            
            var vertex = [SIMD3<Float>]()
            
            for i in (0 ..< verticesCount) {
                
                let x = round(cos( (Float(i) * triangleAngle).toRadian()) * 100)/1000 * radius
                let y = round(sin( (Float(i) * triangleAngle).toRadian()) * 100)/1000 * radius
                vertex.append([x, y, 0])
                
            }
            //x and y have to be reduced to width of new arc line
            
            return vertex
        }//vertices
        
        var triangles: [UInt32] {
            
            var points: [UInt32] = Array(repeating: 0, count: (triangleDetailCount * 3))
            
            for i in (0 ..< triangleDetailCount) {

                points[3 * i + 0] = UInt32(0)
                points[3 * i + 1] = UInt32(i + 1)
                points[3 * i + 2] = UInt32(i + 2)
                
                if(i == triangleDetailCount - 1) {
                    points[3 * i + 2] = UInt32(1)
                }

            }
            return points
        }
        
        var material = PhysicallyBasedMaterial()
        material.emissiveColor = .init(color: color.withAlphaComponent(0.05))
        material.baseColor = .init(tint: color.withAlphaComponent(0.05))
        material.emissiveIntensity = 0.8
        
        var mesh = MeshDescriptor(name: "MeasurePoint")
        mesh.positions = MeshBuffer(vertices)
        mesh.primitives = .triangles(triangles)
        
        return (mesh, material)
    }
    
}

/**
 create sphere that when touched it goes where raycast is hitting but it animates its way over there.
 */

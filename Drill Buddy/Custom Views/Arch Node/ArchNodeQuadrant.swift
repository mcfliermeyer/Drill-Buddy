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
        case topLeft(entity: ModelEntity)
        case topRight(entity: ModelEntity)
        case bottomRight(entity: ModelEntity)
        case bottomLeft(entity: ModelEntity)
    }
    
    func drawArc(angle: Float, triangleDetailCount: Int) -> (MeshDescriptor, PhysicallyBasedMaterial){

        let triangleAngle: Float = (angle / Float(triangleDetailCount))
        
        let verticesCount = Int(triangleDetailCount * 2)
        
        var vertices: [SIMD3<Float>] {
            
            var vertex = [SIMD3<Float>]()
            
            for i in (0 ... verticesCount) {
                
                let x = (round(cos( (Float(i) * triangleAngle).toRadian()) * 1000)/10000) * radius
                let y = (round(sin( (Float(i) * triangleAngle).toRadian()) * 1000)/10000) * radius

                vertex.append([x/(1 + lineWidth), y/(1 + lineWidth), 0])//inner arc
                vertex.append([x, y, 0])
                
            }
            //x and y have to be reduced to width of new arc line
            
            return vertex
        }//vertices
        
        var triangles: [UInt32] {
            
            var points: [UInt32] = Array(repeating: 0, count: (verticesCount * 6))
            
            for i in (0 ..< verticesCount) {
                points[6 * i + 0] = UInt32(i)
                points[6 * i + 1] = UInt32(i + 1)
                points[6 * i + 2] = UInt32(i + 2)
                points[6 * i + 3] = UInt32(i + 2)
                points[6 * i + 4] = UInt32(i + 1)
                points[6 * i + 5] = UInt32(i + 3)
            }
            
            return points
        }
        
        //high sheen material to help with solid color not visible without physically based material
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .black)
        material.sheen = .init(tint: .black)
        material.emissiveColor = .init(color: color)
        material.emissiveIntensity = 10
        
        var mesh = MeshDescriptor(name: "Circle")
        mesh.positions = MeshBuffer(vertices)
        mesh.primitives = .triangles(triangles)

        return (mesh, material)
    }
    
}

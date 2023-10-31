//
//  TextDisplayBubble.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/28/23.
//

import RealityKit
import UIKit

class MeasurementBubble: Entity, HasAnchoring {
    
    var length: Float = 0.15
    var color: UIColor = .white
    
    init(length: Float, color: UIColor) {
        
        self.length = length
        self.color = color
        
        super.init()
        
        let (mesh, material) = self.drawOblongShape(length: 0.15)
        let model = ModelComponent(mesh: try! .generate(from: [mesh]), materials: [material])
        let collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.2/10)])//radius of model is changed during drawing, this scales collision back down to where size of model component
        
        self.components[ModelComponent.self] = model
        self.components[CollisionComponent.self] = collision
        
        /*
         scale down huge model
         rotate to horizontal line
         */
        self.scale = [0.1,0.1,0.1]
        self.transform.rotation = simd_quatf(angle: 90.toRadian(), axis: SIMD3(0,0,1))
    }
    
    @MainActor required init() {
        
        super.init()
        
        let (mesh, material) = self.drawOblongShape(length: 0.15)
        let model = ModelComponent(mesh: try! .generate(from: [mesh]), materials: [material])
        let collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.2/10)])//radius is changed during drawing, this scales it back down
        
        self.components[ModelComponent.self] = model
        self.components[CollisionComponent.self] = collision
        
    }
    
    //oblong pill shape to put in center of measureline with text on top showing current measurement
    func drawOblongShape(length: Float) -> (MeshDescriptor, PhysicallyBasedMaterial) {
        
        let triangleDetailCount = 15
        
        let triangleAngle: Float = (180 / Float(triangleDetailCount))
        
        let verticesCount = Int(50 + 1)
        
        var topVertices: [SIMD3<Float>] {
            
            var vertex = [SIMD3<Float>]()
            
            for i in (0 ..< verticesCount) {
                
                let x = round(cos( (Float(i) * triangleAngle).toRadian()) * 100)/1000
                let y = round(sin( (Float(i) * triangleAngle).toRadian()) * 100)/1000
                vertex.append([x, y + length, 0])
                
            }
            //x and y have to be reduced to width of new arc line
            
            vertex.append([0.1, length, 0])
            vertex.append([-0.1, length, 0])
            vertex.append([-0.1, 0.0, 0])
            vertex.append([0.1, 0.0, 0])
            
            vertex.append([0.1, 0, 0])
            vertex.append([-0.1, 0, 0])
            vertex.append([-0.1, -length, 0])
            vertex.append([0.1, -length, 0])
            
            return vertex
        }//topVertices
        
        var bottomVertices: [SIMD3<Float>] {
            
            var vertex = [SIMD3<Float>]()
            
            for i in (0 ..< verticesCount) {

                let x = round(cos( (Float(i) * triangleAngle).toRadian()) * 100)/1000
                let y = round(sin( (Float(i) * triangleAngle).toRadian()) * 100)/1000
                vertex.append([-x, -y + -length, 0])

            }
            //draw both boxes at end of circle drawings to make drawing points easier to find
            
            return vertex
        }//topVertices
        
        
        
        var topTriangles: [UInt32] {
            
            var points: [UInt32] = Array(repeating: 0, count: (triangleDetailCount * 3))
            
            for i in (0 ..< triangleDetailCount) {

                points[3 * i + 0] = UInt32(0)
                points[3 * i + 1] = UInt32(i + 1)
                points[3 * i + 2] = UInt32(i + 2)

            }
            
            points.append(UInt32(topVertices.count - 8))
            points.append(UInt32(topVertices.count - 7))
            points.append(UInt32(topVertices.count - 6))
            points.append(UInt32(topVertices.count - 8))
            points.append(UInt32(topVertices.count - 6))
            points.append(UInt32(topVertices.count - 5))
            
            points.append(UInt32(topVertices.count - 4))
            points.append(UInt32(topVertices.count - 3))
            points.append(UInt32(topVertices.count - 2))
            points.append(UInt32(topVertices.count - 4))
            points.append(UInt32(topVertices.count - 2))
            points.append(UInt32(topVertices.count - 1))
            
            return points
        }
        
        var bottomTriangles: [UInt32] {
            
            var points: [UInt32] = Array(repeating: 0, count: (triangleDetailCount * 3))
            
            for i in (0 ..< triangleDetailCount) {

                points[3 * i + 0] = UInt32(0)
                points[3 * i + 1] = UInt32((i + topVertices.count) )
                points[3 * i + 2] = UInt32((i + topVertices.count) + 1)

            }
            
            return points
        }
        
        let topAndBottomVertices = topVertices + bottomVertices
        let topAndBottomTriangles = topTriangles + bottomTriangles
        
        /*
         take all vertices and points to create mesh with primitives
         create a material to put over the mesh
         */
        
        var material = PhysicallyBasedMaterial()
        material.emissiveColor = .init(color: color.withAlphaComponent(0.5))
        material.baseColor = .init(tint: color.withAlphaComponent(0.5))
        material.emissiveIntensity = 10
        
        var mesh = MeshDescriptor(name: "MeasurePoint")
        mesh.positions = MeshBuffer(topAndBottomVertices)
        mesh.primitives = .triangles(topAndBottomTriangles)

        return (mesh, material)
    }
    
    
}

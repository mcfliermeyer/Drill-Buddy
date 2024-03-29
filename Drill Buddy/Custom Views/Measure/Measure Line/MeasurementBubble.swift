//
//  TextDisplayBubble.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/28/23.
//

import RealityKit
import UIKit

class MeasurementBubble: Entity, HasAnchoring {
    
    var arView: ARView?
    
    var length: Float = 0.015
    var color: UIColor = .white
    
    var bubbleText = MeasurementBubbleText(text: "Flooof", color: .black)
    
    init(color: UIColor) {
        
        self.color = color
        
        super.init()
        
        let (mesh, material) = self.drawOblongShape(length: self.length)
        let model = ModelComponent(mesh: try! .generate(from: [mesh]), materials: [material])
        let collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.2/10)])//radius of model is changed during drawing, this (0.2/10) scales collision back down to where size of model component
        
        self.components[ModelComponent.self] = model
        self.components[CollisionComponent.self] = collision
        
        self.addChild(bubbleText)
        
        bubbleText.setPosition(SIMD3(-0.0025, -0.007, -0.019), relativeTo: self)//x is same width as measureline to prevent horizontal line from covering the text, Z is what normal X axis. negative to go left KEKW
        bubbleText.transform.rotation = simd_quatf(angle: -90.toRadian(), axis: SIMD3(0,1,0))//text is placed crossing the bubble, rotate y axis to get it square with the bubble
        
    }
    
    @MainActor required init() {
        //this one doesnt seem to be used
        super.init()
    }
    
    class MeasurementBubbleText: Entity {
        
        var mesh: MeshResource
        
        let font = UIFont.systemFont(ofSize: 0.015, weight: .medium, width: .compressed)
        
        var text = ""
        
        required init(text: String, color: UIColor) {
            
            self.text = text
            mesh = MeshResource.generateText(text, extrusionDepth: 0.001, font: font, containerFrame: CGRect.zero, alignment: .center)
            
            super.init()
            
            let model = ModelComponent(mesh: mesh, materials: [UnlitMaterial(color: color)])
            
            self.components[ModelComponent.self] = model
            
        }
        
        @MainActor required init() {
            fatalError("init() has not been implemented")
        }
        
        func changeText(text: String) {
            
            self.text = text
            let mesh = MeshResource.generateText(text, extrusionDepth: 0.001, font: font, containerFrame: CGRect.zero, alignment: .center)
            let model = ModelComponent(mesh: mesh, materials: [UnlitMaterial(color: .black)])
            
            self.components[ModelComponent.self] = model
            
        }
        
    }
    
    func drawOblongShape(length: Float) -> (MeshDescriptor, PhysicallyBasedMaterial) {
        
        let triangleDetailCount = 15
        
        let triangleAngle: Float = (180 / Float(triangleDetailCount))
        
        let verticesCount = Int(50 + 1)
        
        var topVertices: [SIMD3<Float>] {
            
            var vertex = [SIMD3<Float>]()
            
            for i in (0 ..< verticesCount) {
                
                let y = round(cos( (Float(i) * triangleAngle).toRadian()) * 100)/10000
                let x = round(sin( (Float(i) * triangleAngle).toRadian()) * 100)/10000
                vertex.append([0, -y, x + length])
                
            }
            let scaleNumber: Float = 0.01
            vertex.append([0, -scaleNumber, length])
            vertex.append([0, scaleNumber, length])
            vertex.append([0, scaleNumber, 0])
            vertex.append([0, -scaleNumber, 0])
            
            vertex.append([0, -scaleNumber, 0])
            vertex.append([0, scaleNumber, 0])
            vertex.append([0, scaleNumber, -length])
            vertex.append([0, -scaleNumber, -length])
            
            
            return vertex
        }//topVertices
        
        var bottomVertices: [SIMD3<Float>] {
            
            var vertex = [SIMD3<Float>]()
            
            for i in (0 ..< verticesCount) {

                let y = round(cos( (Float(i) * triangleAngle).toRadian()) * 100)/10000
                let x = round(sin( (Float(i) * triangleAngle).toRadian()) * 100)/10000
                vertex.append([0, y, -x + -length])

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

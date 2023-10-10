//
//  ArchNodeQuadrant.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 8/2/23.
//

import RealityKit
import SceneKit

class ArchNodeQuadrant: Entity {
    
    let angle: Float
    let triangleDetailCount: Int
    let quadrant: Quadrant
    let radius: Float
    let color: UIColor
    let lineWidth: Float
    
    enum Quadrant: Int {
        case topRight = 0//goes counter clockwise for some reason
        case topLeft
        case bottomLeft
        case bottomRight
    }
    
    init(angle: Float, triangleDetailCount: Int, quadrant: Int, radius: Float, color: UIColor, lineWidth: Float) {
        
        self.angle = angle
        self.triangleDetailCount = triangleDetailCount
        self.quadrant = Quadrant(rawValue: quadrant)!
        self.radius = radius
        self.color = color
        self.lineWidth = lineWidth
        super.init()
        
        let (mesh, material) = self.drawArc(angle: 90, triangleDetailCount: 9)
        let model = ModelEntity(mesh: try! .generate(from: [mesh]), materials: [material])
        
        model.transform.rotation = simd_quatf(angle: (90 * quadrant).toRadian(), axis: SIMD3(x: 0, y: 0, z: 1))
        
        self.addChild(model)
        
    }
    
    func openQuadrant() {
        let space: Float = 0.01
        switch self.quadrant {
        case .topRight: self.transform.translation = SIMD3<Float>(x: space, y: space, z: 0)
        case .topLeft: self.transform.translation = SIMD3<Float>(x: -space, y: space, z: 0)
        case .bottomLeft: self.transform.translation = SIMD3<Float>(x: -space, y: -space, z: 0)
        case .bottomRight: self.transform.translation = SIMD3<Float>(x: space, y: -space, z: 0)
        }
    }
    
    func closeQuadrant() {
        self.transform.translation = SIMD3<Float>(x: 0, y: 0, z: 0)
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
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
        //slightly grayer less opaque material
        var material = PhysicallyBasedMaterial()
        material.emissiveColor = .init(color: color.withAlphaComponent(0.05))
        material.baseColor = .init(tint: color.withAlphaComponent(0.05))
        material.emissiveIntensity = 1.5
        
        var mesh = MeshDescriptor(name: "archNodeQuadrant")
        mesh.positions = MeshBuffer(vertices)
        mesh.primitives = .triangles(triangles)

        return (mesh, material)
    }
    
}

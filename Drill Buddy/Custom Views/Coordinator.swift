//
//  Coordinator.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 4/15/23.
//
import RealityKit
import SwiftUI
import SceneKit
import ARKit
import Foundation

class Coordinator {
    
    var arView: ARView?
    var startAnchor: AnchorEntity?
    var endAnchor: AnchorEntity?
    let archNode = ArchNode()
    
    
    lazy var measurementButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Start Measurement", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    lazy var resetButton: UIButton = {
        
        let resetButton = UIButton(configuration: .gray(), primaryAction: UIAction(handler: { [weak self] action in
            
            guard let arView = self?.arView else { return }
            self?.startAnchor = nil
            self?.endAnchor = nil
            
            arView.scene.anchors.removeAll()
            self?.measurementButton.setTitle("0.00", for: .normal)
            
        }))
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", for: .normal)
        return resetButton
        
    }()
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let arView = arView else { return }
        
//        let tappedLocation = recognizer.location(in: arView)
        
//        let results = arView.raycast(from: tappedLocation, allowing: .estimatedPlane, alignment: .any)
//        if let result = results.first {
//
//            if startAnchor == nil {
//
//                startAnchor = AnchorEntity(raycastResult: result)
////                let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.01), materials: [SimpleMaterial(color: .green, isMetallic: true)])
//                startAnchor?.addChild(box)
//
//                guard let startAnchor = startAnchor else {
//                    return
//                }
//
//                arView.scene.addAnchor(startAnchor)
//
//            } else if endAnchor == nil {
//
//                endAnchor = AnchorEntity(raycastResult: result)
//                let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.01), materials: [SimpleMaterial(color: .green, isMetallic: true)])
//                endAnchor?.addChild(box)
//
//                guard let endAnchor = endAnchor,
//                      let startAnchor = startAnchor
//                else {
//                    return
//                }
//
//                arView.scene.addAnchor(endAnchor)
//
//                // calculate the distance
//                var distanceInInches = simd_distance(startAnchor.position(relativeTo: nil), endAnchor.position(relativeTo: nil)).fromMetersToInches()
//
//                if distanceInInches < 12.0  {
//                    measurementButton.setTitle(String(format: "%.1f inches", distanceInInches), for: .normal)
//                    return
//                }
//                let feet = floor(distanceInInches / 12)
//                distanceInInches = distanceInInches - (feet * 12)
//                measurementButton.setTitle(String(format: "%.0f feet %.1f inches", feet, distanceInInches), for: .normal)
//
//            }
//
//        }
    }
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        displayGeometry()
        
        let stackView = UIStackView(arrangedSubviews: [measurementButton, resetButton])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        arView.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: arView.centerXAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: arView.bottomAnchor, constant: -180).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true
        
    }
    
    private func displayGeometry() {
        
        guard let arView = arView else { return }
        
        let worldOriginAnchor = AnchorEntity(world: SIMD3(x: 0, y: 0, z: -0.85))
        
//        let positions: [SIMD3<Float>] = [
//            [0,0,0], [0.1,0,0], [0,0.1,0], [0.1,0.1,0], [0.2,0,0], [0.2,0.1,0],
//            [0.3,0,0], [0.3,0.1,0], [0.4,0,0], [0.4,0.1,0], [0.5,0,0]
//        ]
//
//        let horizontalLineVertices: [UInt32] = [0,1,2, 1,3,2, 1,4,3, 4,5,3, 4,6,5, 6,7,5, 6,8,7, 8,9,7 ]
//        //0,1,1,4,4,6,6,8    1,3,4,5,6,7,8,9    2,2,3,3,5,5,7,7
//        var meshDescriptor = MeshDescriptor(name: "Horizontal")
//
//
//        meshDescriptor.positions = MeshBuffer(positions)
//        meshDescriptor.primitives = .triangles(horizontalLineVertices)//[how to connect positions from positions array, must be counter-clockwise to show up]
        
//        let modelEntity = ModelEntity(mesh: try! .generate(from: [meshDescriptor]), materials: [SimpleMaterial(color: .orange, isMetallic: false)])
        
//        worldOriginAnchor.addChild(modelEntity)
//        arView.scene.addAnchor(worldOriginAnchor)
        
        let (vertices, triangles) = drawCircle()
        
        var meshDes = MeshDescriptor(name: "Circle")
//        meshDes.positions = MeshBuffer(elements: vertices, indices: triangles)
        meshDes.positions = MeshBuffer(vertices)
        meshDes.primitives = .triangles(triangles)
        let circleEntity = ModelEntity(mesh: try! .generate(from: [meshDes]), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        
        worldOriginAnchor.addChild(circleEntity)
        arView.scene.addAnchor(worldOriginAnchor)
        
    }
    
    private func drawCircle() -> ([SIMD3<Float>], [UInt32]){
        
        let angle: Float = 360
        let triangleCount: Int = 100
        let triangleAngle: Float = angle / Float(triangleCount)
        
        let verticesCount = Int(triangleCount + 2)
        
        var vertices: [SIMD3<Float>] {
            
            var vertex: [SIMD3<Float>] = [[0,0,0]]
            
            for i in (0..<verticesCount) {
                let x = cos(Float(i)/10 * triangleAngle)
                let y = sin(Float(i)/10 * triangleAngle)
                print("x: \(x) y: \(y)")
                vertex.append([x/10, y/10, 0])
            }
            
            return vertex
        }//vertices
        
        var triangles: [UInt32] {
            
            var points: [UInt32] = Array(repeating: 0, count: triangleCount)
            
            for i in (0 ..< (triangleCount/3)) {
//                print(i)
                points[3 * i + 0] = 0
                points[3 * i + 1] = UInt32(i + 1)
                points[3 * i + 2] = UInt32(i + 2)
//                points.append(UInt32(i))
            }
            
            return points
        }
        
        return (vertices, triangles)
        
        
    }
    
}

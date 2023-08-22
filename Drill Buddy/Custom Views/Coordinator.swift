//
//  Coordinator.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 4/15/23.
//
import RealityKit
import SwiftUI
import Foundation
import Combine

class Coordinator {
    
    var arView: ARView?
    var sceneObserver: Cancellable!
    var startAnchor: AnchorEntity?
    var endAnchor: AnchorEntity?
    var archNode: ArchNode?
    var recentYawValues: [SIMD2<Float>] = []
//    var recentYaw_2_2_Values: [Float] = []
    var recentPositions: [SIMD3<Float>] = []
    
    
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
            
//            arView.scene.anchors.removeAll()
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
    
//    func raycastHandler(results: []) {
//
//    }
    
    func updateScene(on event: SceneEvents.Update) {
        
        guard let arView = arView else { return }
        
        guard let archNodeAnchor = arView.scene.anchors.filter({$0.name == "archNode"}).first else { return }
        
        let translate = Transform(translation: [0,0,-1])
        
        let query = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        
        guard let result = query.first else {
            
            let final = arView.cameraTransform.matrix * translate.matrix
            //set archnode circle in front of camera
            archNodeAnchor.setTransformMatrix(final, relativeTo: nil)
            
            return
        }
        
        recentYawValues.append([(result.worldTransform[2][0]), (result.worldTransform[2][2])] )
//        recentYaw_2_2_Values.append(result.worldTransform[2][2])
        let avgYawValues = recentYawValues.reduce( SIMD2<Float>.zero, {$0 + $1} ) / Float(recentYawValues.count)
//        let yaw_2_2 = recentYaw_2_2_Values.reduce( 0, {$0 + $1} ) / Float(recentYaw_2_2_Values.count)
        
        recentYawValues = recentYawValues.suffix(80)
//        recentYaw_2_2_Values = recentYaw_2_2_Values.suffix(80)
        
        let world = result.worldTransform.translation
        
        let z: Float = {
            let z = result.worldTransform.translation.z
            return (z <= -0.3) ? z : z * -1
        }()
        
        recentPositions.append([world.x,world.y,z])
        
        recentPositions = recentPositions.suffix(20)
        
        let averagePosition = recentPositions.reduce(SIMD3<Float>.zero, {$0 + $1} ) / Float(recentPositions.count)
        
        let positionTransform = Transform(translation: averagePosition)
        print("x: ", positionTransform.translation.x)
        
        let yawTransform = Transform(yaw: atan2f(avgYawValues.x, avgYawValues.y))
        
        let nodeTransform = positionTransform.matrix * yawTransform.matrix
        
        print(nodeTransform.translation)
        print("node: ", nodeTransform.translation)
        
//        print("yawTransform: ", yawTransform.matrix)
//        print("cameraMatrix: ", arView.cameraTransform.matrix)
        
//    newMatrix:  simd_float4x4([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, -0.1764827, 1.0]])
//    yawTransform:  Transform(scale: SIMD3<Float>(1.0, 1.0, 1.0), rotation: simd_quatf(real: 0.7513167, imag: SIMD3<Float>(0.0, -0.65994185, 0.0)), translation: SIMD3<Float>(0.0, 0.0, 0.0))
//    cameraMatrix:  simd_float4x4([[0.1285271, -0.14857908, 0.9805127, 0.0], [0.12559405, 0.9831907, 0.13252182, 0.0], [-0.9837211, 0.10611394, 0.1450273, 0.0], [0.114300154, 0.06341363, 0.41283953, 1.0]])
//    zPosition:  simd_float4x4([[-0.95893365, 0.08606817, 0.27025697, 0.0], [0.12559405, 0.9831907, 0.13252182, 0.0], [-0.25430828, 0.1610223, -0.9536243, 0.0], [0.28790992, 0.044686355, 0.38724473, 1.0]])
        
        archNodeAnchor.move(to: nodeTransform, relativeTo: nil, duration: 0.35)

    }
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        
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
    
    func cast(arView: ARView) {
        
        
//        print(result.worldTransform.orientation)
        
//        let cast = arView.session.trackedRaycast(query, updateHandler: {
//            results in
//            print(results.first!.worldTransform.orientation)
//        })
        
    }
}


//orientation: simd_quatf(real: 0.7215003, imag: SIMD3<Float>(0.68775284, -0.05805765, 0.055342052))
//orientationAngle: 1.5296595
//orientationAxis: SIMD3<Float>(0.99326795, -0.08384815, 0.07992622)
//transform: simd_float4x4([
//    [0.98713315, 0.0, 0.15990052, 0.0],
//                                [-0.15971722, 0.047866732, 0.98600155, 0.0],
//                                                            [-0.007653915, -0.9988538, 0.047250833, 0.0],
//                                                                                        [2.7568834, -0.7279191, -0.6314276, 1.0]
//])
//cos(0.98713315) = 0.99985158921
//sin(0.15990052) = 0.00279078692
//-sin(-0.007653915) = -0.00013358601
//cos(0.047250833) =

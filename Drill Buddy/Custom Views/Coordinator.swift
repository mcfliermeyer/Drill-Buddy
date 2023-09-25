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
    
//    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
//
//        guard let arView = arView else { return }
//
////        let tappedLocation = recognizer.location(in: arView)
//
//        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
//
//        if let result = results.first {
//
//            if startAnchor == nil {
//
//                startAnchor = AnchorEntity(raycastResult: result)
//                let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.01), materials: [SimpleMaterial(color: .green, isMetallic: true)])
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
//    }
    
    func updateScene(on event: SceneEvents.Update) {
        
        guard let arView = arView else { return }
        
        guard let archNodeAnchor = arView.scene.anchors.filter({$0.name == "archNode"}).first as? ArchNode else { return }
        
        guard let worldTransform = raycastWorldTransform(arView: arView) else { return }
        
        let yawX = round(worldTransform.matrix[2][0] * 10000000) / 10000000//pick the decimal point its rounded to
        let yawY = round(worldTransform.matrix[2][2] * 10000000) / 10000000//pick the decimal point its rounded to
        
        recentYawValues.append([(yawX), (yawY)])
        recentYawValues = recentYawValues.suffix(80)
        
        recentPositions.append([worldTransform.translation.x, worldTransform.translation.y, worldTransform.translation.z])
        recentPositions = recentPositions.suffix(20)
        
        let positionTransform = Transform(recentTranslations: recentPositions)
        
        let yawTransform = Transform(recentYawVectors: recentYawValues)
        
        let nodeTransform = positionTransform.matrix * yawTransform.matrix
        
        archNodeAnchor.move(to: nodeTransform, relativeTo: nil, duration: 0.30)
        
    }
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        
//        let view = UIview(arrangedSubviews: [measurementButton, resetButton])
        let pointView = PointControllingView()
        pointView.translatesAutoresizingMaskIntoConstraints = false
        
        arView.addSubview(pointView)
        
        pointView.centerXAnchor.constraint(equalTo: arView.centerXAnchor).isActive = true
        pointView.bottomAnchor.constraint(equalTo: arView.bottomAnchor).isActive = true
        pointView.leftAnchor.constraint(equalTo: arView.leftAnchor).isActive = true
        pointView.rightAnchor.constraint(equalTo: arView.rightAnchor).isActive = true
        pointView.topAnchor.constraint(equalTo: arView.centerYAnchor, constant: UIScreen.main.bounds.height/4).isActive = true
        pointView.backgroundColor = .systemBlue
        
    }
    
    func raycastWorldTransform(arView: ARView) -> Transform? {
        
        let query = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        
        guard let result = query.first else {//no raycast being read
            
//            this is the spot to place the Open vs Close states of the circle. close circle if no raycast being read
            
            return nil
            
        }
        
        return Transform(matrix: result.worldTransform)
        
    }
    
}

class PointControllingView: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("cart")
        super.touchesBegan(touches, with: event)
        
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("fart")
        super.touchesEnded(touches, with: event)
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Shart")
        super.touchesCancelled(touches, with: event)
    }
    
}

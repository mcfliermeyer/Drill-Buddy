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
    
    func updateScene(on event: SceneEvents.Update) {
        
        guard let arView = arView else { return }
        
        guard let archNodeAnchor = arView.scene.anchors.filter({$0.name == "archNode"}).first as? ArchNode else { return }
        
        guard let worldTransform = raycastWorldTransform(arView: arView) else { return }
        
        recentYawValues.append([(worldTransform.matrix[2][0]), (worldTransform.matrix[2][2])])
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
    
    func raycastWorldTransform(arView: ARView) -> Transform? {
        
        let query = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        
        guard let result = query.first else {//no raycast being read
            
//            this is the spot to place the Open vs Close states of the circle. close circle if no raycast being read
            
            return nil
        }
        
        return Transform(matrix: result.worldTransform)
    }
}

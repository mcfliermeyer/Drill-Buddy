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
    var archNode: ArchNode?
    var raycastResults: [matrix_float4x4] = []
    var recentmeasureButtonPositions: [SIMD3<Float>] = []
    var measureSphere: TwoDimensionalSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    var measureButton: MeasureButton = MeasureButton(radius: 0.25, color: .white, lineWidth: 0.05)
    
    func updateScene(on event: SceneEvents.Update) {
        
        guard let arView = arView else { return }
        guard let archNode = archNode else { return }
        /**
         measure button node to move with camera
         */
        guard let measureButtonTransform = createmeasureButtonTransform(arView: arView) else { return }
        measureButton.move(to: measureButtonTransform, relativeTo: AnchorEntity(.camera), duration: 0.01)
        measureButton.children.forEach( {$0.move(to: measureButtonTransform, relativeTo: AnchorEntity(.camera), duration: 0.01)} )
        /**
         arch node to move with raycast results
         */
        guard let archNodePositionTransform = createArchNodeTransform(arView: arView) else { return }
        archNode.move(to: archNodePositionTransform, relativeTo: nil, duration: 0.30)
        
    }
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        arView.scene.addAnchor(measureButton)
        measureButton.addChild(measureSphere)
        measureSphere.generateCollisionShapes(recursive: true)
        
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        
    }
    
    func createmeasureButtonTransform(arView: ARView) -> Transform? {
        
        let bottomOfScreenTransform = Transform(translation: SIMD3(x: 0, y: -0.25, z: -0.6))
        
        //get camera transform and apply bottomOfScreenTransform to keep the node in the bottom of the screen
        let measureButtonTransform = arView.cameraTransform.matrix * bottomOfScreenTransform.matrix
        
        //pull out translation/position from controller transform and keep most recent 12 positions
        recentmeasureButtonPositions.append(measureButtonTransform.translation)
        recentmeasureButtonPositions = recentmeasureButtonPositions.suffix(8)
        
        //create transform that averages the most recent translations/positions in order to keep node from skipping/jumping
        let recentmeasureButtonPositionTransform = Transform(recentTranslations: recentmeasureButtonPositions)
        
        //create transform that averages the most recent orientation
        let recentmeasureButtonOrientationTransform = Transform(rotation: measureButtonTransform.orientation)
        let combineOrientationAndPosition = recentmeasureButtonPositionTransform.matrix * recentmeasureButtonOrientationTransform.matrix
        
        return Transform(matrix: combineOrientationAndPosition)
        
    }
    
    func createArchNodeTransform(arView: ARView) -> Transform? {
        /**
         raycast get and store most recent 80 results of world transform to move around archnode without jitters
         */
        let query = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        guard let result = query.first else { return nil }
        raycastResults.append(result.worldTransform)
        raycastResults = raycastResults.suffix(80)//keep only most recent results
        
        return Transform(recentTransforms: raycastResults)
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        guard let touchInView = sender?.location(in: arView) else { return }
        
        guard let arView = arView else { return }
        
        guard let hitEntity = arView.entity( at: touchInView)?.anchor else { return }
        /**
         as long at the touched entity has anchoring, move it to the raycast result current spot
         remove entity from parent of measureButton so it no long moves with the camera
         add entity to arview scene and keep until removed
         */
        hitEntity.removeFromParent()
        arView.scene.addAnchor(hitEntity)

        let trans = Transform(recentTransforms: raycastResults)
        
        hitEntity.move(to: trans, relativeTo: nil, duration: 0.4)
        
    }
    
}


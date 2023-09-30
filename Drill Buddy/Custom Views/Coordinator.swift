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
    var recentMeasurePointPositions: [SIMD3<Float>] = []
    
    func updateScene(on event: SceneEvents.Update) {
        
        guard let arView = arView else { return }
        /**
         retrieve controller node to move
         */
        guard let controllerNodeAnchor = arView.scene.anchors.filter({$0.name == "controllerNode"}).first as? ArchNode else { return }
        guard let controllerNodeTransform = createControllerNodeTransform(arView: arView) else { return }
        controllerNodeAnchor.move(to: controllerNodeTransform, relativeTo: AnchorEntity(.camera), duration: 0.05)
        /**
         retrieve arch node to move
         */
        guard let archNodeAnchor = arView.scene.anchors.filter({$0.name == "archNode"}).first as? ArchNode else { return }
        guard let positionTransform = createArchNodeTransform(arView: arView) else { return }
        archNodeAnchor.move(to: positionTransform, relativeTo: nil, duration: 0.30)
        
    }
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        
    }
    
    func createControllerNodeTransform(arView: ARView) -> Transform? {
        
        let bottomOfScreenTransform = Transform(translation: SIMD3(x: 0, y: -0.25, z: -0.6))
        
        //get camera transform and apply bottomOfScreenTransform to keep the node in the bottom of the screen
        let controllerTransform = arView.cameraTransform.matrix * bottomOfScreenTransform.matrix
        
        //pull out translation/position from controller transform and keep most recent 12 positions
        recentMeasurePointPositions.append(controllerTransform.translation)
        recentMeasurePointPositions = recentMeasurePointPositions.suffix(12)
        
        //create transform that averages the most recent translations/positions
        let recentMeasurePointPositionTransform = Transform(recentTranslations: recentMeasurePointPositions)
        
        //create transform that averages the most recent orientation
        let recentMeasurePointOrientationTransform = Transform(rotation: controllerTransform.orientation)
        let combineOrientationAndPosition = recentMeasurePointPositionTransform.matrix * recentMeasurePointOrientationTransform.matrix
        
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
    
}


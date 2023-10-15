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
    var animationObserver: Cancellable!
    var measureButtonPressAnimationController: AnimationPlaybackController!
    var archNode: ArchNode?
    var raycastResults: [matrix_float4x4] = []
    var recentCameraPositions: [SIMD3<Float>] = []
    var startSphere, stopSphere: TwoDimensionalSphere?
    var measureButton = MeasureButton(radius: 0.25, color: .white, lineWidth: 0.05)
    var measureLine: MeasureLine?
    
    
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        arView.scene.addAnchor(measureButton)
        startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
        measureButton.addChild(startSphere!)
        startSphere!.generateCollisionShapes(recursive: true)
        
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        animationObserver = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self) { [unowned self] in self.animationsCompleted(on: $0) }
        
    }
    
    func updateScene(on event: SceneEvents.Update) {
        
        guard let arView = arView else { return }
        guard let archNode = archNode else { return }
        /**
         raycast get and store most recent 80 results of world transform to move around archnode without jitters
         */
        let query = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        guard let result = query.first else { return }
        raycastResults.append(result.worldTransform)
        raycastResults = raycastResults.suffix(30)//keep only most recent results
        
        recentCameraPositions.append(arView.cameraTransform.translation)
        recentCameraPositions = recentCameraPositions.suffix(8)
        
        let measureButtonTransform = Transform(cameraTransform: arView.cameraTransform, recentmeasureButtonPositions: recentCameraPositions)
        measureButton.move(to: measureButtonTransform, relativeTo: AnchorEntity(.camera), duration: 0.01)
        measureButton.children.forEach( {$0.move(to: measureButtonTransform, relativeTo: AnchorEntity(.camera), duration: 0.01)} )
        /**
         arch node to move with raycast results
         */
        let archNodePositionTransform = Transform(recentTransforms: raycastResults)
        archNode.move(to: archNodePositionTransform, relativeTo: nil, duration: 0.10)
        
        animateMeasureLine(arView: arView, archNode: archNode)
        
    }
    
    func animationsCompleted(on event: AnimationEvents.PlaybackCompleted) {
        /**
         check if animation that was completed is for the measure button press  measureButtonPressAnimation
         */
        if event.playbackController == self.measureButtonPressAnimationController {
            
            guard let arView = arView else { return }
            guard let archNode = archNode else { return }
            //if stopSphere is nil we start measuring
            if measureLine == nil {
                
                self.measureLine = MeasureLine(startTransform: startSphere!.transform, stopTransform: archNode.transform)
                
                arView.scene.addAnchor(measureLine!)
                
                stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
                measureButton.addChild(stopSphere!)
                stopSphere!.generateCollisionShapes(recursive: true)
                
            }
            else {//we end measuring

                let line = MeasureLine(startTransform: startSphere!.transform, stopTransform: stopSphere!.transform)
                line.addStopSphere()
                arView.scene.addAnchor(line)
                
                self.measureLine = nil
                
                startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
                measureButton.addChild(startSphere!)
                startSphere!.generateCollisionShapes(recursive: true)
                
            }
            
        }
        else {
            return
        }
        
    }
    
    func animateMeasureLine(arView: ARView, archNode: ArchNode) {
        
        guard measureLine != nil else { return }
        //check if we are measuring or not
        //if measuring, we need to create a line and destroy old line. or change current one?
        //destroy old line
        arView.scene.removeAnchor(measureLine!)
        
        self.measureLine = MeasureLine(startTransform: startSphere!.transform, stopTransform: archNode.transform)
        
        arView.scene.addAnchor(measureLine!)
        
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

        let positionTransform = Transform(recentTransforms: raycastResults)
        let scaleTransform = Transform(scale: SIMD3(x: 0.6, y: 0.6, z: 0.6))
        
        let scaledAndPositioned = positionTransform.matrix * scaleTransform.matrix
        
        measureButtonPressAnimationController = hitEntity.move(to: scaledAndPositioned, relativeTo: nil, duration: 0.2)
        
    }
    
}


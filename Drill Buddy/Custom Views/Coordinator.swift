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
    var measureLine = MeasureLine(startTransform: Transform(), stopTransform: Transform())
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        arView.scene.addAnchor(measureButton)
        startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
        measureButton.addChild(startSphere!)
        
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
        
        guard MeasureLine.isMeasuring else { return }
        //if currently measuring, update line transform
        self.measureLine.changeLineTransform(with: startSphere!.transform, newStopTransform: archNode.transform)

    }
    
    func animationsCompleted(on event: AnimationEvents.PlaybackCompleted) {
        /**
         check if animation that was completed is for the measure button press  measureButtonPressAnimation
         */
        //here we know the touched sphere should have moved into position
        if event.playbackController == self.measureButtonPressAnimationController {
            
            guard let arView = arView else { return }
            
            if MeasureLine.isMeasuring == false {
                
                measureLine.startMeasuring()
                arView.scene.addAnchor(measureLine)
                arView.scene.removeAnchor(startSphere!)
                
                stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
                measureButton.addChild(stopSphere!)
                
            }
            else {//we end measuring
                
                self.measureLine.changeLineTransform(with: startSphere!.transform, newStopTransform: stopSphere!.transform)
                measureLine.stopMeasuring()
                
                let line = measureLine.copy() as! MeasureLine
                arView.scene.addAnchor(line)
                
                arView.scene.removeAnchor(startSphere!)
                arView.scene.removeAnchor(stopSphere!)
                arView.scene.removeAnchor(measureLine)
                stopSphere = nil
                
                startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
                measureButton.addChild(startSphere!)
                
                measureLine = MeasureLine(startTransform: Transform(), stopTransform: Transform())
                
            }
            
        }
        else {
            return
        }
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        guard let touchInView = sender?.location(in: arView) else { return }
        
        guard let arView = arView else { return }
        
        guard let sphere = arView.entity( at: touchInView) as? TwoDimensionalSphere else { return }
        
        //remove from button and add to scene to move into position
        sphere.removeFromParent()
        arView.scene.addAnchor(sphere)
        
        let positionTransform = Transform(recentTransforms: raycastResults)
        let scaleTransform = Transform(scale: SIMD3(x: 0.6, y: 0.6, z: 0.6))
        
        let scaledAndPositioned = positionTransform.matrix * scaleTransform.matrix
        
//        //catch the animation controller to make sure this is the animation that is completing to do more logic after animation completes
        measureButtonPressAnimationController = sphere.move(to: scaledAndPositioned, relativeTo: nil, duration: 0.2)
        
    }
    
}


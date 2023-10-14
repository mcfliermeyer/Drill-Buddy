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
    var recentmeasureButtonPositions: [SIMD3<Float>] = []
    
    var measureSpheres = [TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)]
    var startSphere, stopSphere: TwoDimensionalSphere?
    var measureButton = MeasureButton(radius: 0.25, color: .white, lineWidth: 0.05)
    var measureLine: MeasureLine?
    
    
    
    func setupUI() {
        
        guard let arView = arView else { return }
        
        arView.scene.addAnchor(measureButton)
        measureButton.addChild(measureSpheres.last!)
        measureSpheres.last!.generateCollisionShapes(recursive: true)
        
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        animationObserver = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self) { [unowned self] in self.animationsCompleted(on: $0) }
        
    }
    
    func updateScene(on event: SceneEvents.Update) {
        
        guard let arView = arView else { return }
        guard let archNode = archNode else { return }
        /**
         measure button node to move with camera
         measure button children should only be one TwoDimensionalSphere to move with same transform
         */
        guard let measureButtonTransform = createmeasureButtonTransform(arView: arView) else { return }
        measureButton.move(to: measureButtonTransform, relativeTo: AnchorEntity(.camera), duration: 0.01)
        measureButton.children.forEach( {$0.move(to: measureButtonTransform, relativeTo: AnchorEntity(.camera), duration: 0.01)} )
        /**
         arch node to move with raycast results
         */
        guard let archNodePositionTransform = createArchNodeTransform(arView: arView) else { return }
        archNode.move(to: archNodePositionTransform, relativeTo: nil, duration: 0.30)
        
        animateMeasureLine(arView: arView, archNode: archNode)
        
    }
    
    func animationsCompleted(on event: AnimationEvents.PlaybackCompleted) {
        /**
         check if animation that was completed is for the measure button press  measureButtonPressAnimation
         */
        if event.playbackController == self.measureButtonPressAnimationController {
            
            guard let arView = arView else { return }
            guard let archNode = archNode else { return }
            //we have an odd number of spheres, so we start measuring
            if  measureSpheres.count > 0 && measureSpheres.count % 2 != 0 {
                
                let startSphere = measureSpheres.last!
                self.measureLine = MeasureLine(startPosition: startSphere.position, stopPosition: archNode.position)
                
                arView.scene.addAnchor(measureLine!)
                
                measureSpheres.append(TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white))
                measureButton.addChild(measureSpheres.last!)
                measureSpheres.last!.generateCollisionShapes(recursive: true)
                
            }
            else {//we end measuring
                
                
                //we need to try to remove start sphere and end sphere anchors and add them to the line anchor children? perhaps
                //may need to do calculations to not overload the amount of anchors in realitykit
                let startSphere = measureSpheres[measureSpheres.count - 2]
                let endSphere = measureSpheres.last!
                let line = MeasureLine(startPosition: startSphere.position, stopPosition: endSphere.position)
                arView.scene.addAnchor(line)
                
                measureSpheres.append(TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white))
                measureButton.addChild(measureSpheres.last!)
                measureSpheres.last!.generateCollisionShapes(recursive: true)
                
                return
                
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
        
        //check if we are measuring and not initial placement
        guard measureSpheres.count > 0 && measureSpheres.count % 2 == 0 else { return }
        let startSphere = measureSpheres[measureSpheres.count - 2]
        
        self.measureLine = MeasureLine(startPosition: startSphere.position, stopPosition: archNode.position)
        
        arView.scene.addAnchor(measureLine!)
        
        
        
    }
    
    func createmeasureButtonTransform(arView: ARView) -> Transform? {
        
        let bottomOfScreenTransform = Transform(translation: SIMD3(x: 0, y: -0.25, z: -0.6))
        
        //get camera transform and apply bottomOfScreenTransform to keep the node in the bottom of the screen
        let measureButtonTransform = arView.cameraTransform.matrix * bottomOfScreenTransform.matrix
        
        //pull out translation/position from controller transform and keep most recent positions
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

        let positionTransform = Transform(recentTransforms: raycastResults)
        let scaleTransform = Transform(scale: SIMD3(x: 0.6, y: 0.6, z: 0.6))
        
        let scaledAndPositioned = positionTransform.matrix * scaleTransform.matrix
        
        measureButtonPressAnimationController = hitEntity.move(to: scaledAndPositioned, relativeTo: nil, duration: 0.2)
        
    }
    
}


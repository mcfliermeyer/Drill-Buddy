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
import EstimoteUWB

class Coordinator {
    
//    var uwbManager = UWBManager()
//    var uwbDevice: EstimoteUWBDevice?
    
    var arView: ARView?
    var sceneObserver: Cancellable!
    var archNodeObserver: Cancellable!
    var animationObserver: Cancellable!
    var startSphereObserver: Cancellable!
    var stopSphereObserver: Cancellable!
    var vectorObserver: Cancellable!
    var measureButtonPressAnimationController: AnimationPlaybackController!
    var archNode: ArchNode?
    var raycastResults: [matrix_float4x4] = []
    var recentCameraPositions: [SIMD3<Float>] = []
    let startSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    let stopSphere = TwoDimensionalSphere(triangleDetailCount: 50, radius: 0.2, color: .white)
    var measureButton = MeasureButton(radius: 0.25, color: .white, lineWidth: 0.05)
    var measureLine: MeasureLine?
    let generator = UIImpactFeedbackGenerator(style: .soft)
    
    func setupUI() {
        guard let arView = arView else { return }
        
        arView.scene.addAnchor(measureButton)
        measureButton.name = "measureButton"
        
        measureButton.addChild(startSphere)
        
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        archNodeObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateArchNode(on: $0) }
    }
    
    func updateArchNode(on event: SceneEvents.Update) {
        guard let arView = arView else { return }
        guard let archNode = archNode else { return }
        
        let query = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        guard let result = query.first else { return }
        raycastResults.append(result.worldTransform)
        raycastResults = raycastResults.suffix(30)//keep only most recent results
        
        let distance = simd_distance(arView.cameraTransform.translation, archNode.transform.translation)
        
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
    }
    
    func updateScene(on event: SceneEvents.Update) {
        guard MeasureLine.isMeasuring else { return }
        //if currently measuring, update line transform
        self.measureLine!.changeLineTransform()
    }
    
    func startSpherePressed() {
        guard startSphere.isAnchored else { return }
        guard let arView = arView else { return }
        guard let archNode = archNode else { return }
        
        generator.impactOccurred()
        
        let positionTransform = Transform(recentTransforms: self.raycastResults)
        let scaleTransform = Transform(scale: SIMD3(x: 0.6, y: 0.6, z: 0.6))
        let scaledAndPositioned = positionTransform.matrix * scaleTransform.matrix
        startSphere.move(to: scaledAndPositioned, relativeTo: nil, duration: 0.2)
        startSphere.removeFromParent()
        arView.scene.addAnchor(startSphere)
        
        
        measureLine = MeasureLine(startTransform: startSphere.transform, stopTransform: archNode.transform)
        measureLine!.arView = self.arView//need to access arview for line to look at
        measureLine!.measurementBubble.arView = self.arView//need arview for bubble to look at
        measureLine!.coordinatorsArchNode = self.archNode
        measureLine!.startMeasuring()
        
        arView.scene.addAnchor(measureLine!)
        measureButton.addChild(stopSphere)
    }
    
    func stopSpherePressed() {
        guard stopSphere.isAnchored else { return }
        guard let arView = arView else { return }
        
        stopSphere.removeFromParent()
        arView.scene.addAnchor(stopSphere)
        let positionTransform = Transform(recentTransforms: self.raycastResults)
        let scaleTransform = Transform(scale: SIMD3(x: 0.6, y: 0.6, z: 0.6))
        let scaledAndPositioned = positionTransform.matrix * scaleTransform.matrix
        stopSphere.move(to: scaledAndPositioned, relativeTo: nil, duration: 0.2)
        
        generator.impactOccurred()
        
        measureLine!.changeLineTransform()
        measureLine!.stopMeasuring()
        
        let line = measureLine!.copy() as! MeasureLine
        arView.scene.addAnchor(line)
        
        arView.scene.removeAnchor(startSphere)
        arView.scene.removeAnchor(stopSphere)
        arView.scene.removeAnchor(measureLine!)
        
        measureButton.addChild(startSphere)
        
        measureLine = MeasureLine(startTransform: Transform(), stopTransform: Transform())
        measureLine!.measurementBubble.arView = self.arView
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let touchInView = sender?.location(in: arView) else { return }
        guard let arView = arView else { return }
        guard let sphere = arView.entity(at: touchInView) as? TwoDimensionalSphere else { return }
        if sphere == startSphere {
            startSpherePressed()
        }
        else {
            stopSpherePressed()
        }
    }
}


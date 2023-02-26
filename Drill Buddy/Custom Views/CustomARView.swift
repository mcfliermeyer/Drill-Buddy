//
//  CustomARView.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 2/21/23.
//
import ARKit
import RealityKit
import SwiftUI

//class with inits

class CustomArView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
}

//extend arview for gestures
extension ARView {
    
    func raycastFromCenterOfARView() {
        let model = try! Entity.loadModel(named: "Dot")
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.addChild(model)
        self.scene.addAnchor(cameraAnchor)
        model.transform.translation = [0, 0, -1]
//        let transform = simd_float4x4([1,0,0,-1],
//                                      [0,1,0,-1],
//                                      [0,0,1,-1],
//                                      [0,0,0,0])
//        model.setTransformMatrix(transform, relativeTo: nil)
        let radians = 90.0 * Float.pi / 180.0
        model.transform.rotation *= simd_quatf(angle: radians, axis: SIMD3(x: 1, y: 0, z: 0))
        
        
        
//        guard let query = self.makeRaycastQuery(from: center, allowing: .existingPlaneInfinite, alignment: .any)
//        else { return }
//
//        let repeatingRaycast = self.session.trackedRaycast(query){ results in
//            guard let result = results.first
//            else { return }
//
//            let model = try! Entity.loadModel(named: "Dot")
//            model.setScale(SIMD3<Float>(0.5, 0.5, 0.5), relativeTo: nil)
//
//            let anchor = AnchorEntity(world: result.worldTransform)
//            anchor.addChild(model)
//
//            self.scene.anchors.append(anchor)
//        }
        
        
    }
    
}


//extend arview for raycasting

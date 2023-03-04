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
    
    func placeCenterPlaneIndicator() {
        let model = try! Entity.loadModel(named: "Dot")
        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.addChild(model)
        self.scene.addAnchor(cameraAnchor)
        
//        model.transform.translation = [0, 0, -1] code below does the same thing except in the full 4x4
        
        let transform = simd_float4x4([1,0,0,0],//these stacks are actually oriented in the wrong way! they are vertical
                                      [0,1,0,0],
                                      [0,0,1,0],
                                      [0,0,-1.2,1])
        model.setTransformMatrix(transform, relativeTo: nil)
        
        //roatating center entity to be flat on users screen
        let degreesToRotate: Float = 90.0
        let radians = degreesToRotate * Float.pi / 180.0
        model.transform.rotation *= simd_quatf(angle: radians, axis: SIMD3(x: 1, y: 0, z: 0))
    }
    
    func raycastFromCenterOfARView() {
        guard let query = self.makeRaycastQuery(from: center, allowing: .estimatedPlane, alignment: .any)
        else {
            print("we aint!!")
            return }
        print("are we getting a query?")

        let repeatingRaycast = self.session.trackedRaycast(query){ results in
            guard let result = results.first
            else {
                print("no result")
                return
                
            }

            let model = try! Entity.loadModel(named: "Dot")
            model.setScale(SIMD3<Float>(0.5, 0.5, 0.5), relativeTo: nil)

            let anchor = AnchorEntity(world: result.worldTransform)
            anchor.addChild(model)

            self.scene.anchors.append(anchor)
        }
        
        
    }
    
}

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
        guard let query = self.makeRaycastQuery(from: center, allowing: .existingPlaneInfinite, alignment: .any)
        else { return }
        
        
    }
    
}


//extend arview for raycasting

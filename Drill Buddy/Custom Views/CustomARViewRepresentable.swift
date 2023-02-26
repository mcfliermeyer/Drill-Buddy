//
//  CustomARViewRepresentable.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 2/21/23.
//

import SwiftUI
import RealityKit
import ARKit

//make uiview update uiview here
struct CustomARViewRepresentable: UIViewRepresentable {
    @Binding var arView: ARView
    
    func makeUIView(context: Context) -> some UIView {
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        arView.raycastFromCenterOfARView()
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

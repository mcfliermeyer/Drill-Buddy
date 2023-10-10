//
//  ContentView.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 2/17/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        
        return ARViewContainer().edgesIgnoringSafeArea(.all).defersSystemGestures(on: .all)
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let archNode = ArchNode()
        archNode.name = "archNode"
        
        arView.scene.addAnchor(archNode)
        
        context.coordinator.arView = arView
        context.coordinator.archNode = archNode
        context.coordinator.setupUI()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        return arView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

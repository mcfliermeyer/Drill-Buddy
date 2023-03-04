//
//  ContentView.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 2/17/23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State private var arView = ARView(frame: .zero)
    
    var body: some View {
        ZStack {
            CustomARViewRepresentable(arView: $arView)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Button("Start Measuring") {
                    //place anchor in center of screen with model of point
                    //use arView.function() here from arview extension
                    arView.raycastFromCenterOfARView()
                }
                    .padding()
                    .background(Color(red: 75/255, green: 119/255, blue: 201/255))
                    .opacity(0.7)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .cornerRadius(15)
                    .dynamicTypeSize(.medium)
                    
                Spacer().frame(height: 30)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

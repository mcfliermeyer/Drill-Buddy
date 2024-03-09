//
//  SIMDExtension.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 2/21/23.
//

import SceneKit
import RealityKit
import SwiftUI

extension Int {
    
    func toRadian() -> Float {
        
        return Float(self) * Float.pi / 180
        
    }
    
}
extension Float {
    
    func toRadian() -> Float {
        
        return Float(self) * Float.pi / 180
        
    }
    
}

extension simd_float4x4 {
    
    public var position: simd_float3 {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
    
}

extension Float {
    
    func fromMetersToInches() -> Float {
        return self * 39.26
    }
    
}

typealias Angle = Measurement<UnitAngle>
extension Measurement where UnitType == UnitAngle {
  init(degrees: Double) {
    self.init(value: degrees, unit: .degrees)
  }

  func toRadians() -> Double {
    return converted(to: .radians).value
  }
}



// MARK: - float4x4 extensions

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
    */
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
    /**
     Factors out the orientation component of the transform.
    */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}

extension Transform {
    // From: https://stackoverflow.com/questions/50236214/arkit-eulerangles-of-transform-matrix-4x4
    var eulerAngles: SIMD3<Float> {
        
        let matrix = matrix
        
        return .init(
            
            x: asin(-matrix[2][1]),
            y: atan2(matrix[2][0], matrix[2][2]),
            z: atan2(matrix[0][1], matrix[1][1])
            
        )
    }
    
    init(recentTransforms transforms: [matrix_float4x4]) {
        //pull out most recent 20 positions and create Transform
        let translations = transforms.map({$0.translation}).suffix(10)
        let translationsAverage = translations.reduce(SIMD3<Float>.zero, {$0 + $1} ) / Float(translations.count)
        let translationTranform = Transform(translation: translationsAverage)
        
        //pull out most recent 80 orientations (quatf) and create Transform
        let orientations = transforms.map({$0.orientation}).suffix(80)
        let anglesAverage = orientations.map({$0.angle}).reduce(0.0, {$0 + $1} ) / Float(orientations.count)
        let axisAverage = orientations.map({$0.axis}).reduce(SIMD3<Float>.zero, {$0 + $1}) / Float(orientations.count)
        let averageOrientationQauternion = simd_quatf(angle: anglesAverage, axis: axisAverage)
        var orientationTransform = Transform(rotation: averageOrientationQauternion)
        //flip node to face camera
        orientationTransform.rotation *= simd_quatf(angle: 270.toRadian(), axis: SIMD3<Float>(1,0,0))
        
        //multiply both transform matrices
        let newTransform = translationTranform.matrix * orientationTransform.matrix
        
        self.init(matrix: newTransform)
        
    }
    
    init(recentMeasureBubbles transforms: [matrix_float4x4]) {
        //pull out most recent 20 positions and create Transform
        let translations = transforms.map({$0.translation}).suffix(10)
        let translationsAverage = translations.reduce(SIMD3<Float>.zero, {$0 + $1} ) / Float(translations.count)
        let translationTranform = Transform(translation: translationsAverage)
        
        //pull out most recent 80 orientations (quatf) and create Transform
        let orientations = transforms.map({$0.orientation}).suffix(80)
        let anglesAverage = orientations.map({$0.angle}).reduce(0.0, {$0 + $1} ) / Float(orientations.count)
        let axisAverage = orientations.map({$0.axis}).reduce(SIMD3<Float>.zero, {$0 + $1}) / Float(orientations.count)
        let averageOrientationQauternion = simd_quatf(angle: anglesAverage, axis: axisAverage)
        var orientationTransform = Transform(rotation: averageOrientationQauternion)
        //flip node to face camera
//        orientationTransform.rotation *= simd_quatf(angle: 270.toRadian(), axis: SIMD3<Float>(1,0,0))
        
        //multiply both transform matrices
        let newTransform = translationTranform.matrix * orientationTransform.matrix
        
        self.init(matrix: newTransform)
        
    }
    
    init(recentTranslations: [SIMD3<Float>]) {
        
        let avgVector = recentTranslations.reduce( SIMD3<Float>.zero, {$0 + $1} ) / Float(recentTranslations.count)
        
        self.init(translation: avgVector)
        
    }
    
    init(cameraTransform: Transform, recentmeasureButtonPositions: [SIMD3<Float>]) {
        
        let bottomOfScreenTransform = Transform(translation: SIMD3(x: 0, y: -0.25, z: -0.6))
        
        let averageTranslations = Transform(recentTranslations: recentmeasureButtonPositions)
        
        let currentOrientation = Transform(rotation: cameraTransform.rotation)
        
        let combined = averageTranslations.matrix * currentOrientation.matrix * bottomOfScreenTransform.matrix
        
        self.init(matrix: combined)
        
    }
    
}

extension Measurement where UnitType : UnitLength {
    
    internal func convertDecimalToFraction() -> FractionalInch {
        
        guard value <= 0.875 else { return FractionalInch.sevenEighthInch }
        guard value <= 0.75 else { return FractionalInch.threeQuarterInch }
        guard value <= 0.625 else { return FractionalInch.fiveEighthInch }
        guard value <= 0.5 else { return FractionalInch.halfInch }
        guard value <= 0.375 else { return FractionalInch.threeEighthInch }
        guard value <= 0.25 else { return FractionalInch.quarterInch }
        return FractionalInch.eighthInch
        
    }
    
}

extension Float {
    
    func formatDistanceString() -> String{
        
        let meters = Measurement(value: Double(self), unit: UnitLength.meters)
        
        let feetFloorDouble = floor(meters.converted(to: .feet).value)
        let feet = Measurement(value: feetFloorDouble, unit: UnitLength.feet)
        
        let inchFloorDouble = floor((meters - feet).converted(to: .inches).value)
        let inches = Measurement(value: inchFloorDouble, unit: UnitLength.inches)
        
        let decimal = (meters - feet - inches).converted(to: .inches)
        let fractionalInch = decimal.convertDecimalToFraction()
        
        return "\(Int(feet.value))\'\(Int(inches.value))\(fractionalInch.symbol)"
    }
    
}

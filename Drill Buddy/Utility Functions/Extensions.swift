//
//  SIMDExtension.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 2/21/23.
//

import SceneKit
import RealityKit

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

public extension Transform {

    // From: https://stackoverflow.com/questions/50236214/arkit-eulerangles-of-transform-matrix-4x4
    var eulerAngles: SIMD3<Float> {
        let matrix = matrix
        print(matrix[2])
        return .init(
            x: asin(-matrix[2][1]),
            y: atan2(matrix[2][0], matrix[2][2]),
            z: atan2(matrix[0][1], matrix[1][1])
        )
    }
}


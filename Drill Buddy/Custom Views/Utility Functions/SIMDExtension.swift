//
//  SIMDExtension.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 2/21/23.
//

import RealityKit

extension simd_float4x4 {
    public var position: simd_float3 {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}

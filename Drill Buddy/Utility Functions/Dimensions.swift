//
//  Dimensions.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/31/23.
//

import Foundation

final class FractionalInch: UnitLength {
    
    static let inch = FractionalInch(symbol: "\"", converter: UnitConverterLinear(coefficient: 1.0))
    
    static let sevenEighthInch = FractionalInch(symbol: "⅞\"", converter: UnitConverterLinear(coefficient: 0.875))
    
    static let threeQuarterInch = FractionalInch(symbol: "¾\"", converter: UnitConverterLinear(coefficient: 0.75))
    
    static let fiveEighthInch = FractionalInch(symbol: "⅝\"", converter: UnitConverterLinear(coefficient: 0.625))
    
    static let halfInch = FractionalInch(symbol: "½\"", converter: UnitConverterLinear(coefficient: 0.5))
    
    static let threeEighthInch = FractionalInch(symbol: "⅜\"", converter: UnitConverterLinear(coefficient: 0.375))
    
    static let quarterInch = FractionalInch(symbol: "¼\"", converter: UnitConverterLinear(coefficient: 0.25))
    
    static let eighthInch = FractionalInch(symbol: "⅛\"", converter: UnitConverterLinear(coefficient: 0.125))
    
}

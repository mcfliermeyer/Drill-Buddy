//
//  Dimensions.swift
//  Drill Buddy
//
//  Created by Mark Meyer on 10/31/23.
//

import Foundation

final class FractionalInches: Dimension {
    
    static let inch = FractionalInches(symbol: "inch", converter: UnitConverterLinear(coefficient: 1.0))
    
    static let sevenEighthInch = FractionalInches(symbol: "5/8 inch", converter: UnitConverterLinear(coefficient: 0.875))
    
    static let threeQuarterInch = FractionalInches(symbol: "3/4 inch", converter: UnitConverterLinear(coefficient: 0.75))
    
    static let fiveEighthInch = FractionalInches(symbol: "5/8 inch", converter: UnitConverterLinear(coefficient: 0.625))
    
    static let halfInch = FractionalInches(symbol: "1/2 inch", converter: UnitConverterLinear(coefficient: 0.5))
    
    static let threeEighthInch = FractionalInches(symbol: "3/8 inch", converter: UnitConverterLinear(coefficient: 0.375))
    
    static let quarterInch = FractionalInches(symbol: "1/4 inch", converter: UnitConverterLinear(coefficient: 0.25))
    
    static let eightInch = FractionalInches(symbol: "1/8 inch", converter: UnitConverterLinear(coefficient: 0.125))
    
    override class func baseUnit() -> FractionalInches {
        return inch
    }
    
    
    
}

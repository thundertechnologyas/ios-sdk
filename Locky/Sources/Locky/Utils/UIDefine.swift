//
//  UIDefine.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/25.
//

import Foundation
import UIKit
import CoreGraphics

public func sColor_RGB(_ r: UInt, _ g: UInt, _ b: UInt) -> UIColor {
    return sColor_RGBA(r, g, b, 1.0)
}

public func sColor_RGBA(_ r: UInt, _ g: UInt, _ b: UInt, _ a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
}

public func Color_Hex(_ hexStr: String) -> UIColor {
    return Color_Hex(hexStringToInt(from: hexStr))
}

public func Color_Hex(_ rgbValue: UInt) -> UIColor {
    return Color_HexA(rgbValue, alpha: 1.0)
}

public func Color_HexA(_ hexStr: String, alpha: CGFloat) -> UIColor {
    return Color_HexA(hexStringToInt(from: hexStr), alpha: alpha)
}

public func Color_HexA(_ rgbValue: UInt, alpha: CGFloat) -> UIColor {
    let r = (rgbValue & 0xFF0000) >> 16
    let g = (rgbValue & 0x00FF00) >> 8
    let b = rgbValue & 0x0000FF
    return sColor_RGBA(r, g, b, alpha)
}

fileprivate func hexStringToInt(from:String) -> UInt {
    let str = from.replacingOccurrences(of: "#", with: "").uppercased()
    var sum = 0
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48 // 0-9 
        if i >= 65 {                 // A-Z
            sum -= 7
        }
    }
    return UInt(sum)
}


public let Screen_Width = UIScreen.main.bounds.size.width

public let Screen_Height = UIScreen.main.bounds.size.height


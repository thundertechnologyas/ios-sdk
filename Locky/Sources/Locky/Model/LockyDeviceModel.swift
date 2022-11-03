//
//  LockyDeviceModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/11/3.
//

import Foundation
public struct LockyDeviceModel {
    var bleId: String = ""
    var deviceId: String = ""
    var lastSeen: Date?
    var hasData: Bool = false
    var rssi: Float = 0
}

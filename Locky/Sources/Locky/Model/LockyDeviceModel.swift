//
//  LockyDeviceModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/11/3.
//

import Foundation
import CoreBluetooth

public struct LockyDeviceModel {
    public var bleId: String = ""
    public var deviceId: String = ""
    public var lastSeen: Date?
    public var hasData: Bool = false
    public var rssi: Float = 0
    public var peripheral: CBPeripheral?
}

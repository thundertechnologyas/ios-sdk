//
//  LockyBLEProtocol.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/11/3.
//

import Foundation
import CoreBluetooth

/// Lock Bluetooth protocol. It contains events to notify discover, connect
/// disconnect, write successfully or failure, read data.
protocol LockyBLEProtocol {
    func didDiscover (_ devices: [LockyDeviceModel])
    func didConnect (device: LockyDeviceModel)
    func didDisconnect (device: LockyDeviceModel)
    func didWrite (error: Error?)
    func didRead (device: LockyDeviceModel?, data: String?)
}

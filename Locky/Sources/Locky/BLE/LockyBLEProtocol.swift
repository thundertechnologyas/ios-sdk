//
//  LockyBLEProtocol.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/11/3.
//

import Foundation
import CoreBluetooth

public protocol LockyBLEProtocol {
    func didDiscover (_ devices: [LockyDeviceModel])
    func didConnect (device: LockyDeviceModel)
    func didDisconnect (device: LockyDeviceModel)
    func didWrite (error: Error?)
    func didRead (device: LockyDeviceModel?, data: String?)
}

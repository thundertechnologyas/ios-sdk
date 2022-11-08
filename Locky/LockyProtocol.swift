//
//  LockyProtocol.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/11/9.
//

import Foundation

public enum EventType: UInt32 {
    case DiscoveredDevice   = 1  // it has discovered the device
    case ConnectingDevice   = 2  // it is connecting the device
    case DidConnectDevice   = 3  // it has connected the device
    case DisConnectDevice   = 4  // it disconnects the device
    case WritingDevice      = 5  // it is writing to the device
    case DidWriteDevice     = 6  // it has written to the device
    case FailureWriteDevice = 7  // it fails to write to the device
    case DownloadPackage    = 8  // it is downloading package for the device
    case DeliveringMessage  = 9  // messge is delivering
    case MessageDelivered   = 10 // ithe message is delivered
}

public protocol LockyProtocol {
    func postDeviceEvent (_ deviceId: String, eventType: EventType)
}

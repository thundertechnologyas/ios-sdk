//
//  LockyBLEHelper.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/25.
//

import Foundation
import CoreBluetooth
 
class LockyBLEHelper: NSObject {
    
    public var delegate: LockyBLEProtocol?
     
    private var centralManager:CBCentralManager!
    
    private var connectedPeripheral:CBPeripheral?
    //discoverd peripherals array
    private var discoveredDevices:[LockyDeviceModel] = []
    private var discoveredPeripherals:[CBPeripheral] = []
    private var hasDataPeripherals:[CBPeripheral] = []
    private var workItems:[DispatchWorkItem] = []
    private var resetHasDataWorkItem:DispatchWorkItem?
    private var deltaTime = 0
    
    private var autoCollectBLEData = true
    
    // CBCService UUID
    private let confirmServiceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"

    private let characteristicUUIDStringForWrite = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    private let characteristicUUIDStringForRead = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

    public override init() {
        super.init()
        self.centralManager = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey : false])
    }
    
    public func scanForPeripherals () {
        self.stopScan()
        if centralManager.state == .poweredOn {
            doScan()
        }
    }
    
    ///connect peripheral
    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    public func connect(device: LockyDeviceModel) {
        guard let peripheral = device.peripheral else {
            return
        }
        autoCollectBLEData = false
        for item in workItems {
            item.cancel()
        }
        hasDataPeripherals.removeAll()
        workItems.removeAll()
        if device.peripheral == connectedPeripheral {
            delegate?.didConnect(device: device)
            return
        }
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
            connectedPeripheral = nil
        }
        connect(peripheral: peripheral)
    }
    
    public func disconnect(device: LockyDeviceModel) {
        guard let peripheral = device.peripheral else {
            return
        }
        if peripheral == connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        } else if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
            connectedPeripheral = nil
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    public func stopScan() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    public func writeData(device: LockyDeviceModel, data: Data) {
        guard let peripheral = device.peripheral else {
            return
        }
        autoCollectBLEData = false
        if resetHasDataWorkItem != nil {
            resetHasDataWorkItem?.cancel()
            resetHasDataWorkItem = nil
        }
        resetHasDataWorkItem = DispatchWorkItem { [weak self] in
            if self?.connectedPeripheral == nil {
                self?.autoCollectBLEData = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: resetHasDataWorkItem!)
        for service in peripheral.services ?? [] {
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid.isEqual(CBUUID(string: characteristicUUIDStringForWrite)) {
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    return
                }
            }
            
        }
    }
}
extension LockyBLEHelper: CBCentralManagerDelegate{
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("CBCentralManager state:", "unknown")
        case .resetting:
            print("CBCentralManager state:", "resetting")
        case .unsupported:
            print("CBCentralManager state:", "unsupported")
        case .unauthorized:
            print("CBCentralManager state:", "unauthorized")
        case .poweredOn:
            print("CBCentralManager state:", "poweredOn")
        case .poweredOff:
            print("CBCentralManager state:", "poweredOff")
        default:
            print("unknow error")
        }
    }
    ///discover peripheral
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
        if var device = parsePeripheral(peripheral, advertisementData: advertisementData, rssi: RSSI) {
            if device.hasData && autoCollectBLEData {
                device.hasData = false
                hasDataPeripherals.append(peripheral)
                let workItem = DispatchWorkItem { [weak self] in
                    if (self?.hasDataPeripherals.count ?? 0) > 0 {
                        let peripheral = self?.hasDataPeripherals[0]
                        self?.connect(peripheral: peripheral!)
                        self?.hasDataPeripherals.removeFirst()
                    }
                    if (self?.workItems.count ?? 0) > 0 {
                        self?.workItems.removeFirst()
                    }
                }
                workItems.append(workItem)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(deltaTime), execute: workItem)
                deltaTime += 2
            }
            discoveredDevices.removeAll { item in
                return item.deviceId == device.deviceId
            }
            discoveredDevices.append(device)
            delegate?.didDiscover(discoveredDevices)
        }
    }
    
    ///did connect
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        for item in discoveredDevices {
            if item.peripheral == peripheral {
                delegate?.didConnect(device: item)
                break
            }
        }
        
        //start to find services nil is to find all services
        peripheral.discoverServices(nil)
    }
    
    ///fail to connect
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("fail to connect:\(error.debugDescription)")
    }
    
    ///did disconnect
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
        for item in discoveredDevices {
            if item.peripheral == peripheral {
                delegate?.didDisconnect(device: item)
                break
            }
        }
        print("disconnect")
    }
}

private extension LockyBLEHelper {
    
    func doScan() {
        self.centralManager.scanForPeripherals(withServices: [CBUUID(string: confirmServiceUUID)], options: nil)
    }
    
    func parsePeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) -> LockyDeviceModel? {
        guard let name = peripheral.name, name.contains("TT") else {
            return nil
        }
        
        guard let advertise = advertisementData["kCBAdvDataManufacturerData"] else {
            return nil
        }
        var device = LockyDeviceModel()
        
        device.bleId = peripheral.identifier.uuidString
        let advertiseStr = (advertise as! Data).hexadecimal()
        if advertiseStr.count >= 30 {
            device.deviceId = advertiseStr.sub(from: 6, to: 30)!
        }
        device.lastSeen = Date()
        let hasData = advertiseStr.sub(from: 4, to: 6)
        if hasData == "02" {
            device.hasData = true
        }
        device.rssi = RSSI.floatValue
        device.peripheral = peripheral
        return device
    }
}

extension LockyBLEHelper:CBPeripheralDelegate{
    
    ///Discover Services
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let _ = error {
            return
        }
        
        let characteristics = [CBUUID(string: characteristicUUIDStringForRead), CBUUID(string: characteristicUUIDStringForWrite)]
        for service in peripheral.services ?? [] {
            if service.uuid.uuidString == confirmServiceUUID {
                peripheral.discoverCharacteristics(characteristics, for: service)
            }
        }
    }

    /// find characteristics
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let _ = error {
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            
            if !service.uuid.isEqual(CBUUID(string: confirmServiceUUID)) {
                continue
            }
            
            let propertie = characteristic.properties

            if propertie == CBCharacteristicProperties.write && characteristic.uuid.isEqual(CBUUID(string: characteristicUUIDStringForWrite)) {
            }
            if (propertie == .notify || propertie == .read) && characteristic.uuid.isEqual(CBUUID(string: characteristicUUIDStringForRead)) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        delegate?.didWrite(error: error)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            return
        }
        var device: LockyDeviceModel? = nil
        for item in discoveredDevices {
            if item.peripheral == peripheral {
                device = item
                break
            }
        }
        if let data = characteristic.value {
            let base64Str = data.base64EncodedString()
            delegate?.didRead(device: device, data: base64Str)
            print("base64Str:", base64Str)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let _ = error {
            return
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            return
        }
    }

}

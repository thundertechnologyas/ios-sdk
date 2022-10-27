//
//  LockyBLEHelper.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/25.
//

import Foundation
import CoreBluetooth
 
public class LockyBLEHelper: NSObject {

    static var share =  LockyBLEHelper()
    
    lazy var centralManager:CBCentralManager = {
        let central = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey : false])
        return central
    }()
    
    var connectedPeripheral:CBPeripheral?
    //discoverd peripherals array
    var discoveredPeripherals :[CBPeripheral?] = []

    // CBCService UUID
    let confirmServiceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"

    var confirmCharacteristic : CBCharacteristic!
    
    let characteristicUUIDStringForWrite = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    let characteristicUUIDStringForRead = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

    private override init() {
        
    }
    
    func scanForPeripherals () {
        self.stopScan()
        self.centralManager.scanForPeripherals(withServices: [CBUUID(string: confirmServiceUUID)], options: nil)
    }
    ///连接外设
    func connect(peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        centralManager.connect(self.connectedPeripheral!, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
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
//            central.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            print("CBCentralManager state:", "poweredOff")
        default:
            print("unknow error")
        }
    }
    ///discover peripheral
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //add to discovered peripheral list
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    ///did connect
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        //start to find services nil is to find all services
        peripheral.discoverServices(nil)
    }
    ///fail to connect
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("fail to connect:\(error.debugDescription)")
    }
    ///did disconnect
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnect")
    }
}

extension LockyBLEHelper:CBPeripheralDelegate{
    
    ///Discover Services
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            return
            //error occurs
        }
        for service in peripheral.services ?? [] {
            if service.uuid.uuidString == confirmServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    /// find characteristics
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil{
            print(error!.localizedDescription)
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            let propertie = characteristic.properties

            if propertie == CBCharacteristicProperties.write {
                self.confirmCharacteristic = characteristic
                //写入
                let byte:[UInt8] = [0xAA]
                let data = Data(bytes: byte, count: 1)
                self.connectedPeripheral!.writeValue(data, for: self.confirmCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            if propertie == CBCharacteristicProperties.read {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    //MARK: - write data if success
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error?.localizedDescription as Any )
            return
        }else{
            
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }

}

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
    //发现的蓝牙外设
    var discoveredPeripheralsArr :[CBPeripheral?] = []
    var signalRSSIArr:[NSNumber?] = []

//    6E400001-B5A3-F393-E0A9-E50E24DCCA9E ( service_uuid )
//    6E400002-B5A3-F393-E0A9-E50E24DCCA9E ( characteristic_uuid - Transmit data )
//    6E400003-B5A3-F393-E0A9-E50E24DCCA9E ( characteristic_uuid - Receive data )
    
    //蓝牙加密认证 服务 CBCService的UUID
    let confirmServiceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    //保存的设备特性char[3]
    var confirmCharacteristic : CBCharacteristic!
    
    let characteristicUUIDStringForWrite = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    let characteristicUUIDStringForRead = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

    ///启用蓝牙,搜索链接设备
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
            ///扫描设备
            central.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            print("CBCentralManager state:", "poweredOff")
        default:
            print("未知错误")
        }
    }
    ///发现设备
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //过滤存在的蓝牙外设
        var isExisted = false
        for obtainedPeriphal  in discoveredPeripheralsArr {
            if (obtainedPeriphal?.identifier == peripheral.identifier){
                isExisted = true
                //更新信号轻度
                let index = discoveredPeripheralsArr.firstIndex(of: peripheral)!
                signalRSSIArr[index] = RSSI
            }
        }
        if !isExisted && peripheral.name != nil{
            discoveredPeripheralsArr.append(peripheral)
            signalRSSIArr.append(RSSI)
            
        }
//        AUCNOTI.post(name: NOTIFICATION_DEVICE, object: self, userInfo: ["peripheral":discoveredPeripheralsArr,"rssi":signalRSSIArr])
    }
    ///连接设备成功
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        //开始寻找Services。传入nil是寻找所有Services
        peripheral.discoverServices(nil)
    }
    ///连接设备失败
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("fail to connect:\(error.debugDescription)")
    }
    ///断开连接
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnect")
    }

}

extension LockyBLEHelper:CBPeripheralDelegate{
    
    ///Discover Services
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error != nil){
            
        }
        if let services = peripheral.services {
            for  service in services {
                
                if service.uuid.uuidString == confirmServiceUUID {
                    
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
            }
        }
    }

    /// 从感兴趣的服务中，确认 我们所发现感兴趣的特征
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        if error != nil{
            print(error!.localizedDescription)
        }
        
        for characteristic in service.characteristics! {
            
            let propertie = characteristic.properties

            if propertie == CBCharacteristicProperties.notify {
                peripheral.setNotifyValue(true, for: characteristic)
                
            }
            if propertie == CBCharacteristicProperties.write {
                
            }
            if propertie == CBCharacteristicProperties.read {
                peripheral .readValue(for: characteristic)
            }
            self.confirmCharacteristic = characteristic
            //写入
            let byte:[UInt8] = [0xAA]
            let data = Data(bytes: byte, count: 1)
            
            for byte in 0..<data.count {
                print("\(byte)")
            }
            self.connectedPeripheral!.writeValue(data, for: self.confirmCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    //MARK: - 检测向外设写数据是否成功
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            
            print(error?.localizedDescription as Any )
//            AUCNOTI.post(name: NOTIFICATION_ISWRITE_SUCCESS, object: self, userInfo: ["writeEror":error as Any])
            
        }else{
            
        }
        
    }
    
    // 接收外设发来的数据 每当一个特征值定期更新或者发布一次时，我们都会收到通知；
    // 阅读并解译我们订阅的特征值
    // MARK: - 获取外设发来的数据
    // 注意，所有的，不管是 read , notify 的特征的值都是在这里读取
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
        }
    }
    
    //接收characteristic信息    //MARK: - 特征的订阅状体发生变化
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        print("========特征的订阅状体变化========")
//        printShow(str: characteristic.uuid.uuidString)
        
    }
    
    
    /*
     *CRC
     */
    func dealWithCRC(_ crc:String?)->String? {

        if let str = crc {
//            let newCRC =  str.subString(start: 2, length: 2)+str.subString(start: 0, length: 2)
//
//            return "\(CZModbus.convertHex(toDecimal: newCRC))"
        }
        return nil
    }
    
    //根据接收的数据返回带有CRC的Data
    func dealWithParam(_ param:[String:Data]) -> Data? {
        return nil
    }
}

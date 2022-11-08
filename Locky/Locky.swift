//
//  Locky.swift
//  
//
//  Created by Shaolin Zhou on 2022/11/7.
//

import Foundation
import CoreBluetooth

public class Locky {
    private var lockyHelper = LockyBLEHelper()
    private var packageSignalType: PackageSignalType?
    private var email: String?
    private var tokenModel: TokenModel?
    private var mobileKeyList: [LockModelKey]?
    private var peripherals: [CBPeripheral]?
    private var locksList = [LockModel]()
    private var deviceList: [LockyDeviceModel]?
    private var connectedDevice: LockyDeviceModel?
    private var connectedLock: LockModel?
    private var actionClosure: ((Bool)->Void)?
    private var updateLocksClosure: (([LockDevice]?, Bool)->Void)?
    
    public init() {
        lockyHelper.delegate = self
    }
    
    deinit {
        stop()
    }
    
    /// Call this function to tell locky to send a verification code on emai
    /// @param email user's email
    /// @param completion callback, success or fail to send
    public func startVerify(email: String, completion: @escaping ((Bool) -> Void)) {
        LockyService.startVerify(email: email) {[weak self] result, error in
            self?.email = email
            completion(result)
        }
    }
    
    /// Obtain token by the code from email
    /// @param code code from email
    /// @param completion callback, success or fail to obtain
    public func verify(code: String, completion: @escaping ((Bool) -> Void)){
        guard let email = email else {
            completion(false)
            return
        }
        LockyService.verify(email: email, code: code) {[weak self] token in
            guard let token = token else {
                completion(false)
                return
            }
            if token.token.isEmpty {
                completion(false)
                return
            } else {
                self?.tokenModel = token
                UserDefaults.standard.setValue(token.token, forKey: "locky_token")
                completion(true)
            }
        }
    }
    
    /// Judge user if authenticated
    /// return true or false
    public func isAuthenticated()->Bool {
        if tokenModel == nil || tokenModel!.token.isEmpty {
            let storedToken = (UserDefaults.standard.object(forKey: "locky_token") as? String) ?? ""
            if !storedToken.isEmpty {
                tokenModel = TokenModel()
                tokenModel!.token = storedToken
            }
        }
        
        guard let token = tokenModel, !token.token.isEmpty else {
            return false
        }
        return true
    }
    
    /// logout, and clean token
    public func logout() {
        tokenModel = nil
        UserDefaults.standard.setValue(nil, forKey: "locky_token")
        stop()
    }
    
    /// stop scan bluetooth and dis connect
    public func stop() {
        lockyHelper.delegate = nil
        lockyHelper.stopScan()
        if let connectedDevice = connectedDevice {
            lockyHelper.disconnect(device: connectedDevice)
        }
    }
    
    /// stop scan bluetooth and dis connect
    /// @param completion callback, true or false to get locks,
    /// if true, then we can get locks list
    public func getAllLocks(completion: @escaping (([LockDevice]?, Bool) -> Void)) {
        
        if tokenModel == nil || tokenModel!.token.isEmpty {
            let storedToken = (UserDefaults.standard.object(forKey: "locky_token") as? String ) ?? ""
            if !storedToken.isEmpty {
                tokenModel = TokenModel()
                tokenModel?.token = storedToken
            }
        }
        
        guard let token = tokenModel, !token.token.isEmpty else {
            return
        }
        updateLocksClosure = completion
        LockyService.getMobileKeys(token: token.token) {[weak self] result, tenantList in
            if result {
                self?.mobileKeyList = tenantList
                self?.getLocks(completion: { locks, result in
                    completion(locks, result)
                })
            } else {
                completion(nil, false)
            }
        }
    }
    
    /// run pulse open operation when it has been authenticated
    /// @param id, device id
    /// @param completion callback, true or false to send the command
    public func pulseOpen(id: String, completion: @escaping ((Bool) -> Void)) {
        guard let deviceList = deviceList else {
            return
        }
        actionClosure = completion
        packageSignalType = .PulseOpen
        for device in deviceList {
            if id == device.deviceId {
                if let connectedDevice = connectedDevice {
                   if connectedDevice.deviceId == device.deviceId {
                       writeData(device: connectedDevice)
                   } else {
                       lockyHelper.disconnect(device: connectedDevice)
                       lockyHelper.connect(device: device)
                       return
                   }
                } else {
                    lockyHelper.connect(device: device)
                    return
                }
                break
            }
        }
    }
}

extension Locky: LockyBLEProtocol {
    
    func didDiscover (_ devices: [LockyDeviceModel]) {
        updateLockStatus(devices)
    }
    
    func didConnect(device: LockyDeviceModel) {
        connectedDevice = device
        writeData(device: device)
    }
    
    func didDisconnect (device: LockyDeviceModel) {
        connectedDevice = nil
    }
    
    func didWrite(error: Error?) {
        packageSignalType = nil
        if let _ = error {
            actionClosure?(false)
            return
        }
        actionClosure?(true)
    }
    
    func didRead (device: LockyDeviceModel?, data: String?) {
        guard let data = data else {
            return
        }
        if let connectedLock = connectedLock {
            var payload = [String: Any]()
            payload["data"] = data
            LockyService.messageDelivered(token: connectedLock.token!, deviceId: connectedLock.id, tenantId: connectedLock.tenantId!, payload: payload) { _ in
            }
        } else if let device = device {
            guard let lock = getLockFromDevice(device) else {
                return
            }
            var payload = [String: Any]()
            payload["data"] = data
            LockyService.messageDelivered(token: lock.token!, deviceId: lock.id, tenantId: lock.tenantId!, payload: payload) { _ in
            }
        }

    }
}

private extension Locky {
    
    private func getLockDevices() -> [LockDevice]? {
        var locks = [LockDevice]()
        for item in locksList {
            let lock = LockDevice(id: item.id, name: item.name)
            locks.append(lock)
        }
        return locks
    }
    
    func getLockFromDevice(_ device: LockyDeviceModel) -> LockModel? {
        for lock in locksList {
            if lock.id == device.deviceId {
                return lock;
            }
        }
        return nil
    }
    
    func writeData(device: LockyDeviceModel) {
        guard let signalType = packageSignalType else {
            return
        }
        guard let lock = getLockFromDevice(device) else {
            return
        }
        
        connectedLock = lock
        LockyService.downloadPackage(token: lock.token!, deviceId: device.deviceId, tenantId: lock.tenantId!, type: signalType) {[weak self] package in
            guard let package = package else {
                return
            }
            let dataFromBase64 = Data(base64Encoded: package)
            if dataFromBase64 != nil {
                self?.lockyHelper.writeData(device: device, data: dataFromBase64!)
            }
        }
    }
    
    func updateLockStatus(_ devices: [LockyDeviceModel]) {
        deviceList = devices
        var locks = [LockDevice]()
        for item in locksList {
            var lock = LockDevice(id: item.id, name: item.name)
            if let deviceList = deviceList {
                for item in deviceList {
                    if item.deviceId == lock.id {
                        lock.hasBLE = true
                        break
                    }
                }
            }
            locks.append(lock)
        }
        updateLocksClosure?(locks, true)
    }
    
    func getLocks(completion: @escaping (([LockDevice]?, Bool) -> Void)) {
        guard let mobileKeyList = mobileKeyList else {
            completion(nil, false)
            return
        }
        var needRefresh = true
        
        LockyService.getAllLocks(mobileKeyList) {[weak self] locks, loadFinished in
            if needRefresh {
                self?.locksList.removeAll()
                self?.locksList.append(contentsOf: locks)
                needRefresh = false
            } else {
                self?.locksList.append(contentsOf: locks)
            }
            if loadFinished {
                self?.lockyHelper.scanForPeripherals()
                let locks = self?.getLockDevices()
                completion(locks, true)
            }
        }
    }
}



//
//  LockyView.swift
//  Locky
//  create the ui to enter email, verify and so on.
//
//  Created by Shaolin Zhou on 2022/10/24.
//

import UIKit
import SnapKit
import CoreBluetooth

public class LockyView: UIView {
    private let scrollView = UIScrollView()
    private let startLabel = UILabel()
    private let firstHintLabel = UILabel()
    private lazy var emailTextField: UITextField = {
        let view = createTextField()
        return view
    }()
    
    private let startButton = UIButton()
    
    private let verifyLabel = UILabel()
    private let verifyHintLabel = UILabel()
    private lazy var codeTextField: UITextField = {
        let view = createTextField()
        return view
    }()
    private let verifyButton = UIButton()
    
    private let tokenHintLabel = UILabel()
    private lazy var tokenTextField: UITextField = {
        let view = createTextField()
        view.isEnabled = false
        return view
    }()
    
    private let tenansLabel = UILabel()
    private let getMobileButton = UIButton()
    private let getLocksLabel = UILabel()
    private let getLocksButton = UIButton()
    private var email: String?
    private var tokenModel: TokenModel?
    private var mobileKeyList: [LockyMobileKey]?
    private var peripherals: [CBPeripheral]?
    private var locksList = [LockyMobile]()
    private var locksView = UIView()
    private var deviceList: [LockyDeviceModel]?
    private var connectedDevice: LockyDeviceModel?
    private var connectedLock: LockyMobile?
    private var packageSignalType: PackageSignalType = .PulseOpen
    private var lockyHelper = LockyBLEHelper()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        lockyHelper.delegate = self
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        lockyHelper.delegate = nil
        lockyHelper.stopScan()
        if let connectedDevice = connectedDevice {
            lockyHelper.disconnect(device: connectedDevice)
        }
    }
}

private extension LockyView {
    
    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always;
        textField.borderStyle = .none
        textField.placeHolderColor = .gray
        textField.returnKeyType = .done
        return textField
    }
    
    func createSubviews() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.isScrollEnabled = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(startLabel)
        startLabel.font = UIFont.boldSystemFont(ofSize: 18)
        startLabel.textColor = .black
        startLabel.backgroundColor = .clear
        startLabel.text = "Step 1 - Start"
        startLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.width.equalTo(150)
            make.height.equalTo(20)
        }
        
        scrollView.addSubview(firstHintLabel)
        firstHintLabel.font = UIFont.systemFont(ofSize: 16)
        firstHintLabel.text = "First, start with entering your email for logging on to the system."
        firstHintLabel.textColor = .black
        firstHintLabel.backgroundColor = .clear
        firstHintLabel.numberOfLines = 0
        firstHintLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(startLabel.snp.bottom).offset(15)
            make.width.equalTo(UIScreen.main.bounds.width - 30)
        }

        scrollView.addSubview(emailTextField)
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        emailTextField.placeholder = "Email"
        emailTextField.textColor = .black
        emailTextField.placeHolderColor = .gray
        emailTextField.backgroundColor = .white
        emailTextField.layer.cornerRadius = 4
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        
        emailTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(firstHintLabel.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(40)
        }

        scrollView.addSubview(startButton)
        startButton.addTarget(self, action: #selector(startEmailAction), for: .touchUpInside)
        startButton.backgroundColor = Color_Hex(0x008CBA)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 4
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.gray.cgColor
        startButton.setTitle("Start verification process", for: .normal)
        startButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(emailTextField.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(40)
        }

        scrollView.addSubview(verifyLabel)

        verifyLabel.font = UIFont.boldSystemFont(ofSize: 18)
        verifyLabel.text = "Step 2 - Verify"
        verifyLabel.textColor = .black
        verifyLabel.backgroundColor = .clear
        verifyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(startButton.snp.bottom).offset(30)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(20)
        }

        scrollView.addSubview(verifyHintLabel)
        verifyHintLabel.font = UIFont.systemFont(ofSize: 16)
        verifyHintLabel.textColor = .black
        verifyHintLabel.backgroundColor = .clear
        verifyHintLabel.text = "After running step 1, you will recieve an email with a verification code, enter the code in the field below to logon."
        verifyHintLabel.numberOfLines = 0
        verifyHintLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(UIScreen.main.bounds.width - 30)
            make.top.equalTo(verifyLabel.snp.bottom).offset(15)
        }

        scrollView.addSubview(codeTextField)
        codeTextField.font = UIFont.systemFont(ofSize: 16)
        codeTextField.placeholder = "Verification code"
        codeTextField.textColor = .black
        codeTextField.placeHolderColor = .gray
        codeTextField.backgroundColor = .white
        codeTextField.layer.cornerRadius = 4
        codeTextField.layer.borderWidth = 1
        codeTextField.layer.borderColor = UIColor.gray.cgColor
        codeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(verifyHintLabel.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(40)
        }

        scrollView.addSubview(verifyButton)
        verifyButton.backgroundColor = Color_Hex(0x008CBA)
        verifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.borderWidth = 1
        verifyButton.layer.borderColor = UIColor.gray.cgColor
        verifyButton.layer.cornerRadius = 4
        verifyButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(codeTextField.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(40)
        }
        
        verifyButton.addTarget(self, action: #selector(verifyAction), for: .touchUpInside)

        scrollView.addSubview(tokenHintLabel)
        tokenHintLabel.font = UIFont.systemFont(ofSize: 16)
        tokenHintLabel.textColor = .black
        tokenHintLabel.backgroundColor = .clear
        
        tokenHintLabel.text = "Token (will be entered here after sucessful logon):"
        tokenHintLabel.numberOfLines = 0
        tokenHintLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(verifyButton.snp.bottom).offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        scrollView.addSubview(tokenTextField)
        tokenTextField.font = UIFont.systemFont(ofSize: 16)
        tokenTextField.placeholder = "Token after login"
        tokenTextField.textColor = .black
        tokenTextField.placeHolderColor = .gray
        tokenTextField.backgroundColor = .white
        tokenTextField.layer.cornerRadius = 4
        tokenTextField.layer.borderWidth = 1
        tokenTextField.layer.borderColor = UIColor.gray.cgColor
        tokenTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(tokenHintLabel.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(40)
        }
        
        scrollView.addSubview(tenansLabel)
        tenansLabel.font = UIFont.boldSystemFont(ofSize: 16)
        tenansLabel.text = "Login complete, find tenants"
        tenansLabel.numberOfLines = 0
        tenansLabel.textColor = .black
        tenansLabel.backgroundColor = .clear
        tenansLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(UIScreen.main.bounds.width - 30)
            make.top.equalTo(tokenTextField.snp.bottom).offset(30)
        }

        scrollView.addSubview(getMobileButton)
        getMobileButton.backgroundColor = Color_Hex(0x008CBA)
        getMobileButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        getMobileButton.setTitle("Get mobile keys", for: .normal)
        getMobileButton.setTitleColor(.white, for: .normal)
        
        getMobileButton.layer.borderWidth = 1
        getMobileButton.layer.borderColor = UIColor.gray.cgColor
        getMobileButton.layer.cornerRadius = 4
        getMobileButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(tenansLabel.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(40)
        }
        
        getMobileButton.addTarget(self, action: #selector(getMobileAction), for: .touchUpInside)

        scrollView.addSubview(getLocksLabel)
        getLocksLabel.font = UIFont.boldSystemFont(ofSize: 18)
        getLocksLabel.text = "Get all locks"
        getLocksLabel.textColor = .black
        getLocksLabel.backgroundColor = .clear
        getLocksLabel.numberOfLines = 0
        getLocksLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(getMobileButton.snp.bottom).offset(30)
            make.width.equalTo(Screen_Width - 30)
        }

        scrollView.addSubview(getLocksButton)
        getLocksButton.backgroundColor = Color_Hex(0x008CBA)
        getLocksButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        getLocksButton.setTitle("Get all locks", for: .normal)
        getLocksButton.setTitleColor(.white, for: .normal)
        
        getLocksButton.layer.borderWidth = 1
        getLocksButton.layer.borderColor = UIColor.gray.cgColor
        getLocksButton.layer.cornerRadius = 4
        getLocksButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(getLocksLabel.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(40)
        }
        
        getLocksButton.addTarget(self, action: #selector(getLockAction), for: .touchUpInside)
        
        scrollView.addSubview(locksView)
        locksView.backgroundColor = .clear
        locksView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(getLocksButton.snp.bottom).offset(15)
            make.width.equalTo(Screen_Width - 30)
            make.height.equalTo(0)
        }
        
        updateConstraintsIfNeeded()
        layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.scrollView.contentSize = CGSize(width: Screen_Width, height: 90 + self.getLocksButton.frame.origin.y)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEdit)))
    }
    
    
    
    @objc func endEdit() {
        endEditing(true)
    }
    
    @objc func startEmailAction(sender: Any) {
        guard let emailText = emailTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines), !emailText.isEmpty else {
            return
        }
        if !emailText.isVaildEmail() {
            return
        }
        LockyService.startVerify(email: emailText) {[weak self] result, error in
            if result {
                self?.email = emailText
            } else {
                self?.email = nil
            }
        }
    }
    
    @objc func verifyAction(sender: Any) {
        guard let emailText = emailTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines), !emailText.isEmpty else {
            return
        }
        if !emailText.isVaildEmail() {
            return
        }

        guard let code = codeTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines), !code.isEmpty else {
            return
        }
        LockyService.verify(email: emailText, code: code) {[weak self] token in
            guard let token = token else {
                return
            }
            if token.token.isEmpty {
                return
            } else {
                self?.tokenModel = token
                self?.tokenTextField.text = token.token
            }
        }
    }
    
    @objc func getMobileAction(sender: Any) {
        guard let token = tokenModel, !token.token.isEmpty else {
            return
        }
        LockyService.getMobileKeys(token: token.token) {[weak self] result, tenantList in
            if result {
                self?.mobileKeyList = tenantList
            }
        }
    }
    
    @objc func getLockAction(sender: Any) {
        guard let mobileKeyList = mobileKeyList else {
            return
        }
        var needRefresh = true
        LockyService.getAllLocks(mobileKeyList) {[weak self] locks, loadFinished in
            if needRefresh {
                self?.locksList.removeAll()
                self?.customLocksView(needRefresh: true, locks: locks)
                self?.locksList.append(contentsOf: locks)
                needRefresh = false
            } else {
                self?.customLocksView(needRefresh: false, locks: locks)
                self?.locksList.append(contentsOf: locks)
            }
            if loadFinished {
                self?.lockyHelper.scanForPeripherals()
            }
        }
    }
    
    func customLocksView (needRefresh: Bool, locks: [LockyMobile]) {
        let tagDelta = self.locksList.count
        if needRefresh {
            for view in locksView.subviews {
                view.removeFromSuperview()
            }
        }
        var yOrigin = locksList.count * 84
        
        for k in locks.indices {
            let lock = locks[k]
            let cView = customLockItemView(lock: lock, tag: k + 1 + tagDelta, frame: CGRect(x: 0, y: yOrigin, width: Int(Screen_Width - 30), height: 84))
            locksView.addSubview(cView)
            yOrigin += 84
        }
        locksView.snp.updateConstraints() { make in
            make.height.equalTo(yOrigin)
        }
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 60 + getLocksButton.frame.origin.y + CGFloat(yOrigin) + 52)
    }
    
    private func customLockItemView(lock: LockyMobile, tag: Int, frame: CGRect)->UIView {
        let cView = UIView(frame: frame)
        cView.backgroundColor = .clear
        let hostView = UIView(frame: CGRect(x: 0, y: 10, width: Screen_Width - 30, height: 64))
        cView.addSubview(hostView)
        hostView.tag = 1
        hostView.layer.cornerRadius = 4
        hostView.backgroundColor = Color_Hex(0xEDEDED)
        let nameLabel = UILabel(frame: CGRect(x: 15, y: 25, width: Screen_Width - 60, height: 34))
        nameLabel.text = lock.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.backgroundColor = .clear
        cView.addSubview(nameLabel)
        cView.tag = tag
        let connectButton = UIButton(frame: CGRect(x: Screen_Width - 150, y: 22, width: 105, height: 40))
        cView.addSubview(connectButton)
        connectButton.layer.cornerRadius = 4
        connectButton.backgroundColor = Color_Hex(0x008CBA)
        connectButton.setTitle("Pulse open", for: .normal)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        connectButton.addTarget(self, action: #selector(connectDevice), for: .touchUpInside)
        connectButton.isHidden = true
        nameLabel.tag = 2
        connectButton.tag = 3
        if let deviceList = deviceList {
            for item in deviceList {
                if item.deviceId == lock.id {
                    hostView.backgroundColor = Color_Hex(0x9CA06B)
                    connectButton.isHidden = false
                    nameLabel.frame = CGRect(x: 15, y: 25, width: Screen_Width - 200, height: 34)
                    break
                }
            }
        }
        return cView
    }
    
    private func updateLockStatus(_ devices: [LockyDeviceModel]) {
        deviceList = devices
        for k in locksList.indices {
            let lock = locksList[k]
            let cView = locksView.viewWithTag(k + 1)
            if let deviceList = deviceList {
                for item in deviceList {
                    if item.deviceId == lock.id {
                        if let hostView = cView?.viewWithTag(1) {
                            hostView.backgroundColor = Color_Hex(0x9CA06B)
                        }
                        if let nameLabel = cView?.viewWithTag(2) {
                            nameLabel.frame = CGRect(x: 15, y: 25, width: Screen_Width - 200, height: 34)
                        }
                        if let connectButton = cView?.viewWithTag(3) {
                            connectButton.isHidden = false
                        }
                        break
                    }
                }
            }
        }
    }
    
    @objc func connectDevice(sender: UIButton) {
        let superView = sender.superview
        let tag = superView!.tag - 1
        let lock = locksList[tag]
        guard let deviceList = deviceList else {
            return
        }
        packageSignalType = .PulseOpen
        for device in deviceList {
            if lock.id == device.deviceId {
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

extension LockyView: LockyBLEProtocol {
    
    public func didDiscover (_ devices: [LockyDeviceModel]) {
        updateLockStatus(devices)
    }
    
    public func didConnect(device: LockyDeviceModel) {
        connectedDevice = device
        writeData(device: device)
    }
    
    public func didDisconnect (device: LockyDeviceModel) {
        connectedDevice = nil
    }
    
    public func didWrite(error: Error?) {
        if let _ = error {
            return
        }
    }
    
    public func didRead (device: LockyDeviceModel?, data: String?) {
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

private extension LockyView {
    func getLockFromDevice(_ device: LockyDeviceModel) -> LockyMobile? {
        for lock in locksList {
            if lock.id == device.deviceId {
                return lock;
            }
        }
        return nil
    }
    
    func writeData(device: LockyDeviceModel) {
        guard let lock = getLockFromDevice(device) else {
            return
        }
        
        connectedLock = lock
        LockyService.downloadPackage(token: lock.token!, deviceId: device.deviceId, tenantId: lock.tenantId!, type: packageSignalType) {[weak self] package in
            guard let package = package else {
                return
            }
            let dataFromBase64 = Data(base64Encoded: package)
            if self?.packageSignalType == .PulseOpen && dataFromBase64 != nil {
                self?.lockyHelper.writeData(device: device, data: dataFromBase64!)
            }
        }
    }
}

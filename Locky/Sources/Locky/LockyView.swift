//
//  LockyView.swift
//  Locky
//  create the ui to enter email, verify and so on.
//
//  Created by Shaolin Zhou on 2022/10/24.
//

import UIKit
import SnapKit

public class LockyView: UIView {
    private let scrollView = UIScrollView()
    private let startLabel = UILabel()
    private let firstHintLabel = UILabel()
    private let emailTextField = UITextField()
    private let startButton = UIButton()
    
    private let verifyLabel = UILabel()
    private let verifyHintLabel = UILabel()
    private let codeTextField = UITextField()
    private let verifyButton = UIButton()
    
    private let tokenHintLabel = UILabel()
    private let tokenTextField = UITextField()
    
    private let tenansLabel = UILabel()
    private let getMobileButton = UIButton()
    private let getLocksLabel = UILabel()
    private let getLocksButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LockyView {
    func createSubviews() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(startLabel)
        startLabel.font = UIFont.boldSystemFont(ofSize: 16)
        startLabel.text = "Step 1 - Start"
        startLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(18)
        }
        
        scrollView.addSubview(firstHintLabel)
        firstHintLabel.font = UIFont.systemFont(ofSize: 14)
        firstHintLabel.text = "First, start with entering your email for logging on to the system."
        firstHintLabel.numberOfLines = 0
        firstHintLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(startLabel).offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        scrollView.addSubview(emailTextField)
        emailTextField.font = UIFont.systemFont(ofSize: 14)
        emailTextField.placeholder = "Email"
        emailTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(firstHintLabel).offset(15)
            make.width.equalTo(100)
            make.height.equalTo(24)
        }
        
        scrollView.addSubview(startButton)
        
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        startButton.setTitle("Start verification process", for: .normal)
        startButton.snp.makeConstraints { make in
            make.left.equalTo(emailTextField.snp.right).offset(15)
            make.top.equalTo(firstHintLabel).offset(15)
            make.right.equalToSuperview().offset(15)
            make.height.equalTo(24)
        }
        
        scrollView.addSubview(verifyLabel)
        
        verifyLabel.font = UIFont.boldSystemFont(ofSize: 16)
        verifyLabel.text = "Step 2 - Verify"
        verifyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(emailTextField).offset(30)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(18)
        }
        
        scrollView.addSubview(verifyHintLabel)
        verifyHintLabel.font = UIFont.systemFont(ofSize: 14)
        verifyHintLabel.text = "After running step 1, you will recieve an email with a verification code, enter the code in the field below to logon."
        verifyHintLabel.numberOfLines = 0
        verifyHintLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(verifyLabel).offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        scrollView.addSubview(codeTextField)
        codeTextField.font = UIFont.systemFont(ofSize: 14)
        codeTextField.placeholder = "Verification code"
        codeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(verifyHintLabel).offset(15)
            make.width.equalTo(100)
            make.height.equalTo(24)
        }
        
        scrollView.addSubview(verifyButton)
        
        verifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.snp.makeConstraints { make in
            make.left.equalTo(codeTextField.snp.right).offset(15)
            make.top.equalTo(firstHintLabel).offset(15)
            make.right.equalToSuperview().offset(15)
            make.height.equalTo(24)
        }
        
        
    }
}

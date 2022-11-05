//
//  LockyViewController.swift
//  LockyDemo
//
//  Created by Shaolin Zhou on 2022/10/24.
//

import UIKit
import Locky

class LockyViewController: UIViewController {
    private lazy var lockyView: LockyView = {
        let view = LockyView(frame: CGRect(x: 0, y: 24, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 24))
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
}

extension LockyViewController {
    func createSubviews() {
        view.backgroundColor = .white
        view.addSubview(lockyView)
    }
}


//
//  Data+String.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/11/4.
//

import Foundation

extension Data {
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }

    func hexDescription() -> String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

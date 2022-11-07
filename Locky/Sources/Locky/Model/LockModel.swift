//
//  LockModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/31.
//

import Foundation

public struct LockyMobile: Decodable {
    public var id: String = ""
    public var name: String = ""
    public var token: String?
    public var tenantId: String?
}

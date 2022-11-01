//
//  LockModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/31.
//

import Foundation

struct LockyMobile: Decodable {
    var id: String = ""
    var name: String = ""
    var token: String?
    var tenantId: String?
}

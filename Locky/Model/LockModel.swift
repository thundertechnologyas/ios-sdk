//
//  LockModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/31.
//

import Foundation
///Lock model with token and tenantId. it is used internal.
struct LockModel: Decodable {
    var id: String = ""
    var name: String = ""
    var token: String?
    var tenantId: String?
}

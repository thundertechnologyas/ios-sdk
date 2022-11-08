//
//  TokenModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/30.
//

import Foundation
///data from verify api
struct TokenModel: Decodable {
    var token: String = ""
    var dateCreated: String = ""
    var description: String = ""
}

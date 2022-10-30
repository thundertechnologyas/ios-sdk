//
//  TokenModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/30.
//

import Foundation

struct TokenModel: Decodable {
    let token: String
    let dateCreated: String
    let description: String
}

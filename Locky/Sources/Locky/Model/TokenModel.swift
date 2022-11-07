//
//  TokenModel.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/30.
//

import Foundation

public struct TokenModel: Decodable {
    public let token: String
    public let dateCreated: String
    public let description: String
}

//
//  Network.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/25.
//

import Foundation

class Network {
    func decode<T: Decodable>(type: T.Type, data: Data) throws -> T {
        let jsonDecodable = JSONDecoder()
        return try jsonDecodable.decode(type, from: data)
    }
}

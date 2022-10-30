//
//  Network.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/25.
//

import Foundation

open class Network {
    class func decode<T: Decodable>(type: T.Type, data: Data) throws -> T {
        let jsonDecodable = JSONDecoder()
        return try jsonDecodable.decode(type, from: data)
    }
    
    class func encode<T: Encodable>(from data: T) throws -> String? {
        let jsonEncoder = JSONEncoder()
        let json = try jsonEncoder.encode(data)
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
    
    
               
}

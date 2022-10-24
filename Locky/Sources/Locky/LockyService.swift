//
//  LockyService.swift
//  Locky
//  service to restful api.
//
//  Created by Shaolin Zhou on 2022/10/24.
//

import Foundation
import Alamofire

public class LockyService: Network {
    func startVerify(email: String, completion: @escaping ((Result<Bool?,Error>) -> Void)) {
        var params = [String: Any]()
        params["domain"] = Environment.domain
        params["email"] = email
        AF.request(Environment.authEndpoint + "api/simpleauth/start",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"]).responseData { response in
            guard let data = response.data else {
                return
            }
        }
    }
}

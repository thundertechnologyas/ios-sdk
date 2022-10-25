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
    
    func verify(email: String, code: String, completion: @escaping ((Result<String?,Error>) -> Void)) {
        var params = [String: Any]()
        params["domain"] = Environment.domain
        params["email"] = email
        params["code"] = code
        AF.request(Environment.authEndpoint + "api/simpleauth/verify",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"]).responseData { response in
            guard let data = response.data else {
                return
            }
        }
    }
    
    func getMobileKeys(token: String, completion: @escaping (([LockyMobileKey]?, String?,  Error?) -> Void)) {
        var params = [String: Any]()
        params["domain"] = Environment.domain
        params["token"] = token
        AF.request(Environment.authEndpoint + "/api/simpleauth/mobilekeys",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"]).responseData { response in
            guard let data = response.data else {
                completion(nil, nil, nil)
                return
            }
            let mobileKeyString = data as? String
            guard let dict = data as? [String: String] else {
                completion(nil, mobileKeyString, nil)
                return
            }
            var dataArray:[LockyMobileKey] = []
            for k in dict.keys {
                let tocheck = dict[k]
                let tenantId = (tocheck! as NSString).substring(to: 24)
                let token = (tocheck! as NSString).substring(from: 24)
                dataArray.append(LockyMobileKey(token: token, tenantId: tenantId))
            }
            completion(dataArray, mobileKeyString, nil)
        }
    }
    
    func getAllLocks(mobileKeyString: String, completion: @escaping ((Bool?,  Error?) -> Void)) {
        var params = [String: Any]()
        params["domain"] = Environment.domain
        params["mobilekeylist"] = mobileKeyString
        AF.request(Environment.authEndpoint + "/api/simpleauth/mobilekeys",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"]).responseData { response in
        }
        
    }
}

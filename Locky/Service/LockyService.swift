//
//  LockyService.swift
//  Locky
//  service to restful api.
//
//  Created by Shaolin Zhou on 2022/10/24.
//

import Foundation
import Alamofire

/// The four types to download package
enum PackageSignalType: String {
    case PulseOpen = "pulseopenpackage"
    case ForcedOpen = "forcedopenpackage"
    case ForcedClosed = "forcedclosedpackage"
    case NormalState = "normalstatepackage"
}

class LockyService {
    public class func startVerify(email: String, completion: @escaping ((Bool,  Error?) -> Void)) {
        var params = [String: Any]()
        params["domain"] = Environment.domain
        params["email"] = email
        let url = Environment.authEndpoint + "api/simpleauth/start"
        AF.request(url,
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseData { response in
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    public class func verify(email: String, code: String, completion: @escaping ((TokenModel?) -> Void)) {
        var params = [String: Any]()
        params["domain"] = Environment.domain
        params["email"] = email
        params["code"] = code
        AF.request(Environment.authEndpoint + "api/simpleauth/verify",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseData { response in
            let statusCode = response.response?.statusCode
            guard let data = response.data, statusCode == 200 else {
                completion(nil)
                return
            }
            
            do {
                let model = try Network.decode(type: TokenModel.self, data: data)
                completion(model)
            } catch {
                completion(nil)
            }
        }
    }
    
    public class func getMobileKeys(token: String, completion: @escaping ((Bool, [LockyMobileKey]?) -> Void)) {
        var params = [String: Any]()
        params["domain"] = Environment.domain
        params["token"] = token
        AF.request(Environment.authEndpoint + "api/simpleauth/mobilekeys",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil).responseData { response in
            guard let data = response.data else {
                completion(false, nil)
                return
            }
            do {
                let tenantList = try Network.decode(type: [String].self, data: data)
                var dataArray:[LockyMobileKey] = []
                for toCheck in tenantList {
                    let tenantId = (toCheck as NSString).substring(to: 24)
                    let token = (toCheck as NSString).substring(from: 24)
                    dataArray.append(LockyMobileKey(token: token, tenantId: tenantId))
                }
//                let jsonString = try Network.encode(from: tenantList)
                completion(true, dataArray)
                
            } catch {
                completion(false, nil)
            }
        }
    }
    
    public class func getAllLocks(_ mobileKeys: [LockyMobileKey], completion: @escaping (([LockModel], Bool) -> Void)) {
        var loadIndex = 0
        for mobile in mobileKeys {
            var headers = [String: String]()
            headers["tenantId"] = mobile.tenantId
            headers["token"] = mobile.token
            let httpHeaders = HTTPHeaders(headers)
            AF.request(Environment.endpoint + "lockyapi/mobilekey/devices",
                       method: .get,
                       parameters: nil,
                       encoding: URLEncoding.default,
                       headers: httpHeaders).responseData { response in
                loadIndex += 1
                var dataArray:[LockModel] = []
                if let locksData = response.data {
                    do {
                        let lockList = try Network.decode(type: [LockModel].self, data: locksData)
                        for var lock in lockList {
                            lock.token = mobile.token
                            lock.tenantId = mobile.tenantId
                            dataArray.append(lock)
                        }
                       
                    } catch {
                        
                    }
                }
                completion(dataArray, loadIndex >= mobileKeys.count)
            }
        }
    }
    
    public class func downloadPackage(token: String, deviceId: String, tenantId: String, type: PackageSignalType, completion: @escaping ((String?) -> Void)) {
        
        let signal = type.rawValue
        var params = [String: Any]()
        params["deviceId"] = deviceId
        var headers = [String: String]()
        headers["tenantId"] = tenantId
        headers["token"] = token
        let httpHeaders = HTTPHeaders(headers)
        
        AF.request(Environment.endpoint + "lockyapi/mobilekey/" + signal,
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: httpHeaders).responseData { response in
            let statusCode = response.response?.statusCode
            guard let data = response.data, statusCode == 200 else {
                completion(nil)
                return
            }
            do {
                let model = try Network.decode(type: LockyPackage.self, data: data)
                completion(model.data)
            } catch {
                completion(nil)
            }
        }
    }
    
    public class func messageDelivered(token: String, deviceId: String, tenantId: String, payload: [String: Any], completion: @escaping ((Bool) -> Void)) {
        var headers = [String: String]()
        headers["tenantId"] = tenantId
        headers["token"] = token
        headers["Content-Type"] = "application/json"
        let httpHeaders = HTTPHeaders(headers)
        var request = try! URLRequest(url: Environment.endpoint + "lockyapi/mobilekey/msgdelivered?deviceId=" + deviceId, method: .post)
        request.headers = httpHeaders
        request.httpBody = try! JSONSerialization.data(withJSONObject: payload, options: [])
        AF.request(request).responseData { response in
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

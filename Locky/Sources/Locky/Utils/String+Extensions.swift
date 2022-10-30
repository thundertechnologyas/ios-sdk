//
//  String+Addition.swift
//  YouShaQi
//
//  Created by YJMac-QJay on 2/8/2019.
//  Copyright © 2019 HangZhou RuGuo Network Technology Co.Ltd. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto
import CoreText

//MARK: - 常用
extension String {
    /// 判断是否为空
    public var isBlank: Bool {
        if self.isEmpty {
            return true
        }
        
        if self.isKind(of: NSNull.self) {
            return true
        }
        
        if self == "(null)" {
            return true
        }
        
        if self == "null" {
            return true
        }
        
        let str = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if str.isEmpty {
            return true
        }
        
        return false
    }
}

//MARK: - 字符串截取
extension String {
    /// 不包含to
    public func sub(to: Int) -> String? {
        guard isVaild(to: to) else {
            return nil
        }
        let index: String.Index = self.index(startIndex, offsetBy: to)
        return String(self[..<index])
    }
    
    /// 包含from
    public func sub(from: Int) -> String? {
        guard isVaild(from: from) else {
            return nil
        }
        let index: String.Index = self.index(startIndex, offsetBy: from)
        return String(self[index ..< endIndex])
    }
    
    /// 包含from, 不包含to
    public func sub(from: Int, to: Int) -> String? {
        guard isVaild(to: to), isVaild(from: from), from <= to else {
            return nil
        }
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex..<endIndex])
    }
    
    private func isVaild(from: Int) -> Bool {
        from >= 0 && from < count
    }
    
    private func isVaild(to: Int) -> Bool {
        to >= 0 && to <= count
    }
}

//MARK: - 字符串计数单位变形
extension String {
    /// 过滤空白符号，包括空格、换行符、制表符
    public func filterSpace() -> String {
        self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
}

extension String {
    /// 把seconds转换成 分钟:秒钟 样式
    public static func mapToXX2XXFormat(seconds: Int) -> String {
        let minute = String(format: "%02ld", seconds % 3600 / 60)
        let second = String(format: "%02ld", seconds % 60)
        return "\(minute):\(second)"
    }
}

//MARK: - 加密
extension String {
    /// MD5String
    public func yj_MD5String() -> String? {
        if self.isBlank {
            return ""
        }
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: 0)
        return String(format: hash as String)
    }

    /// 把图片数据md5，上传图片时需要
    public static func md5StringFromImage(image: UIImage) -> String {
        guard let imgData = image.jpegData(compressionQuality: 1),
            let rawPointer = imgData.withUnsafeBytes({ $0 }).baseAddress else {
            return ""
        }
        let count = Int(CC_MD5_DIGEST_LENGTH)
        let md: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: count)
        md.initialize(repeating: 0, count: count)
        CC_MD5(rawPointer, CC_LONG(imgData.count), md)
        let imageHash = NSString(format: "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 md[0], md[1], md[2], md[3], md[4], md[5], md[6], md[7], md[8], md[9], md[10], md[11], md[12], md[13], md[14], md[15])
        md.deinitialize(count: count)
        md.deallocate()
        return imageHash as String
    }

    /// 先 md5 再 base64 得到字符串
    public func yj_md5AndBase64Str() -> String? {
        if self.isBlank {
            return ""
        }
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        
        let base64 = Data(bytes: result, count: digestLen)
        let base64Str = base64.base64EncodedString(options: .lineLength64Characters)
        return base64Str
    }
}

//MARK: - URL 相关
extension String {
    /// urlEncode，会先解码再转码，以避免多次转码做成的问题
    public func yjs_queryEncodedURLString() -> String? {
        self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    public func yjs_allEncodedURLString() -> String? {
        #if TARGET_TTYY
        let allowed = CharacterSet(charactersIn: "!*'();@+$,[]").inverted
        return self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: allowed)
        #else
        let allowed = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted
        return self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: allowed)
        #endif

    }
    
    /// 是否是 itunes 的链接
    public func isiTunesURL() -> Bool {
        !self.isBlank && self.contains("//itunes.apple.com")
    }
    
    /// 是否是 appstore 的链接
    public func isAppStoreURL() -> Bool {
        self.hasPrefix("itms-apps://")
    }
    
    /// 获取URL的参数字典
    public func getUrlParams() -> [String : String] {
        let components = self.yjs_queryEncodedURLString()
            .flatMap { NSURLComponents(string: $0) }
            .flatMap { $0.queryItems }
        guard let queryItems = components else {
            return [:]
        }
        return queryItems.reduce(into: [:]) { (result, item) in
            if let value = item.value {
                result[item.name] = value
            }
        }
    }
}

extension String {
    /// 判断是否是邮箱
    public func isVaildEmail() -> Bool {
        let numberOfMatches = self.numberOfMatchesInString(string: self, pattern:"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        if numberOfMatches > 0 {
            return true
        }
        return false
    }
    
    private func numberOfMatchesInString(string:String,pattern:String) -> Int {
        let regex = try? NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        return regex?.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: string.count)) ?? 0
    }
}

extension String {
    /// 在指定的宽高下，计算文本宽高
    public func yjs_stringSize(fontSize: CGFloat, size: CGSize) -> CGRect {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
        let rect: CGRect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect
    }
    
    /// 在指定的宽度下，计算文本宽高
    public func size(fixWidth: CGFloat, font: UIFont) -> CGSize {
        let rect = (self as NSString).boundingRect(with: CGSize(width: fixWidth, height: CGFloat(MAXFLOAT)), options: .truncatesLastVisibleLine, attributes: [:], context: nil)
        return rect.size
    }
    
    /// 在指定宽度、行数的范围下，计算文本的宽高
    public func size(fixWidth: CGFloat, numberOfLines: Int, font: UIFont) -> CGSize {
        let label = UILabel()
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.text = self
        label.font = font
        let labelSize = label.sizeThatFits(CGSize(width: fixWidth, height: CGFloat(MAXFLOAT)))
        let height = ceil(labelSize.height)
        let width = ceil(labelSize.width)
        return CGSize(width: width, height: height)
    }
}

extension Array where Element == String {
    public func toString(joinBy: String) -> String {
        reduce(into: "") { (result, substring) in
            if result.isEmpty {
                result.append(substring)
            } else {
                result.append("\(joinBy)\(substring)")
            }
        }
    }
}

extension Optional where Wrapped == String {
    public var isBlank: Bool {
        map { $0.isBlank } ?? true
    }
}

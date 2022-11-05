//
//  String+Addition.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/10/25.
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

extension String {
    
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

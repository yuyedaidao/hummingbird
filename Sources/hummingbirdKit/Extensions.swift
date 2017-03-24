//
//  Extensions.swift
//  hummingbird
//
//  Created by 王叶庆 on 2017/3/15.
//
//

import Foundation
import PathKit

extension String {
    var fullRange: NSRange {
        return NSMakeRange(0, self.utf16.count)
    }
    
    func plainName(extensions: [String]) -> String {
        let p = Path(self.lowercased())
        let result: String
        
        if let ext = p.extension, extensions.contains(ext) {
            result = p.lastComponentWithoutExtension
        } else {
            result = p.lastComponent
        }
        var r = result
        if r.hasSuffix("@2x") || r.hasSuffix("@3x") {
            r = String(describing: result.utf16.dropLast(3))
        }
        return r
    }
    

    func similarPatternWithNumberIndex(other: String) -> Bool {
        let matches = digitalRegex.matches(in: other, options: [], range: other.fullRange)
        guard matches.count >= 1 else {
            return false
        }
        let lastMatch = matches.last!
        let digitalRange = lastMatch.rangeAt(1)
        
        var prefix: String?
        var suffiex: String?
        
        let digitalLocation = digitalRange.location
        if digitalLocation != 0 {
            let index = other.index(other.startIndex, offsetBy: digitalLocation)
            prefix = other.substring(to: index)
        }
        
        let digitalMaxRange = NSMaxRange(digitalRange)
        if digitalMaxRange < other.utf8.count {
            let index = other.index(other.startIndex, offsetBy: digitalMaxRange)
            suffiex = other.substring(from: index)
        }
        
        switch (prefix, suffiex) {
        case (nil, nil): return false
        case (let p?, nil): return hasPrefix(p)
        case (nil, let s?): return hasSuffix(s)
        case (let p?, let s?): return hasPrefix(p) && hasSuffix(s)
        }
        
    }
    
}

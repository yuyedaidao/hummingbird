//
//  StringsSearchRule.swift
//  hummingbird
//
//  Created by 王叶庆 on 2017/3/15.
//
//

import Foundation

protocol StringsSearcher {
    func search(in content: String) -> Set<String>
}

protocol RegexStringSearcher: StringsSearcher {
    var extensions: [String] {get}
    var patterns: [String] {get}
}

extension RegexStringSearcher {
    func search(in content: String) -> Set<String> {
        var results = Set<String>()
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                print("Failed to create pattern: \(pattern)")
                continue
            }
            let matches = regex.matches(in: content, options: [], range: content.fullRange)
            for checkingResult in matches {
                let range = checkingResult.rangeAt(1)
                let extracted = NSString(string: content).substring(with: range)
                results.insert(extracted.plainName(extensions: extensions))
            }
        }
        return results
    }
}

struct SwiftSearcher: RegexStringSearcher {
    let extensions: [String]
    let patterns = ["\"(.+?)\""]
}

struct ObjSearcher: RegexStringSearcher {
    let extensions: [String]
    let patterns = ["@\"(.*?)\""]
}

struct XibSearcher: RegexStringSearcher {
    let extensions: [String]
    let patterns = [""]
}

struct GeneralSearcher: RegexStringSearcher {
    let extensions: [String]
    var patterns: [String] {
        if extensions.isEmpty {
            return []
        }
        let joined = extensions.joined(separator: "|")
        return ["\"(.+?)\\.(\(joined))\""]        
    }
}

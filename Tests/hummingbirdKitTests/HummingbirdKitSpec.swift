//
//  HummingbirdKitSpec.swift
//  hummingbird
//
//  Created by Wang on 2017/3/17.
//
//

import Foundation
import Spectre
import PathKit
@testable import hummingbirdKit

public func specHummingbirdKit() {
    let testFilePath = Path(#file).parent()
    describe("HummingbirdKit") {
        $0.describe("String Extension") {
            $0.it("should return plain name") {
                let s1 = "image@2x.png"
                let s2 = "/usr/local/bin/find"
                let s3 = "image@3x.png"
                let s4 = "local.host"
                let s5 = "local.png"
                
                let exts = ["png"]
                try expect(s1.plainName(extensions: exts)) == "image"
                try expect(s2.plainName(extensions: exts)) == "find"
                try expect(s3.plainName(extensions: exts)) == "image"
                try expect(s4.plainName(extensions: exts)) == "local.host"
                try expect(s5.plainName(extensions: exts)) == "local"
            }
        }
      
        $0.describe("String searchers") {
            $0.it("Swift Searcher works") {
                let s1 = "UIImage(named: \"my_image\")"
                let s2 = "adlg\"aa\"ldgjals ada\"_fkjas\""
                let s3 = "let name = \"close_button@2x\""
                let s4 = "test string: \"local.png\""
                let s5 = "test string : \"local.host\""
                let s6 = "\"cong.png\""
                let searcher = SwiftSearcher(extensions: ["png"])
                let result = [s1, s2, s3, s4, s5, s6].map{
                    searcher.search(in: $0)
                }
                
                try expect(result[0]) == Set(["my_image"])
                try expect(result[1]) == Set(["aa", "_fkjas"])
                try expect(result[2]) == Set(["close_button"])
                try expect(result[3]) == Set(["local"])
                try expect(result[4]) == Set(["local.host"])
                try expect(result[5]) == Set(["cong"])
            }
        }
        
        $0.describe("HummingbirdKit Path") {
            $0.it("should find directory") {
                try expect(testFilePath + "HummingbirdKitTests.swift") == "/Users/wang/Desktop/Work/Project/1703/hummingbird/Tests/hummingbirdKitTests/HummingbirdKitTests.swift"
            }
        }
        $0.describe("HummingbirdKit Function") {
            $0.it("should find ") {
                print(FileManager.default.currentDirectoryPath)
                let path = testFilePath + "HummingbirdKitTests.swift"
                
                let hummingbird = Hummingbird(projectPath: path.string, excludedPaths: [], resourceExtensions: ["png", "jpg"], fileExtensions: ["swift"])
                let result = hummingbird.allStringInUse()
                try expect(result) == Set(["a", "cong", "loca.host"])
            }
        }
    }

}

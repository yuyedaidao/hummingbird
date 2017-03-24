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
            $0.it("should filter similar pattern string") {
                
                let s1 = "suffix_01"
                let s1Pattern = "suffix_%d"
                let result = s1Pattern.similarPatternWithNumberIndex(other: s1)
                try expect(result).to.beTrue()
                
                let s2 = "1prefix"
                let s2Pattern = "\\(i)prefix"
                let result2 = s2Pattern.similarPatternWithNumberIndex(other: s2)
                try expect(result2).to.beTrue()
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
            
            $0.it("can find all resouce in project") {
                let fixture = Path(#file).parent().parent() + "Fixtures"
                let path = fixture + "FindProcess"
                let hummingbird = Hummingbird(projectPath: path.string, excludedPaths:["Ignore"] , resourceExtensions: ["png", "jpg", "imageset"], fileExtensions: [])
                let result = hummingbird.allResources()
                let expected = [
                    "image1" : (path + "image1.png").string,
                    "image3" : (path + "Subfolder/image3.imageset").string,
                    "image4" : (path + "Subfolder/image4.png").string,
                ]
                try expect(result) == expected
            }
            
            $0.it("should filter unused") {
                let all = ["suffix_1" : "suffix_1.jpg",
                           "suffix_2" : "suffix_2.jpg",
                           "suffix_3" : "suffix_3.jpg",
                           "1_prefix" : "1_prefix.jpg",
                           "2_prefix" : "2_prefix.jpg",
                           "3_prefix" : "3_prefix.jpg",
                           "aa1_prefix" : "aa1_prefix.jpg",
                           "aa2_prefix" : "aa2_prefix.jpg",
                           "aa3_prefix" : "aa3_prefix.jpg",
                           "bb_as" : "adfagds"
                ]
                
                let used: Set<String> = ["suffix_\\(d)", "aa\\(d)_prefix"]
                let result = Hummingbird.filterUnused(from: all, used: used)
                let expected = Set(["adfagds"])
                try expect(result) == expected
            }
        }
        
        $0.describe("FindProcess") {
            $0.it("shoulf find correct files") {
                let fixture = Path(#file).parent().parent() + "Fixtures"
                let path = fixture + "FindProcess"
                let process = FindProcess(path: path, extensions: ["png", "jpg", "imageset"], exclued: ["Ignore"])
                let result = process?.execute() ?? []
                let expected: Set<String> = Set(["/Users/wang/Desktop/Work/Project/1703/hummingbird/Tests/Fixtures/FindProcess/Subfolder/image3.imageset", "/Users/wang/Desktop/Work/Project/1703/hummingbird/Tests/Fixtures/FindProcess/Subfolder/image3.imageset/image3.png", "/Users/wang/Desktop/Work/Project/1703/hummingbird/Tests/Fixtures/FindProcess/Subfolder/image4.png", "/Users/wang/Desktop/Work/Project/1703/hummingbird/Tests/Fixtures/FindProcess/image1.png"])
                try expect(result) == expected
            }
        }
        
    }

}

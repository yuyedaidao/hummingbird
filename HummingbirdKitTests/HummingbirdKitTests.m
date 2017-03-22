//
//  HummingbirdKitTests.m
//  HummingbirdKitTests
//
//  Created by Wang on 2017/3/17.
//
//

#import <XCTest/XCTest.h>
@testable import hummingbirdKit
import Spectre

@interface HummingbirdKitTests : XCTestCase

@end

@implementation HummingbirdKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    //
    //  HummingbirdKitSpec.swift
    //  hummingbird
    //
    //  Created by Wang on 2017/3/17.
    //
        print("测试不执行呢")
        describe("HummingbirdKit") {
                //        $0.before {
                //            print("Spec before")
                //        }
            $0.describe("String Extension") {
                $0.it("should return plain name") {
                    let s1 = "image@2x.png"
                    let s2 = "/usr/local/bin/find"
                    let s3 = "image@3x.png"
                    
                    try expect(s1.plainName) == "image"
                    try expect(s2.plainName) == "find"
                    try expect(s3.plainName) == "image"
                }
            }
                //        $0.after {
                //            print("Spec after")
                //        }
        }
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

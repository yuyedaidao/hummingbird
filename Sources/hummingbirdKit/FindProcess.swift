//
//  FindProcess.swift
//  hummingbird
//
//  Created by 王叶庆 on 2017/3/19.
//
//

import Foundation
import PathKit

struct FindProcess {
    let p: Process
    
    init?(path: Path, extensions: [String], exlude: [Path]) {
        p = Process()
        p.launchPath = "/usr/bin/find"
        guard !extensions.isEmpty else {
            return nil
        }
        p.arguments
    }
}

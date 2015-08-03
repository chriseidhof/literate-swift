//
//  CLI.swift
//  LiterateSwift
//
//  Created by Chris Eidhof on 03/08/15.
//  Copyright © 2015 Chris Eidhof. All rights reserved.
//

import Foundation
import CommonMark

public func processMarkdownOrStdIn(process: [Block] -> ()) {
    guard Process.arguments.count == 2 else {
        fatalError("Need a single argument: a .md file to be processed")
    }

    let filename: String = Process.arguments[1]
    let node: Node = {
        if filename == "--" {
            let fileHandle = NSFileHandle.fileHandleWithStandardInput()
            let inputData = fileHandle.readDataToEndOfFile()
            let str = NSString(data: inputData, encoding:NSUTF8StringEncoding)! as String
            return Node(markdown: str)!
        } else {
            return Node(filename: filename)!
        }
        }()

    process(node.elements)
}
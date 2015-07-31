//
//  Library.swift
//  LiterateSwift
//
//  Created by Chris Eidhof on 31/07/15.
//  Copyright © 2015 Chris Eidhof. All rights reserved.
//

import Foundation

extension SequenceType {
    func takeWhile(f: Generator.Element -> Bool) -> [Generator.Element] {
        var result: [Generator.Element] = []
        for element in self {
            guard f(element) else { break }
            result.append(element)
        }
        return result
    }
}

prefix operator / { }

prefix func /(string: String) -> NSRegularExpression {
    return try! NSRegularExpression(pattern: string, options: NSRegularExpressionOptions())
}

infix operator =~ { associativity left }

func =~(string: String, regex: NSRegularExpression) -> Bool {
    let matches = regex.numberOfMatchesInString(string,
        options: NSMatchingOptions(),
        range: NSMakeRange(0, (string as NSString).length))
    return matches > 0
}
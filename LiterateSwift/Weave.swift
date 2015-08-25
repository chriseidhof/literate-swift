//
//  Weave.swift
//  LiterateSwift2
//
//  Created by Chris Eidhof on 16/06/15.
//  Copyright © 2015 Unsigned Integer. All rights reserved.
//

import Foundation
import CommonMark


private let nameRegex = /"^<<(\\w+)>>$"

func matchName(string: String) -> String? {
    let matches = nameRegex.matchesInString(string, options: NSMatchingOptions(), range: NSMakeRange(0, (string as NSString).length))
    guard matches.count == 1 else { return nil }
    return (string as NSString).substringWithRange(matches[0].rangeAtIndex(1))
}

public enum WeaveError: ErrorType {
    case CouldNotFindSnippet(name: String)
}

public func replaceSnippet(directory: String)(child: Block) throws -> [Block] {
    if case let .CodeBlock(code, language) = child where language == "highlight-swift",
        let name = matchName(code) {
            guard let code = findSnippet(directory)(name: name) else {
              throw WeaveError.CouldNotFindSnippet(name: name)
            }
            return [Block.CodeBlock(text: code, language: language)]
    } else {
        return [child]
    }
}

func findNestedFiles(directory: String, test: String -> Bool) -> [String] {
    do {
        let fm = NSFileManager.defaultManager()
        return try fm.subpathsOfDirectoryAtPath(directory).filter(test)
    } catch {
        return []
    }
}

func extractSnippet(filename: String, snippetName: String) -> String? {
    let contents: String = try! NSString(contentsOfFile: filename, encoding: NSUTF8StringEncoding) as String
    var result: [String]?
    let regex = /"^\\s*//\\s+<<\(snippetName)>>"
    let closeRegex = /"^\\s*//\\s+<</\(snippetName)>>"
    for line in contents.lines {
        if line =~ closeRegex {
            guard let lines = result else { return "" }
            let snippetIndentation = lines.map { $0.characters.takeWhile { $0 == " " }.count}.reduce(Int.max, combine: min)
            var index = lines[0].startIndex
            for _ in 0..<snippetIndentation { index = index.successor() }
            let indented: [String] = lines.map { $0.substringFromIndex(index) }
            return indented.joinWithSeparator("\n")
        } else if result != nil {
            result?.append(line)
        } else if line =~ regex {// start
            result = []
        }
    }
    return nil
}

func findSnippet(directory: String)(name: String) -> String? {
    let files = findNestedFiles(directory) { ($0 as NSString).pathExtension == "swift" }
    for swiftFile in files  {
        if let snippet = extractSnippet((directory as NSString).stringByAppendingPathComponent(swiftFile), snippetName: name) {
            return snippet
        }
    }
    return nil
}

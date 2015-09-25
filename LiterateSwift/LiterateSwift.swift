//
//  LiterateSwift.swift
//  LiterateSwiftFramework
//
//  Created by Chris Eidhof on 22/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation

import CommonMark

func isCodeBlock(matchingLanguage: String? -> Bool)(element: Block) -> Bool {
    switch element {
    case .CodeBlock(_, let lang) where matchingLanguage(lang):
        return true
    default:
        return false

    }

}

public func codeBlock(element: Block, _ includeLanguage: String? -> Bool) -> String? {
    switch element {
    case .CodeBlock(let code, let lang) where includeLanguage(lang):
        return code
    default:
        return nil
        
    }
}

public func toArray<A>(optional: A?) -> [A] {
    if let x = optional {
        return [x]
    } else {
        return []
    }
}

public func extractSwift(child: Block) -> [String] {
    return toArray(codeBlock(child, { $0 == "swift"  }))
}

public func printableSwiftBlocks(child: Block) -> [String] {
    return toArray(codeBlock(child, { $0 == "print-swift" } ))
}

extension String {
    var trimmed: String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

extension Array {
    var decompose: (Element, [Element])? {
        guard let x = self.first else { return nil }
        return (x, Array(self[self.startIndex.successor()..<self.endIndex]))
    }
}

public func isEmbedPrintSwift(block: Block) -> (String,String)? {
    return codeBlock(block, { $0 == "embed-print-swift"}).flatMap { str in
        let lines = str.componentsSeparatedByString("\n")
        guard let (firstLine, rest) = lines.decompose else { return nil }
        let firstLineComps = firstLine.componentsSeparatedByString(":")
        guard firstLineComps.count == 2 else { return nil }
        return (firstLineComps[1].trimmed, rest.joinWithSeparator("\n"))
    }
}

extension String {
    func filterLines(include: String -> Bool) -> String {
        return lines.filter(include).joinWithSeparator("\n")
    }

    var withoutResult: String {
        return filterLines { !isResultLine($0) }
    }
}

func resultBlocks(printableCode: String, prelude: String, expression: String, merge: Bool) -> [Block] {
    let part1 = printableCode.withoutResult
    let part2 = evaluateSwift(prelude, expression: expression)
    return merge ? [
        Block.CodeBlock(text: part1 + "\n" + part2, language: "swift")
    ] : [
        Block.CodeBlock(text: part1, language: "swift"),
        Block.CodeBlock(text: part2, language: "")
    ]
}

public func evaluateAndReplacePrintSwift(document: [Block], workingDirectory: NSURL, mergeCodeBlocks: Bool = false) -> [Block] {
    let isPrintSwift = { codeBlock($0, { $0 == "print-swift" }) }
    let swiftCode = deepCollect(document, extractSwift).joinWithSeparator("\n").stringByReplacingOccurrencesOfString("print(", withString: "noop_print(")
    let prelude = [
        "func noop_print<T, TargetStream : OutputStreamType>(value: T, inout _ target: TargetStream, appendNewline: Bool) { }",
        "func noop_print<T, TargetStream : OutputStreamType>(value: T, inout _ target: TargetStream) { }",
        "func noop_print<T>(value: T, appendNewline: Bool) { }",
        "func noop_print<T>(value: T) { }",
        ""
        ].joinWithSeparator("\n")
    let eval: Block -> [Block] = {
        if let code = isPrintSwift($0) {
            return resultBlocks(code, prelude: prelude+swiftCode, expression: code, merge: mergeCodeBlocks)
        } else if let (filename, code) = isEmbedPrintSwift($0) {
            let url = workingDirectory.URLByAppendingPathComponent(filename)
            let fileCode = try! String(contentsOfURL: url)
            return resultBlocks(code, prelude: fileCode, expression: code, merge: mergeCodeBlocks)
        } else {
            return [$0]
        }
    }
    let hasPrintSwiftStatements = deepFilter({ (block: Block) in
        isPrintSwift(block) != nil || isEmbedPrintSwift(block) != nil
    })(elements: document).count > 0
    guard hasPrintSwiftStatements else {
        evaluateSwift(prelude + swiftCode, expression: "()")
        return document
    }
    return deepApply(document, eval)
}

extension String {
    var lines: [String] {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }

    var words: [String] {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    func writeToFile(destination: String) {
        do {
            try writeToFile(destination, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
    }
}

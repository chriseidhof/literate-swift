//
//  Evaluation.swift
//  LiterateSwiftFramework
//
//  Created by Chris Eidhof on 25/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation

private func exec(commandPath commandPath: String, workingDirectory: String, arguments: [String]) -> (output: String, stderr: String) {
    let task = NSTask()
    task.currentDirectoryPath = workingDirectory
    task.launchPath = commandPath
    task.arguments = arguments
    task.environment = ["PATH": "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"]

    let stdout = NSPipe()
    task.standardOutput = stdout
    let stderr = NSPipe()
    task.standardError = stderr

    task.launch()

    func read(pipe: NSPipe) -> String {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return NSString(data: data, encoding: NSUTF8StringEncoding)! as String
    }
    let stdoutoutput : String = read(stdout)
    let stderroutput : String = read(stderr)

    task.waitUntilExit()

    return (output: stdoutoutput, stderr: stderroutput)
}

private func ignoreOutputAndPrintStdErr(input: (output: String,stderr: String)) -> () {
    printstderr(input.stderr)
}

private func printstderr(s: String) {
    NSFileHandle.fileHandleWithStandardError().writeData(s.dataUsingEncoding(NSUTF8StringEncoding)!)
}

func isResultLine(x: String) -> Bool {
    return x.hasPrefix("let result___ ")
}

func evaluateSwift(code: String, expression: String) -> String {
    let hasPrintlnStatements = !(expression.rangeOfString("print", options: NSStringCompareOptions(), range: nil, locale: nil) == nil)
    var expressionLines: [String] = expression.lines.filter { $0.characters.count > 0 }
    let contents: String
    if !hasPrintlnStatements {
        if expressionLines.count == 0 {
            contents = [code, "", "ERROR"].joinWithSeparator("\n")
        } else {
            let lastLine = expressionLines.removeLast()
            let shouldIncludeLet = expressionLines.filter(isResultLine).count == 0
            let resultIs = shouldIncludeLet ? "let result___ : Any = " : ""
            contents = [code, "", expressionLines.joinWithSeparator("\n"), "", "\(resultIs) \(lastLine)", "print(\"\\(result___)\")"].joinWithSeparator("\n")
        }
    } else {
        contents = [code, "", expressionLines.joinWithSeparator("\n")].joinWithSeparator("\n")
    }

    let base = NSUUID().UUIDString as NSString
    let basename = base.stringByAppendingPathExtension("swift")
    let filename = ("/tmp" as NSString).stringByAppendingPathComponent(basename!)

    contents.writeToFile(filename)
    let arguments: [String] =  "--sdk macosx swiftc".words
    let objectName = base.stringByAppendingPathExtension("o")!
    ignoreOutputAndPrintStdErr(exec(commandPath:"/usr/bin/xcrun", workingDirectory:"/tmp", arguments:arguments + ["-c", filename]))
    ignoreOutputAndPrintStdErr(exec(commandPath: "/usr/bin/xcrun", workingDirectory: "/tmp", arguments: arguments + ["-o", "app", objectName]))
    let workingDirectory = NSFileManager.defaultManager().currentDirectoryPath
    let (stdout, stderr) = exec(commandPath: "/tmp/app", workingDirectory: workingDirectory, arguments: [workingDirectory])
    printstderr(stderr)
    return stdout
}
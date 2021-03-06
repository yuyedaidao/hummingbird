import Foundation
import CommandLineKit
import Rainbow
import hummingbirdKit
import PathKit

let cli = CommandLineKit.CommandLine()

let projectOption = StringOption(shortFlag: "p", longFlag: "project", required: true, helpMessage: "Path to the project.")
let excludePathsOption = MultiStringOption(shortFlag: "e", longFlag: "exclude", helpMessage: "Excluded paths which should not search.")
let resourceExtensionsOption = MultiStringOption(shortFlag: "r", longFlag: "resource-extensions", helpMessage: "Extensions to search.")
let fileExtensionsOption = MultiStringOption(shortFlag: "f", longFlag: "file-extensions", helpMessage: "File extensions to search.")
let help = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints a help message.")


cli.addOptions(projectOption, resourceExtensionsOption, fileExtensionsOption, excludePathsOption, help)

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .error:
        str = s.red.bold
    case .optionFlag:
        str = s.green.underline
    case .optionHelp:
        str = s.lightBlue
    default:
        str = s
    }
    
    return cli.defaultFormat(s: str, type: type)
}
do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if help.value {
    cli.printUsage()
    exit(EX_USAGE)
}

let project = projectOption.value ?? "."
let resourceExtensions = resourceExtensionsOption.value ?? ["png", "jpg", "imageset"]
let fileExtensions = fileExtensionsOption.value ?? ["swift", "mm", "m", "xib", "storyboard"]
let excludedPaths = excludePathsOption.value ?? []

let hummingbird = Hummingbird(projectPath: project, excludedPaths: excludedPaths, resourceExtensions: resourceExtensions, fileExtensions: fileExtensions)
let unusedFiles: [FileInof]

do {
    print("working...".bold)
    unusedFiles = try hummingbird.unusedResources()
} catch {
    guard let e = error as? HummingbirdError else {
        exit(EX_USAGE)
    }
    
    switch e {
    case .noResourceExtension: break
    case .noFileExtension:break
    }
    
    exit(EX_USAGE)
}

if unusedFiles.isEmpty {
    print("No unused files!")
    exit(EX_OK)
}

print("I found \(unusedFiles.count) files".green)
var size: Int = 0
for (index, file) in unusedFiles.enumerated() {
    print("[\(index)] unused file: \(file.path.string) [\(file.size)]")
    size += file.size
}
let total = Double(size) / 1024 / 1024
print("Delete \(unusedFiles.count) files(\(String(format: "%.2f", total))M)?  yes(Y|y) or no(N|n)")
if let input = readLine(), input.lowercased() == "y" {
    let fails = Hummingbird.delete(unusedFiles)
    if !fails.isEmpty {
        print("Some file deletion failed: \(fails)")
    }
}



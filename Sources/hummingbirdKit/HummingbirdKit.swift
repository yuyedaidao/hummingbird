import  Foundation
import PathKit
import Rainbow

enum FileType {
    case swift, obj, xib
    init?(ext: String) {
        switch ext {
        case "swift": self = .swift
        case "m","mm": self = .obj
        case "xib", "storyboard": self = .xib
        default: return nil
        }
    }
    
    func searcher(extensions: [String]) -> StringsSearcher {
        switch self {
        case .swift:return SwiftSearcher(extensions: extensions)
        case .obj: return ObjSearcher(extensions: extensions)
        case .xib: return XibSearcher(extensions: extensions)
        }
    }
}

public struct FileInof {
    public let path: Path
    public let size: Int
    init(path: String) {
        self.path = Path(path)
        self.size = self.path.size
    }
}

extension Path {
    var size: Int {
        if isDirectory {
            let childrenPaths = try? children()
            return (childrenPaths ?? []).reduce(0) {$0 + $1.size}
        } else {
            if lastComponent.hasSuffix(".") {return 0}
            let attr = try? FileManager.default.attributesOfItem(atPath: absolute().string)
            
            if let num = attr?[.size] as? NSNumber {
                return num.intValue
            } else {
                return 0
            }
        }
    }
}

public enum HummingbirdError: Error {
    case noResourceExtension
    case noFileExtension
}

public struct Hummingbird {
    let projectPath: Path
    let excludedPaths: [Path]
    let resourceExtensions: [String]
    let fileExtensions: [String]

    public init(projectPath: String, excludedPaths: [String], resourceExtensions: [String], fileExtensions: [String]){
        let path = Path(projectPath).absolute()
        self.projectPath = path
        self.excludedPaths = excludedPaths.map{ path + $0 }
        for path in self.excludedPaths {
            if  !path.exists {
                print("path: \"\(path.string)\" is not existed".magenta)
            }
        }
        self.resourceExtensions = resourceExtensions
        self.fileExtensions = fileExtensions;
    }
    
    public func unusedResources() throws -> [FileInof] {
        guard !resourceExtensions.isEmpty else {
            throw HummingbirdError.noResourceExtension
        }
        guard !fileExtensions.isEmpty else {
            throw HummingbirdError.noFileExtension
        }
        let resources =  allResources()
        let allStrings = allStringInUse()
        
        return Hummingbird.filterUnused(from: resources, used: allStrings).map{ FileInof(path: $0) }
    }
    
    public func allStringInUse() -> Set<String> {
        return stringInUse(at: projectPath)
    }
    
    func stringInUse(at path: Path) -> Set<String> {
        func strings(`in` filePath: Path ) ->Set<String>? {
            let fileExt = filePath.extension ?? ""
            guard fileExtensions.contains(fileExt) else {
                return nil
            }
            let searcher: StringsSearcher
            if let fileType = FileType(ext: fileExt) {
                searcher = fileType.searcher(extensions: resourceExtensions)
            } else {
                searcher = GeneralSearcher(extensions: resourceExtensions)
            }
            let content = (try? filePath.read()) ?? ""
            return searcher.search(in: content)
        }
        if path.isFile {
            return strings(in: path) ?? []
        } else {
            guard let subPaths = try? path.children() else {
                print("Path reading error: \(path)".red)
                return []
            }
            var result = [String]()
            for subPath in subPaths {
                if subPath.lastComponent.hasPrefix(".") {
                    continue
                }
                if excludedPaths.contains(subPath) {
                    continue
                }
                if subPath.isDirectory {
                    result.append(contentsOf: stringInUse(at: subPath))
                } else {
                    guard let strings = strings(in: subPath) else {
                        continue
                    }
                    result.append(contentsOf: strings)
                }
            }
            return Set(result)

        }
        
    }
    
    public func allResources() -> [String : String] {
        guard let process = FindProcess(path: projectPath, extensions: resourceExtensions, exclued: excludedPaths) else {
            return [:]
        }

        let found = process.execute()
        var files = [String : String]()
        let regularDirExtensions = ["imageset", "launchimage", "bundle"]
        let nonDirExtensions = resourceExtensions.filter {
            !regularDirExtensions.contains($0)
        }
        let dirPath = regularDirExtensions.map{ ".\($0)/" }
        fileLoop: for file in found {//去掉了 "imageset/" 也就是保留了imageset
            for dir in dirPath where file.contains(dir) {
                continue fileLoop
            }
            let filePath = Path(file)
            //去除image.png这种形式的文件夹
            if let ext = filePath.extension, filePath.isDirectory && nonDirExtensions.contains(ext) {
                continue
            }
            let key = file.plainName(extensions: resourceExtensions)
            if let _ = files[key] {
                print("Found a duplicated file key: \(key)".yellow.bold)
                continue
            }
            files[key] = file
        }
        return files
    }
    
    static func filterUnused(from all: [String : String], used: Set<String>)  -> Set<String> {
        let unusedPairs = all.filter { (key, _) -> Bool in
            return !used.contains(key) && !used.contains { $0.similarPatternWithNumberIndex(other: key)
            }
        }
        return Set(unusedPairs.map{ $0.value})
    }
    
    static public func delete(_ unusedFiles: [FileInof]) -> [(FileInof, Error)] {
        var failed = [(FileInof, Error)]()
        for file in unusedFiles {
            do {
                try file.path.delete()
            } catch {
                failed.append((file, error))
            }
        }
        return failed
    }
    
}

let digitalRegex = try! NSRegularExpression(pattern: "(\\d+)", options: .caseInsensitive)



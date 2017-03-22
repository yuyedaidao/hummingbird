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
    let path: String
}

public struct Hummingbird {
    let projectPath: Path
    let excludedPaths: [Path]
    let resourceExtensions: [String]
    let fileExtensions: [String]

    public init(projectPath: String, excludedPaths: [String], resourceExtensions: [String], fileExtensions: [String]){
        let path = Path(projectPath).absolute()
        self.projectPath = path
        self.excludedPaths = excludedPaths.map{ path + Path($0).absolute()}
        self.resourceExtensions = resourceExtensions
        self.fileExtensions = fileExtensions;
    }
    
    public func unusedResource() -> [String] {
        fatalError()
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
    
    func resourcesInUse() -> [String : String] {
        guard let process = FindProcess(path: projectPath, extensions: resourceExtensions, exclued: excludedPaths) else {
            return [:]
        }
        let found = process.execute()
        var fileds = [String : String]()
        let regularDirExtensions = ["imageset", "launchimage", "bundle"]
        for file in found {
            let dirPath = regularDirExtensions.map{ ".\($0)/" }
            for dir in dirPath where file.contains(dir) {
            
            }
            
        }
        return fileds
    }
    
    public func delete() -> Void {
        
    }
    
}

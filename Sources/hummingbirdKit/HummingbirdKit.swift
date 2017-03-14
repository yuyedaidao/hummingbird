import  Foundation
import PathKit
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
    
    func stringInUse() -> [String] {
        
        fatalError()
    }
    
    func resourcesInUse() -> [String : String] {
        fatalError()
    }
    
    public func delete() -> Void {
        
    }
    
}

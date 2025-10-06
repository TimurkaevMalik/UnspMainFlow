// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [
            SPMDependency.coreKit.name: .framework,
            SPMDependency.networkKit.name: .framework
        ]
    )
#endif


let package = Package(
    name: "UnspMainFlow",
    dependencies: [
        .make(from: SPMDependency.coreKit),
        .make(from: SPMDependency.networkKit)
    ]
)

/// MARK: - Dependencies
fileprivate enum SPMDependency {
    static let coreKit = PackageModel(
        name: "CoreKit",
        url: "https://github.com/TimurkaevMalik/CoreKit.git",
        requirement: .version(.init(2, 0, 0))
    )
    
    static let networkKit = PackageModel(
        name: "NetworkKit",
        url: "https://github.com/TimurkaevMalik/NetworkKit.git",
        requirement: .branch("main")
    )
}

fileprivate struct PackageModel: Sendable {
    let name: String
    let url: String
    let requirement: Requirement
    
    init(name: String, url: String, requirement: Requirement) {
        self.name = name
        self.url = url
        self.requirement = requirement
    }
    
    public enum Requirement: Sendable{
        case version(Version)
        case branch(String)
        
        var string: String {
            switch self {
                
            case .version(let version):
                return version.stringValue
                
            case .branch(let string):
                return string
            }
        }
    }
}

fileprivate extension Version {
    var stringValue: String {
        let major = "\(major)"
        let minor = "\(minor)"
        let patch = "\(patch)"
        
        return major + "." + minor + "." + patch
    }
    
    init(string: String) {
        self.init(stringLiteral: string)
    }
}

fileprivate extension Package.Dependency {
    static func make(from package: PackageModel) -> Package.Dependency {
        let url = package.url
        let requirement = package.requirement.string
        
        switch package.requirement {
            
        case .version:
                return .package(url: url, from: .init(string: requirement))
        case .branch:
                return .package(url: url, branch: requirement)
        }
    }
}

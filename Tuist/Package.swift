// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [
            SPMDependency.snapKit.name: .framework,
            SPMDependency.coreKit.name: .framework,
            SPMDependency.networkKit.name: .framework,
            SPMDependency.loggingKit.name: .framework,
            SPMDependency.helpersSharedUnsp.name: .framework,
            SPMDependency.keychainStorageKit.name: .framework
        ]
    )
#endif


let package = Package(
    name: "UnspMainFlow",
    dependencies: [
        .make(from: SPMDependency.snapKit),
        .make(from: SPMDependency.coreKit),
        .make(from: SPMDependency.networkKit),
        .make(from: SPMDependency.loggingKit),
        .make(from: SPMDependency.helpersSharedUnsp),
        .make(from: SPMDependency.keychainStorageKit)
    ]
)

/// MARK: - Dependencies
fileprivate enum SPMDependency {
    static let snapKit = PackageModel(
        name: "SnapKit",
        url: "https://github.com/SnapKit/SnapKit.git",
        requirement: .version(.init(5, 7, 0))
    )

    // MARK: - My own libraries
    static let loggingKit = PackageModel(
        name: "LoggingKit",
        url: "https://github.com/TimurkaevMalik/LoggingKit.git",
        requirement: .version(.init(1, 1, 1))
    )

    static let keychainStorageKit = PackageModel(
        name: "KeychainStorageKit",
        url: "https://github.com/TimurkaevMalik/KeychainStorageKit.git",
        requirement: .version(.init(1, 1, 3))
    )
    
    static let coreKit = PackageModel(
        name: "CoreKit",
        url: "https://github.com/TimurkaevMalik/CoreKit.git",
        requirement: .version(.init(2, 3, 2))
    )
    
    static let networkKit = PackageModel(
        name: "NetworkKit",
        url: "https://github.com/TimurkaevMalik/NetworkKit.git",
        requirement: .version(.init(1, 3, 0))
    )
        
    static let helpersSharedUnsp = PackageModel(
        name: "HelpersSharedUnsp",
        url: "https://github.com/TimurkaevMalik/HelpersSharedUnsp.git",
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

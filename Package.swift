// swift-tools-version:6.1

import PackageDescription

let projName = "UnspMainFlow"
let projNameDynamic = projName + "-Dynamic"

let package = Package(
    name: projName,
    platforms: [.iOS(.v15)],
    products: [
        .library(name: projName, targets: [projName]),
        .library(name: projNameDynamic, type: .dynamic, targets: [projName]),
    ],
    dependencies: [
//        .make(from: SPMDependency.snapKitWrapper),
//        .make(from: SPMDependency.coreKit),
//        .make(from: SPMDependency.networkKit),
//        .make(from: SPMDependency.loggingKit),
//        .make(from: SPMDependency.keychainStorageKit),
//        .make(from: SPMDependency.helpersSharedUnsp)
    ],
    targets: [
        .target(
            name: projName,
            dependencies: [
//                .product(SPMDependency.snapKitWrapper.name),
//                .product(SPMDependency.coreKit.name),
//                .product(SPMDependency.networkKit.name),
//                .product(SPMDependency.loggingKit.name),
//                .product(SPMDependency.keychainStorageKit.name),
//                .product(SPMDependency.helpersSharedUnsp.name)
            ],
            path: projName,
            sources: ["Sources"]
        )
    ]
)

/// MARK: - Dependencies
fileprivate enum SPMDependency {
    static let snapKitWrapper = PackageModel(
        name: "SnapKitWrapper",
        url: "https://github.com/TimurkaevMalik/SnapKitWrapper.git",
        requirement: .version(.init(5, 8, 0))
    )

    static let loggingKit = PackageModel(
        name: "LoggingKit",
        url: "https://github.com/TimurkaevMalik/LoggingKit.git",
        requirement: .version(.init(1, 2, 0))
    )
    
    static let keychainStorageKit = PackageModel(
        name: "KeychainStorageKit",
        url: "https://github.com/TimurkaevMalik/KeychainStorageKit.git",
        requirement: .version(.init(1, 3, 0))
    )
    
    static let coreKit = PackageModel(
        name: "CoreKit",
        url: "https://github.com/TimurkaevMalik/CoreKit.git",
        requirement: .version(.init(2, 14, 0))
    )
    
    static let networkKit = PackageModel(
        name: "NetworkKit",
        url: "https://github.com/TimurkaevMalik/NetworkKit.git",
        requirement: .version(.init(1, 3, 0))
    )
    
    static let helpersSharedUnsp = PackageModel(
        name: "HelpersSharedUnsp",
        url: "https://github.com/TimurkaevMalik/HelpersSharedUnsp.git",
        requirement: .version(.init(1, 1, 0))
    )
}

/// MARK: - PackageModel
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

/// MARK: - Version
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

/// MARK: - Package.Dependency
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

/// MARK: - Target.Dependency
fileprivate extension Target.Dependency {
    static func product(_ name: String) -> Self {
        .product(name: name, package: name)
    }
}

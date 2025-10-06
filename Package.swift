// swift-tools-version:6.2

import PackageDescription

let featureName = "UnspMainFlow"

let package = Package(
    name: featureName,
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: featureName,
            type: .dynamic,
            targets: [featureName]
        ),
    ],
    dependencies: [
        .make(from: SPMDependency.coreKit)
    ],
    targets: [
        .target(
            name: featureName,
            dependencies: [/*.product(SPMDependency.coreKit.name)*/],
            path: featureName,
            sources: ["Sources"]
        )
    ]
)

/// MARK: - Dependencies
fileprivate enum SPMDependency {
    static let coreKit = PackageModel(
        name: "CoreKit",
        url: "https://github.com/TimurkaevMalik/CoreKit.git",
        requirement: .version(.init(2, 0, 0))
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

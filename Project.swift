import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: ProjectConstants.appName,
    settings: .settings(base: BuildFlags.base),
    targets: [ Targets.appTarget ]
)

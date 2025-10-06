//
//  DefaultSceneManifest.swift
//  Manifests
//
//  Created by Malik Timurkaev on 23.09.2025.
//

import ProjectDescription

public let defaultSceneManifest: [String: Plist.Value] = [
    appSupportsMultipleScenes: .boolean(false),
    sceneConfigurations: .dictionary([
        windowSceneSessionRoleApplication: .array([
            .dictionary([
                sceneConfigurationName: .string("Default Configuration"),
                sceneDelegateClassName: .string("$(PRODUCT_MODULE_NAME).SceneDelegate")
            ])
        ])
    ])
]

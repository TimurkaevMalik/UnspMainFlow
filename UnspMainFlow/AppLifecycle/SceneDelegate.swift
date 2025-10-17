//
//  SceneDelegate.swift
//  FeatureTemplate
//
//  Created by Malik Timurkaev on 26.09.2025.
//

import UIKit
import CoreKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var featureCoordinator: Coordinator?
        
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigation = UINavigationController()
        
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
        
        featureCoordinator = RootUnspMainFlowCoordinator(navigation: navigation)
        featureCoordinator?.start()
    }
}

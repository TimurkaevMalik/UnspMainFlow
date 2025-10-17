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
        
        let navigation = makeNavigationController()
        let coordinator = RootUnspMainFlowCoordinator(navigation: navigation)
        featureCoordinator = coordinator
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigation
        coordinator.start()
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func makeNavigationController() -> UINavigationController {
       let appearance = UINavigationBarAppearance()
       appearance.configureWithOpaqueBackground()
       appearance.backgroundColor = Palette.Asset.whitePrimary.uiColor
       appearance.titleTextAttributes = [
           .foregroundColor: Palette.Asset.blackPrimary.uiColor
       ]
       
       let navController = UINavigationController()
       navController.navigationBar.standardAppearance = appearance
       navController.navigationBar.scrollEdgeAppearance = appearance
       
       return navController
   }
}

//
//  SceneDelegate.swift
//  FeatureTemplate
//
//  Created by Malik Timurkaev on 26.09.2025.
//


import UIKit
#warning("Remove KeychainStorageKit, Corekit")
import KeychainStorageKit
import CoreKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    #warning("Remove valet")
    static let valet = ValetStorage(
        id: "n",
        accessibility: .whenUnlockedThisDeviceOnly,
        logger: nil
    )!
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let helper = DefaultNetworkServiceHelper()
        let requestFactory = AuthorizedRequestFactory()
        let tokenStorage = TokenCache(keychain: SceneDelegate.valet)
        
        let usalRepo = PhotoDataRepository(
            photoDataService: PhotosDataService(
                requestFactory: requestFactory,
                helper: helper),
            tokenStorage: tokenStorage)
        
        let likedRepo = UserLikedPhotosRepository(
            photoDataService: UserLikedPhotosService(
                requestFactory: requestFactory,
                helper: helper),
            tokenStorage: tokenStorage)
        
        let vm = PhotosViewModel(
            photoDataRepo: likedRepo,
            imagesRepo: ImagesRepository(imageService: ImageService()))
        
        let photoFeedCollection = ImageCollectionController(
            vm: vm,
            layoutFactory: TripleSectionLayoutFactory()
        )
        
        let feedController = PhotoFeedController(
            photoFeedCollectionController: photoFeedCollection
        )
                
        let navigation = makeNavigationController(root: feedController)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }
    
    private func makeNavigationController(root: UIViewController) -> UINavigationController {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Palette.Asset.whitePrimary.uiColor
        appearance.titleTextAttributes = [
            .foregroundColor: Palette.Asset.blackPrimary.uiColor
        ]
        
        let navController = UINavigationController(rootViewController: root)
        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        
        return navController
    }
}

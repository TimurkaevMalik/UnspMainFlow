//
//  SceneDelegate.swift
//  FeatureTemplate
//
//  Created by Malik Timurkaev on 26.09.2025.
//


import UIKit
#warning("Remove KeychainStorageKit")
import KeychainStorageKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let vm = PhotosViewModel(
            photoDataRepo: PhotoDataRepository(photoDataService: PhotosDataService()),
            imagesRepo: ImagesRepository(imageService: ImageService()),
            keychainStorage: ValetStorage(id: "n", accessibility: .whenUnlockedThisDeviceOnly, logger: nil)!)
        
        let photoFeedCollection = ImageCollectionController(
            vm: vm,
            layoutFactory: TripleSectionLayoutFactory()
        )
        window?.rootViewController = PhotoFeedViewController(
            vm: vm,
            photoFeedCollectionController: photoFeedCollection
        )
        window?.makeKeyAndVisible()
    }
}

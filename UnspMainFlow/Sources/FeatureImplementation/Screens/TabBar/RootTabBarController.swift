//
//  RootTabBarController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import CoreKit

final class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
    }
}

private extension RootTabBarController {
    func setupAppearance() {
        tabBar.tintColor = Palette.Asset.blackPrimary.uiColor
        tabBar.backgroundColor = Palette.Asset.whitePrimary.uiColor
    }
    
    func setupTabs() {}
}

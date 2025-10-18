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
        setupUI()
    }
}

private extension RootTabBarController {
    func setupUI() {
        title = "TabBar"
        tabBar.tintColor = Palette.Asset.blackPrimary.uiColor
        tabBar.backgroundColor = Palette.Asset.whitePrimary.uiColor
    }
}

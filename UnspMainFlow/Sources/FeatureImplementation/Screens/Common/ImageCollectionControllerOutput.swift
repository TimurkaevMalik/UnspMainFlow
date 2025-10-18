//
//  ImageCollectionControllerOutput.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 18.10.2025.
//

import UIKit

@MainActor
protocol ImageCollectionControllerOutput: AnyObject {
    func didSelect(image: UIImage, data: PhotoItem)
}

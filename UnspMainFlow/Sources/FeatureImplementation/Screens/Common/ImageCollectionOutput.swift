//
//  ImageCollectionOutput.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 18.10.2025.
//

import UIKit

@MainActor
protocol ImageCollectionOutput: AnyObject {
    func didSelect(image: UIImage, data: PhotoItem)
}

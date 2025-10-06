//
//  ViewController.swift
//  AppModule
//
//  Created by Malik Timurkaev on 04.10.2025.
//

import UIKit

final class ViewController: UIViewController {
    let s = FetchPhotosService()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        
        Task {
            do {
                let data = try await s.fetchPhotos(page: 1, token: token)
                print(data)
            } catch {
                print(error)
            }
        }
    }
}

//
//  ViewController.swift
//  AppModule
//
//  Created by Malik Timurkaev on 04.10.2025.
//

import UIKit
import Combine
#warning("Remove KeychainStorageKit")
import KeychainStorageKit

final class ViewController: UIViewController {
    
    private let imageView = UIImageView()
    
    private let vm = PhotosFeedViewModel(
        photoDataRepo: PhotoDataRepository(photoDataService: PhotosDataService()),
        imagesRepo: ImagesRepository(imageService: ImageService()),
        keychainStorage: ValetStorage(id: "n", accessibility: .whenUnlockedThisDeviceOnly, logger: nil)!)
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        
        imageView.frame = CGRect(x: 100, y: 50, width: 300, height: 400)
        imageView.backgroundColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        bindVM()
        vm.fetchPhotosData()
    }
}

private extension ViewController {
    func bindVM() {
        vm.photoDataServiceState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                    
                case .loading:
                    print("Loading")
                case .loaded(let items):
                    print(items)
                    items.indices.forEach({ index in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.vm.fetchImage(by: IndexPath(row: index, section: 0))
                        }
                    })
                case .failed(let error):
                    print("state", error)
                }
            }
            .store(in: &cancellables)
        
        vm.imageSubject
            .receive(on: DispatchQueue.main)
            .map({ $0.image })
            .assign(to: \.image, on: imageView)
            .store(in: &cancellables)
    }
}

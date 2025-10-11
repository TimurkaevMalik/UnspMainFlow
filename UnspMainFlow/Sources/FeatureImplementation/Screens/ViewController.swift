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
    
    private let vm = PhotosFeedViewModel(
        photoDataRepo: PhotoDataRepository(photoDataService: PhotosDataService()),
        keychainStorage: ValetStorage(id: "n", accessibility: .whenUnlockedThisDeviceOnly, logger: nil)!)
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        vm.fetchPhotosData()
        
        vm.photoDataServiceState
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { state in
                switch state {
                    
                case .loading:
                    print("Loading")
                case .loaded(let items):
                    print(items)
                case .failed(let error):
                    print("state", error)
                }
            }
            .store(in: &cancellables)
    }
}

//
//  ImageCollectionController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit
import CoreKit
import Combine

final class ImageCollectionController: UICollectionViewController {
    
    private let vm: PhotosViewModel
    private var snapshot = Snapshot()
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = makeDataSource()
    
    init(
        vm: PhotosViewModel,
        layoutFactory: CollectionCompositionalLayoutFactory
    ) {
        self.vm = vm
        super.init(collectionViewLayout: layoutFactory.make())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollection()
        bindViewModel()
        vm.fetchPhotosData()
    }
}

#warning("Не лишний ли receive(on:)?")
private extension ImageCollectionController {
    func bindViewModel() {
        vm.photoDataServiceState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                
                guard let self else { return }
                
                switch state {
                    
                case .loading:
                    print("Loading")
                    
                case .loaded(let photosData):
                    handleLoaded(data: photosData)
    
                case .failed(let error):
                    print(error)
                }
            }
            .store(in: &cancellables)
        
        vm.imageSubject
            .receive(on: DispatchQueue.main)
            .sink { items in
                self.updateSnapshot(items: items)
            }
            .store(in: &cancellables)
    }
    
    func handleLoaded(data: [PhotoItem]) {
        let items = data.map({
            let id = UUID()
            
            self.vm.fetchImageFromPhotoData(forID: id, index: $0.index)
            return ImageItem(id: id, index: $0.index)
        })
        
        self.apply(items: items)
    }
    
    func updateSnapshot(items: [ImageItem]) {
//        var newSnapshot = Snapshot()
//        newSnapshot.appendSections([.main])
//        newSnapshot.appendItems(items, toSection: .main)
//        
//        snapshot.reconfigureItems(items)
//        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func apply(items: [ImageItem]) {
//        print("applied items")
//        snapshot.appendSections([.main])
//        snapshot.appendItems(items, toSection: .main)
//        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

//MARK: - Configuration
private extension ImageCollectionController {
    func configureCollection() {
        collectionView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        collectionView.dataSource = dataSource
        collectionView.register(Cell.self, identifier: Cell.identifier)
    }

    func makeDataSource() -> DataSource {
        UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: makeCellRegistration().cellProvider
        )
    }
    
    func makeCellRegistration() -> CellRegistration {
        CellRegistration { cell, indexPath, item in
            if let image = item.image {
                print("did set")
                cell.set(image: image)
            }
        }
    }
}

private extension ImageCollectionController {
    typealias Cell = ImageCollectionCell
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem>
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, ImageItem>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageItem>
    
    enum Section: Int {
        case main
    }
}

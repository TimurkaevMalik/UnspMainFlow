//
//  ImageCollectionController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit
import CoreKit
import Combine

// MARK: - Lifecycle
final class ImageCollectionController: UICollectionViewController {
    
    private let vm: PhotosViewModel
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
        configureSnapshot()
        configureCollection()
        bindViewModel()
        vm.fetchPhotosData()
    }
}

// MARK: - UICollectionViewDelegate
extension ImageCollectionController {
#warning("Перенести в Coordinator")
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let image = vm.imageItem(at: indexPath.row).image else { return }
        let photoItem = vm.photoItem(at: indexPath.row)
        let vc = PhotoInfoController(image: image, info: photoItem)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Bindings
#warning("Не лишний ли receive(on:)?")
private extension ImageCollectionController {
    func bindViewModel() {
        vm.photosState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
#warning("Нужен ли guard?")
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
        
        vm.imagePublisher
            .receive(on: DispatchQueue.main)
            .sink { item in
                self.updateSnapshot(itemID: item.id)
            }
            .store(in: &cancellables)
    }
    
    func handleLoaded(data: [PhotoItem]) {
        let tuple = data.reduce(into: (ids: [String](), indexes: [Int]())) { partialResult, item in
            
            partialResult.ids.append(item.id)
            partialResult.indexes.append(item.index)
        }
        
        apply(itemsIDs: tuple.ids)
        vm.fetchImages(for: tuple.indexes)
    }
    
    func updateSnapshot(itemID: String) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([itemID])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func apply(itemsIDs: [String]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(itemsIDs, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

//MARK: - Configuration
private extension ImageCollectionController {
    func configureCollection() {
        collectionView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        collectionView.dataSource = dataSource
        collectionView.register(Cell.self, identifier: Cell.identifier)
    }
    
    func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
    }

    func makeDataSource() -> DataSource {
        UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: makeCellRegistration().cellProvider
        )
    }
    
    func makeCellRegistration() -> CellRegistration {
        CellRegistration { cell, indexPath, id in
            if let image = self.vm.imageItem(at: indexPath.row).image {
                cell.set(image: image)
            }
        }
    }
}

// MARK: - Typealiases & Section
private extension ImageCollectionController {
    typealias Cell = ImageCollectionCell
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem.ID>
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, ImageItem.ID>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageItem.ID>
    
    enum Section: Int {
        case main
    }
}

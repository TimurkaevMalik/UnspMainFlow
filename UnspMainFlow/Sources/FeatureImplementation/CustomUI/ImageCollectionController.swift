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
        configureSnapshot()
        configureCollection()
        bindViewModel()
        vm.fetchPhotosData()
    }
}

extension ImageCollectionController {
#warning("Перенести в Coordinator")
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let image = vm.getImage(index: indexPath.row) else { return }
        let photoItem = vm.getPhotoItem(index: indexPath.row)
        let vc = PhotoInfoController(image: image, info: photoItem)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

#warning("Не лишний ли receive(on:)?")
private extension ImageCollectionController {
    func bindViewModel() {
        vm.photoDataServiceState
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
        
        vm.imageSubject
            .receive(on: DispatchQueue.main)
            .sink { item in
                self.updateSnapshot(item: item.id)
            }
            .store(in: &cancellables)
    }
    
    func handleLoaded(data: [PhotoItem]) {
        let tuple = data.reduce(into: (ids: [UUID](), indexes: [Int]())) { partialResult, item in
            
            partialResult.ids.append(item.id)
            partialResult.indexes.append(item.index)
        }
        
        apply(items: tuple.ids)
        vm.fetchImagesFromPhotoData(indexes: tuple.indexes)
    }
    
    func updateSnapshot(item: UUID) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func apply(items: [UUID]) {
        snapshot.appendItems(items, toSection: .main)
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
        snapshot.appendSections([.main])
    }

    func makeDataSource() -> DataSource {
        UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: makeCellRegistration().cellProvider
        )
    }
    
    func makeCellRegistration() -> CellRegistration {
        CellRegistration { cell, indexPath, item in
            if let image = self.vm.getImage(index: indexPath.row) {
                cell.set(image: image)
            }
        }
    }
}

private extension ImageCollectionController {
    typealias Cell = ImageCollectionCell
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem.ID>
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, ImageItem.ID>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageItem.ID>
    
    enum Section: Int {
        case main
    }
}

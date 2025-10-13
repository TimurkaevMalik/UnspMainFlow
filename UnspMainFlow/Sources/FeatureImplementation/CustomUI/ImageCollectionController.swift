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
    private lazy var dataSource = makeDataSource()
    private lazy var snapShot = NSDiffableDataSourceSnapshot<Section, ImageItem>()
    private var cancellables = Set<AnyCancellable>()
    
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
        configureSnapshot()
        applySnapshot(items: [])
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
                    let startIndex = self.collectionView.visibleCells.count
                    self.applyPlaceholderSnapshot(count: photosData.count)
                    self.vm.fetchImages(from: .init(row: startIndex, section: 0), to: .init(row: photosData.count - 1, section: 0))
                case .failed(let error):
                    print(error)
                }
            }
            .store(in: &cancellables)
        
        vm.imageSubject
//            .debounce(for: 1, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { item in
//                if item.index.row > self.collectionView.visibleCells.count {
//                    return
//                }
                let cell = self.collectionView.cellForItem(at: item.index) as? ImageCollectionCell
                print(item)
                print(cell)
                cell?.set(image: item.image)
//                self.applySnapshot(items: [item])
            }
            .store(in: &cancellables)
    }
    
    func applySnapshot(items: [ImageItem]) {
        snapShot.appendItems(items, toSection: .main)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    func applyPlaceholderSnapshot(count: Int) {
        let items = (0..<count).map({ ImageItem(id: UUID(), index: IndexPath(row: $0, section: 0), image: UIImage()) })
        snapShot.appendItems(items, toSection: .main)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
}

//MARK: - Configuration
private extension ImageCollectionController {
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, ImageItem> {
        let registration = makeCellRegistration()
        
        return UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collection, indexPath, item in
                
                collection.dequeueConfiguredReusableCell(
                    using: registration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }
    
    func makeCellRegistration() -> CellRegistration {
        CellRegistration { cell, indexPath, item in
            cell.set(image: item.image)
        }
    }
    
    func configureSnapshot() {
        snapShot.appendSections([.main])
    }
    
    func configureCollection() {
        collectionView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        collectionView.dataSource = dataSource
        collectionView.register(
            ImageCollectionCell.self,
            forCellWithReuseIdentifier: ImageCollectionCell.identifier
        )
    }
}

private extension ImageCollectionController {
    typealias Cell = ImageCollectionCell
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, ImageItem>
    
    enum Section: Int {
        case main
    }
}

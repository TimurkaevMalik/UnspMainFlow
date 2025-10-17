//
//  ImageCollectionController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit
import CoreKit
import Combine

@MainActor
protocol ImageCollectionControllerOutput: AnyObject {
    func didSelect(image: UIImage, data: PhotoItem)
}

// MARK: - Lifecycle
final class ImageCollectionController: UICollectionViewController {
    
    private weak var output: ImageCollectionControllerOutput?
    private let vm: PhotosViewModel
    private var cancellable = Set<AnyCancellable>()
    private lazy var dataSource = makeDataSource()
    private var nextPageTriggerIndex = IndexPath(item: 0, section: 0)
    private let paginationOffset = 5
    
    init(
        output: ImageCollectionControllerOutput? = nil,
        vm: PhotosViewModel,
        layoutFactory: CollectionCompositionalLayoutFactory
    ) {
        self.output = output
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

// MARK: - Bindings
private extension ImageCollectionController {
    func bindViewModel() {
        vm.photosState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .loading:
                    print("Loading")
                    
                case .loaded(let photosData):
                    handleLoaded(photosData: photosData)
                case .failed(let error):
                    print(error)
                }
            }
            .store(in: &cancellable)
        
        vm.imagePublisher
            .collect(.byTime(DispatchQueue.main, .seconds(1)))
            .receive(on: DispatchQueue.main)
            .map({ item in
                item.map({ $0.id })
            })
            .sink { IDs in
                self.updateSnapshot(itemsIDs: IDs)
            }
            .store(in: &cancellable)
    }
    
    func handleLoaded(photosData: [PhotoItem]) {
        apply(itemsIDs: photosData.map({ $0.id }))
        
        nextPageTriggerIndex = IndexPath(
            item: nextPageTriggerIndex.item + photosData.count - paginationOffset,
            section: 0
        )
    }
    
    func updateSnapshot(itemsIDs: [String]) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(itemsIDs)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func apply(itemsIDs: [String]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(itemsIDs, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func loadNextPageIfNeeded(at index: IndexPath) {
        guard index >= nextPageTriggerIndex else { return }
        vm.fetchPhotosData()
    }
}

// MARK: - UICollectionViewDelegate
extension ImageCollectionController {
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let image = vm.imageItem(at: indexPath.item).image else { return }
        let photoItem = vm.photoItem(at: indexPath.item)
        output?.didSelect(image: image, data: photoItem)
    }
}

// MARK: - UICollectionViewDelegate
extension ImageCollectionController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.last else { return }
        loadNextPageIfNeeded(at: indexPath)
    }
}

//MARK: - Configuration
private extension ImageCollectionController {
    func configureCollection() {
        collectionView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = self
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
            if let image = self.vm.imageItem(at: indexPath.item).image {
                cell.set(image: image)
            } else {
                self.vm.fetchImages(for: [indexPath.item])
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

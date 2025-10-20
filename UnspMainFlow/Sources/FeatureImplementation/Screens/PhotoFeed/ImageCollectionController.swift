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
    
    private weak var output: ImageCollectionOutput?
    private let vm: PhotosViewModelProtocol
    private var cancellable = Set<AnyCancellable>()
    private lazy var dataSource = makeDataSource()
    private var nextPageTriggerIndex = 0
    private let paginationOffset = 5
    
    init(
        output: ImageCollectionOutput? = nil,
        vm: PhotosViewModelProtocol,
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
        configureCollection()
        bindViewModel()
        vm.fetchNextPhotosPage()
    }
}

// MARK: - Bindings
private extension ImageCollectionController {
    var refreshDataAction: UIAction {
        .init { [weak self] _ in
            self?.vm.refreshPhotoData()
        }
    }
    
    func bindViewModel() {
        vm.photosState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in

                switch state {
                case .loading:
                    print("Loading")

                case .loaded(let photosData):
                    self?.handleLoaded(photosData: photosData)
                    self?.collectionView.refreshControl?.endRefreshing()
                    
                case .failed(let error):
                    print(error)
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            }
            .store(in: &cancellable)

        vm.imagePublisher
            .collect(.byTime(DispatchQueue.main, .seconds(1)))
            .receive(on: DispatchQueue.main)
            .map({ $0.map(\.id) })
            .sink { [weak self] IDs in
                self?.updateSnapshot(itemsIDs: IDs)
            }
            .store(in: &cancellable)
    }

    func handleLoaded(photosData: [PhotoItem]) {
        let index = photosData.first?.index ?? 0

        if index == 0 {
            applyNew(itemsIDs: photosData.map({ $0.id }))
        } else {
            applyAdditional(itemsIDs: photosData.map({ $0.id }))
        }

        nextPageTriggerIndex = index + paginationOffset
    }

    func updateSnapshot(itemsIDs: [String]) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(itemsIDs)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func applyAdditional(itemsIDs: [String]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(itemsIDs, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func applyNew(itemsIDs: [String]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(itemsIDs, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func loadNextPageIfNeeded(at index: Int) {
        guard index >= nextPageTriggerIndex else { return }
        vm.fetchNextPhotosPage()
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
        loadNextPageIfNeeded(at: indexPath.item)
    }
}

//MARK: - Configuration
private extension ImageCollectionController {
    func configureCollection() {
        collectionView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = self
        collectionView.register(Cell.self, identifier: Cell.identifier)
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(
            refreshDataAction,
            for: .valueChanged
        )
    }
        
    func makeDataSource() -> DataSource {
        UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: makeCellRegistration().cellProvider
        )
    }
    
    func makeCellRegistration() -> CellRegistration {
        CellRegistration { [weak self] cell, indexPath, id in
            guard let self else { return }
            
            if let image = self.vm.imageItem(at: indexPath.item).image {
                cell.set(image: image)
            } else {
                self.vm.fetchImages(for: [indexPath.item])
            }
        }
    }
}

// MARK: - Typealias & Section
extension ImageCollectionController: DiffableCollectionControllerProtocol {
    typealias Section = CustomSection
    typealias Cell = ImageCollectionCell
    typealias ItemIdentifier = ImageItem.ID
        
    enum CustomSection: Int {
        case main
    }
}

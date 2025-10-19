//
//  Untitled.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 19.10.2025.
//

import UIKit
import CoreKit
import Combine

// MARK: - Lifecycle
final class PhotoSearchFeedView: UIView {
    
    private let collectionView: UICollectionView
    
    private weak var output: ImageCollectionControllerOutput?
    private let vm: PhotosViewModelProtocol
    private var cancellable = Set<AnyCancellable>()
    private lazy var dataSource = makeDataSource()
    private var nextPageTriggerIndex = IndexPath(item: 0, section: 0)
    private let paginationOffset = 5
    
    init(
        output: ImageCollectionControllerOutput? = nil,
        vm: PhotosViewModelProtocol,
        layoutFactory: CollectionCompositionalLayoutFactory
    ) {
        self.output = output
        self.vm = vm
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layoutFactory.make()
        )
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupUI()
        configureSnapshot()
        configureCollection()
        bindViewModel()
        vm.fetchPhotosData()
    }
}

// MARK: - Bindings
private extension PhotoSearchFeedView {
    func bindViewModel() {
        vm.photosState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                
                switch state {
                case .loading:
                    print("Loading")
                    
                case .loaded(let photosData):
                    self?.handleLoaded(photosData: photosData)
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
            .sink { [weak self] IDs in
                self?.updateSnapshot(itemsIDs: IDs)
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
extension PhotoSearchFeedView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let image = vm.imageItem(at: indexPath.item).image else { return }
        let photoItem = vm.photoItem(at: indexPath.item)
        output?.didSelect(image: image, data: photoItem)
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoSearchFeedView: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        guard let indexPath = indexPaths.last else { return }
        loadNextPageIfNeeded(at: indexPath)
    }
}

//MARK: - Configuration
private extension PhotoSearchFeedView {
    func configureCollection() {
        collectionView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        collectionView.dataSource = dataSource
        collectionView.delegate = self
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

// MARK: UI Setup
private extension PhotoSearchFeedView {
    func setupUI() {
        backgroundColor = Palette.Asset.whitePrimary.uiColor

        // 1. Создаём searchBar
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search photos..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        // 2. Добавляем сабвью
        addSubview(searchBar)
        addSubview(collectionView)

        // 3. Настраиваем констрейнты
        searchBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(44)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        // 4. Поведение коллекции
        collectionView.contentInsetAdjustmentBehavior = .never
    }
}

// MARK: - Typealias & Section
extension PhotoSearchFeedView:
    DiffableCollectionControllerProtocol {
    typealias Section = CustomSection
    typealias Cell = ImageCollectionCell
    typealias ItemIdentifier = ImageItem.ID
        
    enum CustomSection: Int {
        case main
    }
}

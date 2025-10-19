//
//  Untitled.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 19.10.2025.
//

import UIKit
import CoreKit
import Combine

final class PhotoSearchFeedView: UIView {

    private let collectionView: UICollectionView
    private lazy var searchBar = UISearchBar()

    private weak var output: ImageCollectionOutput?
    private let vm: PhotosSearchViewModelProtocol
    private var cancellable = Set<AnyCancellable>()
    private lazy var dataSource = makeDataSource()
    private var nextPageTriggerIndex = 0
    private let paginationOffset = 13

    init(
        output: ImageCollectionOutput? = nil,
        vm: PhotosSearchViewModelProtocol,
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
        configureSearchBar()
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
        let index = photosData.first?.index ?? 0

        if index == 0 {
            applyNew(itemsIDs: photosData.map({ $0.id }))
        } else {
            applyAdditional(itemsIDs: photosData.map({ $0.id }))
        }
        print("first index", index)
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
        let text = searchBar.text ?? ""
        vm.fetchPhotosData(query: text)
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

// MARK: - UICollectionViewDataSourcePrefetching
extension PhotoSearchFeedView: UICollectionViewDataSourcePrefetching {
    
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {

        print(nextPageTriggerIndex, indexPaths.max()!.item)
        print(indexPaths)
        print("Total items:", dataSource.snapshot().itemIdentifiers.count)

        print("contentSize:", collectionView.contentSize.height)
        print("bounds:", collectionView.bounds.height)

        guard let index = indexPaths.max()?.item else { return }
        loadNextPageIfNeeded(at: index)
    }
}

//MARK: - UISearchResultsUpdating
extension PhotoSearchFeedView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text ?? ""
        vm.fetchPhotosData(query: text)
    }
}

//MARK: - Configuration
private extension PhotoSearchFeedView {
    func configureSearchBar() {
        searchBar.delegate = self
    }

    func configureCollection() {
        configureSnapshot()
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
        
        searchBar.placeholder = "Search photos"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(searchBar)
        addSubview(collectionView)

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
    }
}

// MARK: - Typealias & Section
extension PhotoSearchFeedView: DiffableCollectionControllerProtocol {

    typealias Section = CustomSection
    typealias Cell = ImageCollectionCell
    typealias ItemIdentifier = ImageItem.ID

    enum CustomSection: Int {
        case main
    }
}

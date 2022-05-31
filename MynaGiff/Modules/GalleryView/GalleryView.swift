import Foundation
import UIKit
import Combine

enum Section {
    case gifList
}

typealias DataSource = UICollectionViewDiffableDataSource<Section, GifModel>
typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, GifModel>

protocol GalleryViewProtocol {
    func show(gifModels: [GifModel])
}

final class GalleryView: UIView, GalleryViewProtocol {
    public var shouldUploadNewContent = CurrentValueSubject<Bool, Never>(false)
    
    public var showDetailedModel = PassthroughSubject<GifModel, Never>()
    private var cancelable = Set<AnyCancellable>()
    private var uploadImageClosure: (GifModel, URL) -> AnyPublisher<Data, Error>

    private var snapshot = DataSourceSnapshot()

    private weak var galleryModule: GalleryViewController?
    private let collectionView: UICollectionView

    private lazy var gridDataSouce = DataSource(
        collectionView: self.collectionView,
        cellProvider: { [weak self] collectionView, indexPath, _ -> UICollectionViewCell? in
            guard let self = self else { return nil }
            let item = self.snapshot.itemIdentifiers(inSection: .gifList)[indexPath.row]
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryViewCell.identifier,
                for: indexPath
            ) as! GalleryViewCell
            
            cell.fill(data: nil)
            cell.shimeringView.backgroundColor = CellColors.random()
            if let url = URL(string: item.images.previewGif.url) {
                self.uploadImageClosure(item, url)
                .sink { _ in } receiveValue: { [weak self] data in
                    cell.fill(data: data)
                    
                }
                .store(in: &self.cancelable)
            }
            
            return cell
        }
    )
    
    init(
        gifModels: PassthroughSubject<[GifModel], Never>,
        uploadImageClosure: @escaping (GifModel, URL) -> AnyPublisher<Data, Error>
    ) {
        let layout = CustomGalleryLayout()
        self.uploadImageClosure = uploadImageClosure
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        layout.delegate = self
        self.setupCollectionView()
        self.prepareCollectionViewSection()
        gifModels
        .sink { [weak self] models in
            self?.show(gifModels: models)
        }
        .store(in: &self.cancelable)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        self.collectionView.dataSource = self.gridDataSouce
        self.collectionView.delegate = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = .clear
        self.collectionView.alwaysBounceVertical = true

        self.collectionView.register(
            GalleryViewCell.self,
            forCellWithReuseIdentifier: GalleryViewCell.identifier
        )

        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension GalleryView: UICollectionViewDelegateFlowLayout, CustomGalleryLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, cellWidth: CGFloat) -> CGFloat {
        let item = self.snapshot.itemIdentifiers(inSection: .gifList)[indexPath.row]
        let imageWidth = UIScreen.main.bounds.width / 2.0 - 16.0
        return CGFloat(imageWidth / (Double(item.images.previewGif.width) ?? 1.0) * (Double(item.images.previewGif.height) ?? 1.0))
        
    }
    
    private func section(at index: Int) -> Section {
        .gifList
    }

    private func indexPath(forItemAt index: Int) -> IndexPath {
        IndexPath(item: index, section: 0)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    private func prepareCollectionViewSection() {
        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([Section.gifList])
        self.gridDataSouce.apply(snapshot)
        self.snapshot = snapshot
        self.collectionView.isScrollEnabled = false
    }

    func show(gifModels: [GifModel]) {
        var newSnapshot = self.gridDataSouce.snapshot()
        if gifModels.isEmpty {
            self.collectionView.isScrollEnabled = false
        } else {
            self.collectionView.isScrollEnabled = true
        }
        let filteredModels = gifModels.filter { model in
            !(newSnapshot.itemIdentifiers.contains { $0.id == model.id })
        }
        newSnapshot.appendItems(filteredModels, toSection: .gifList)
        self.snapshot = newSnapshot
        self.gridDataSouce.apply(newSnapshot, animatingDifferences: true, completion: {})
    }
}

extension GalleryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemsCount = self.snapshot.itemIdentifiers(inSection: .gifList).count
        if  (itemsCount - indexPath.row < Int(Double(itemsCount) / 2.0)) {
            self.shouldUploadNewContent.send(true)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = self.snapshot.itemIdentifiers(inSection: .gifList)[indexPath.row]
        self.showDetailedModel.send(item)
    }
}


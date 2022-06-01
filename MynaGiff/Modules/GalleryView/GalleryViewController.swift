import SnapKit
import UIKit
import Combine

final class GalleryViewController: UIViewController{
    
    let viewModel: GalleryViewModel
    
    private var cancelable = Set<AnyCancellable>()
    
    private lazy var contentView: GalleryView = {
        return GalleryView(
            gifModels: self.viewModel.gifModels,
            uploadImageClosure: { [weak self] item, url in
                guard let self = self else {
                    return Empty<Data, Error>()
                        .eraseToAnyPublisher()
                }
                return self.viewModel.api.getImage(
                    id:item.id,
                    url: url
                )
            }
        )
    }()

    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.contentView)
        self.contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.viewModel.setupUploadEvent(uploadNewData: self.contentView.shouldUploadNewContent)
        
        self.contentView.showDetailedModel
            .sink {
                let vc = ShareViewController(
                    viewModel: ShareViewModel(
                        gifModel: $0,
                        api: self.viewModel.api
                    )
                )
                self.present(vc, animated: true)
            }
            .store(in: &self.cancelable)
        
        self.viewModel.api.getCategories()
            .sink { _ in } receiveValue: { categories in
                self.contentView.categoriesView.buildCategoryView(addedCategories: categories)
            }
            .store(in: &self.cancelable)

        self.contentView.categoriesView.chooseCategory
            .removeDuplicates()
            .sink { _ in } receiveValue: { categoryType in
                self.contentView.removeAllItems()
                self.viewModel.chosenCategoryType.send(categoryType)
                self.viewModel.isLoading = false
                self.viewModel.currentOffset = 0
                self.viewModel.offset.send(self.viewModel.currentOffset)
            }
            .store(in: &self.cancelable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

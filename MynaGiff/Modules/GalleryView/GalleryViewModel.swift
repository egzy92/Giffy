import UIKit
import Combine

final class GalleryViewModel {
    var currentOffset = 0
    var offset = PassthroughSubject<Int, Never>()
    var gifModels = PassthroughSubject<[GifModel], Never>()
    public var isLoading: Bool = false
    var chosenCategoryType = CurrentValueSubject<CategoryType, Never>(.trendy)
    public var api: GiffyAPI
    
    private var cancelable: Set<AnyCancellable> = []

    init(api: GiffyAPI) {
        self.api = api
        
        self.offset
        .removeDuplicates()
        .combineLatest(chosenCategoryType)
        .flatMap { [weak self] offset, type -> AnyPublisher<[GifModel], Error> in
            print("ZZZZ \(offset) ----- \(type.nameEncoded)")
            guard let self = self else {
                return Empty<[GifModel], Error>()
                    .eraseToAnyPublisher()
            }
            self.isLoading = true
            switch type {
            case .trendy:
                return self.api.gifModels(offset: offset)
            case .custom(let category):
                return self.api.gifSearch(category: category, offset: offset)
            }
        }
        .sink { comletion in } receiveValue: { [weak self] models in
            self?.isLoading = false
            self?.gifModels.send(Array(Set(models)))
        }
        .store(in: &self.cancelable)
        
        self.offset.send(0)
    }
    
    public func setupUploadEvent(uploadNewData: CurrentValueSubject<Bool, Never>) {
        uploadNewData
            .sink { comletion in } receiveValue: { [weak self] shouldUpload in
                guard let self = self else { return }
                if shouldUpload && !self.isLoading {
                    self.currentOffset += 1
                    self.offset.send(self.currentOffset)
                }
            }
            .store(in: &self.cancelable)
    }
    
}



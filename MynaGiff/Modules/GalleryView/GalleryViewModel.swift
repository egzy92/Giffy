import UIKit
import Combine

final class GalleryViewModel {
    var currentOffset = 0
    var offset = PassthroughSubject<Int, Never>()
    var gifModels = PassthroughSubject<[GifModel], Never>()
    var isLoading: Bool = false
    public var api: GiffyAPI
    
    private var cancelable: Set<AnyCancellable> = []

    init(api: GiffyAPI) {
        self.api = api
        
        self.offset
        .removeDuplicates()
        .flatMap { [weak self] offset -> AnyPublisher<[GifModel], Error> in
            guard let self = self else {
                return Empty<[GifModel], Error>()
                    .eraseToAnyPublisher()
            }
            self.isLoading = true
            return self.api.gifModels(offset: offset)
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



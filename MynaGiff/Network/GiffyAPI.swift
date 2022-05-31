import Foundation
import Combine
import SDWebImage

final class GiffyAPI {
    private let limit = 40
    private let apiKey = "eUweyLAZoKfMWxyD8jmTGwoLvySfAzsE"
    
    static let shared = GiffyAPI()
    private let cache = Cache(
        cache: SDImageCache.shared
    )
    
    private let baseUrl = "https://api.giphy.com/v1/gifs/trending"
    
    func gifModels(offset: Int) -> AnyPublisher<[GifModel], Error> {
        
        let fullUrl = URL(string: "\(baseUrl)?api_key=\(apiKey)&limit=\(limit)&offset=\(String(offset * limit))&rating=g")
        guard let url = fullUrl else {
            return Empty<[GifModel], Error>()
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map {
                $0.data
            }
            .decode(type: TrendingGifs.self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<TrendingGifs, Error> in
                print(error)
                return Empty<TrendingGifs, Error>()
                    .eraseToAnyPublisher()
            }
            .map { response in
                return response.data
                    .filter { model in
                        model.images.previewGif.url != nil
                    }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getImage(
        id: String,
        url: URL,
        applyCache: Bool = true
    ) -> AnyPublisher<Data, Error> {
        if let data = self.cache.getFromDisk(for: id),
           applyCache {
            return CurrentValueSubject<Data, Error>(data)
                        .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map {
                self.cache.saveToDisk(data: $0.data, for: id)
                return $0.data
            }
            .catch { _ in
                return Empty<Data, Error>()
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

import Foundation
import Combine
import SDWebImage

enum APIRequest {
    case getCategories
    case getTrendy(Int)
    case searchGif(Int, Category)
}

final class GiffyAPI {
    private let limit = 40
    private let apiKey = "eUweyLAZoKfMWxyD8jmTGwoLvySfAzsE"
    
    static let shared = GiffyAPI()
    private let cache = Cache(
        cache: SDImageCache.shared
    )
    
    private let baseUrl = "https://api.giphy.com/v1/gifs/"
    
    func getCategories() -> AnyPublisher<[Category], Error> {
        let fullUrl = URL(string: "\(baseUrl)categories?api_key=\(apiKey)")
        guard let url = fullUrl else {
            return Empty<[Category], Error>()
                .eraseToAnyPublisher()
        }
        
        return self.execute(url: url, decodingType: Categories.self)
                    .map { response in
                        return response.data
                    }
                    .eraseToAnyPublisher()
    }
    
    func gifModels(offset: Int) -> AnyPublisher<[GifModel], Error> {
        
        let fullUrl = URL(string: "\(baseUrl)trending?api_key=\(apiKey)&limit=\(limit)&offset=\(String(offset * limit))&rating=g")
        guard let url = fullUrl else {
            return Empty<[GifModel], Error>()
                .eraseToAnyPublisher()
        }
        
        return self.execute(url: url, decodingType: TrendingGifs.self)
                    .map { response in
                        return response.data
                            .filter { model in
                                model.images.previewGif.url != nil
                            }
                    }
                    .eraseToAnyPublisher()
    }
    
    func gifSearch(category: Category, offset: Int) -> AnyPublisher<[GifModel], Error> {
        let fullUrl = URL(string: "\(baseUrl)search?api_key=\(apiKey)&limit=\(limit)&offset=\(String(offset * limit))&q=\(category.nameEncoded)")
        guard let url = fullUrl else {
            return Empty<[GifModel], Error>()
                .eraseToAnyPublisher()
        }
        
        return self.execute(url: url, decodingType: TrendingGifs.self)
                    .map { response in
                        return response.data
                            .filter { model in
                                model.images.previewGif.url != nil
                            }
                    }
                    .eraseToAnyPublisher()
    }
    
    func execute<T>(url: URL,
                    decodingType: T.Type,
                    retries: Int = 0) -> AnyPublisher<T, Error> where T: Codable {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map {
                $0.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<T, Error> in
                print(error)
                return Empty<T, Error>()
                    .eraseToAnyPublisher()
            }
            .map { response in
                return response
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

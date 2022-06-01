import Foundation
import SDWebImage
import UIKit

final class Cache {
    
    private let cache: SDImageCache

    public init(cache: SDImageCache) {
        self.cache = cache
    }

    public func saveToDisk(data: Data, for key: String) {
        self.cache.storeImageData(toDisk: data, forKey: key)
    }

    public func getFromDisk(for key: String) -> Data? {
        guard let data = self.cache.diskImageData(forKey: key) else { return nil }
        return data
    }
}

import Foundation

struct TrendingGifs: Codable {
    var data: [GifModel]
    var meta: MetaInfo
    var pagination: Pagination
}

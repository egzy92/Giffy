import Foundation

struct GifModel: Codable, Hashable {
    let type: String
    let id: String
    let slug: String
    let url: String
    let bitlyUrl: String
    let embedUrl: String
    let username: String
    let source: String
    let rating: String
    
    let contentUrl: String?
    let sourceTld: String?
    let sourcePost_url: String?
    let updateDatetime: String?
    let createDatetime: String?
    let importDatetime: String?
    let trendingDatetime: String?
    let images: ImagesInfo
    let title: String
    
    private enum CodingKeys : String, CodingKey {
        case type
        case id
        case slug
        case url
        case bitlyUrl = "bitly_url"
        case embedUrl = "embed_url"
        case username
        case source
        case rating
        case contentUrl = "content_url"
        case sourceTld = "source_tld"
        case sourcePost_url = "source_post_url"
        case updateDatetime = "update_datetime"
        case createDatetime = "create_datetime"
        case importDatetime = "import_datetime"
        case trendingDatetime = "trending_datetime"
        case images
        case title
    }
}

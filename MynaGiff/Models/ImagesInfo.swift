import Foundation

struct ImagesInfo: Codable, Hashable {
    let original: ImageInfo
    var previewGif: ImageInfo
    
    private enum CodingKeys : String, CodingKey {
        case original
        case previewGif = "preview_gif"
    }
}

struct ImageInfo: Codable, Hashable {
    var height: String?
    var width: String?
    var size: String?
    var url: String?
    var mp4Size: String?
    var mp4: String?
    var webpSize: String?
    var webp: String?
    var frames: String?
    var hash: String?
    
    private enum CodingKeys : String, CodingKey {
        case height
        case width
        case size
        case url
        case mp4Size = "mp4_size"
        case mp4
        case webpSize = "webp_size"
        case webp
        case frames
        case hash
    }
}

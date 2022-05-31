import Foundation

struct Pagination: Codable {
    let offset: Int
    let totalCount: Int?
    let count: Int
    
    private enum CodingKeys : String, CodingKey {
        case offset
        case totalCount = "total_count"
        case count
    }
}

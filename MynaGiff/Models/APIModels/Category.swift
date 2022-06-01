import Foundation

struct Categories: Codable {
    var data: [Category]
    var meta: MetaInfo
    var pagination: Pagination
}

struct Category: Codable {
    let name: String
    let nameEncoded: String
    
    private enum CodingKeys : String, CodingKey {
        case name
        case nameEncoded = "name_encoded"
    }
}

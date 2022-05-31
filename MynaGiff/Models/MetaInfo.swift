import Foundation

struct MetaInfo: Codable {
    var msg: String
    var status: Int
    var responseId: String
    
    private enum CodingKeys : String, CodingKey {
        case msg
        case responseId = "response_id"
        case status
    }
}

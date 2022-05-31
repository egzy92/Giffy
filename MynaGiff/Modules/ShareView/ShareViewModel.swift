import UIKit
import Combine

final class ShareViewModel {

    public var gifModel: GifModel
    public var gifData: Data?
    public var api: GiffyAPI
    
    init(
        gifModel: GifModel,
        api: GiffyAPI
    ) {
        self.gifModel = gifModel
        self.api = api
    }
}

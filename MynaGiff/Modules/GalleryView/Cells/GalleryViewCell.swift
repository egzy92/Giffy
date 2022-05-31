import Foundation
import UIKit
import SnapKit
import FLAnimatedImage
import Combine

class GalleryViewCell: UICollectionViewCell {
    private var cancelable = Set<AnyCancellable>()
    
    static let identifier = "GalleryViewCell"
    
    public let imageView = FLAnimatedImageView()
    public var shimeringView =  UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.shimeringView)
        self.shimeringView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func fill(data: Data?) {
        self.imageView.animatedImage = .init(
            animatedGIFData: data
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

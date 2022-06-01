import Foundation
import UIKit
import SnapKit
import Combine

final class ShareSocialView: UIView {
    private var cancelable = Set<AnyCancellable>()
    public var shareWithMedia = PassthroughSubject<ShareSource, Never>()
    private var socialMediaArray: [ShareSource] = [.imessage, .inst, .fb]
    
    private let shareStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 6.0
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.shareStackView)
        self.shareStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44.0)
        }
        
        self.buildShareSourcesView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func buildShareSourcesView() {
        for source in self.socialMediaArray {
            let button = UIButton()
            button.setImage(UIImage(named: source.imageName), for: .normal)
            button.tintColor = .white
            button.imageView?.contentMode = .scaleAspectFill
            button.publisher(for: .touchUpInside)
                .sink { [weak self] in
                    self?.shareWithMedia.send(source)
                }
                .store(in: &self.cancelable)
            self.shareStackView.addArrangedSubview(button)
        }
    }
}

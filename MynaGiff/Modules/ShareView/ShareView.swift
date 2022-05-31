import Foundation
import UIKit
import Combine
import FLAnimatedImage

final class ShareView: UIView {
    
    private let buttonHeight: CGFloat = 40.0
    private let contentOffset: CGFloat = 16.0
    
    public lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    public lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    public let imageView = FLAnimatedImageView()
    
    public lazy var copyLinkButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(
            red: 85.0 / 255.0,
            green: 77.0 / 255.0,
            blue: 246.0 / 255.0,
            alpha: 1.0
        )
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Copy GIF Link", for: .normal)
        return button
    }()
    
    public lazy var copyGifButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(
            red: 29.0 / 255.0,
            green: 28.0 / 255.0,
            blue: 30.0 / 255.0,
            alpha: 1.0
        )
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Copy GIF", for: .normal)
        return button
    }()
    
    public lazy var saveToPhotos: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(
            red: 29.0 / 255.0,
            green: 28.0 / 255.0,
            blue: 30.0 / 255.0,
            alpha: 1.0
        )
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Save to Photos", for: .normal)
        return button
    }()
    
    public lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    public lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        return view
    }()
    
    public lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        return view
    }()
    
    private var cancelable = Set<AnyCancellable>()

    init(gifModel: GifModel) {
        super.init(frame: .zero)
        self.setupLayout(gifModel: gifModel)
    }
    
    private func setupLayout(gifModel: GifModel) {
        let aspectCoef = (Double(gifModel.images.original.height ?? "0") ?? 0) / (Double(gifModel.images.original.width ?? "0") ?? 1)
        
        self.addSubview(self.shareButton)
        self.shareButton.snp.makeConstraints { make in
            make.size.equalTo(self.buttonHeight)
            make.trailing.equalTo(-self.contentOffset)
            make.top.equalTo(self.contentOffset)
        }
        
        self.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { make in
            make.height.equalTo(self.buttonHeight)
            make.leading.equalTo(self.contentOffset)
            make.trailing.equalTo(-self.contentOffset)
            make.bottom.equalTo(self.contentOffset).offset(-32.0)
        }
        
        self.addSubview(self.saveToPhotos)
        self.saveToPhotos.snp.makeConstraints { make in
            make.height.equalTo(self.buttonHeight)
            make.leading.equalTo(self.contentOffset)
            make.trailing.equalTo(-self.contentOffset)
            make.bottom.equalTo(self.cancelButton.snp.top).offset(-self.contentOffset)
        }
        
        self.addSubview(self.copyGifButton)
        self.copyGifButton.snp.makeConstraints { make in
            make.height.equalTo(self.buttonHeight)
            make.leading.equalTo(self.contentOffset)
            make.trailing.equalTo(-self.contentOffset)
            make.bottom.equalTo(self.saveToPhotos.snp.top).offset(-self.contentOffset)
        }
        
        self.addSubview(self.copyLinkButton)
        self.copyLinkButton.snp.makeConstraints { make in
            make.height.equalTo(self.buttonHeight)
            make.leading.equalTo(self.contentOffset)
            make.trailing.equalTo(-self.contentOffset)
            make.bottom.equalTo(self.copyGifButton.snp.top).offset(-self.contentOffset)
        }
        
        let containerView = UIView()
        
        containerView.addSubview(self.imageView)
        self.imageView.layer.masksToBounds = true
        self.imageView.snp.makeConstraints { make in
            make.leading.equalTo(16.0)
            make.trailing.equalTo(-16.0)
            make.height.equalTo(self.imageView.snp.width).multipliedBy(aspectCoef)
            make.height.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.shareButton.snp.bottom)
            make.bottom.equalTo(self.copyLinkButton.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        
        self.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.loadingView.addSubview(self.loadingIndicator)
        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.applyLoadingIndicator(shouldShow: false)
        
        self.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints { make in
            make.size.equalTo(self.buttonHeight)
            make.leading.equalTo(16.0)
            make.top.equalTo(16.0)
        }
        
        self.backgroundColor = .black
    }
    
    func applyLoadingIndicator(shouldShow: Bool) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !shouldShow
            shouldShow ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

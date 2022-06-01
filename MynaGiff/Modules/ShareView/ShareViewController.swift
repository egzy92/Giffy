import SnapKit
import UIKit
import Combine
import MobileCoreServices
import Photos
import MessageUI

final class ShareViewController: UIViewController{
    
    private var cancelable = Set<AnyCancellable>()
    
    private var loadingInProgress = PassthroughSubject<Bool, Never>()
    
    private lazy var contentView: ShareView = {
        return ShareView(gifModel: self.viewModel.gifModel)
    }()

    init(viewModel: ShareViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let viewModel: ShareViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.contentView)
        self.contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.setupBindings()
    }
    
    private func setupBindings() {
        self.contentView.closeButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &self.cancelable)
        
        self.contentView.shareButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                if let gifData = self?.viewModel.gifData {
                    let objectsToShare = [gifData]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    activityVC.popoverPresentationController?.sourceView = self?.contentView ?? nil
                    self?.present(activityVC, animated: true, completion: nil)
                }
            }
            .store(in: &self.cancelable)
        
        self.contentView.copyLinkButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                if let url = URL(string: self?.viewModel.gifModel.images.original.url ?? "") {
                    UIPasteboard.general.url = url
                    self?.showAlert(title: "Success", text: "Coppied!")
                } else {
                    self?.showAlert(title: "Failed", text: "Something went wrong!")
                }
            }
            .store(in: &self.cancelable)
        
        self.contentView.copyGifButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                if let gifData = self?.viewModel.gifData {
                    UIPasteboard.general.setData(gifData, forPasteboardType: kUTTypeGIF as String)
                    self?.showAlert(title: "Success", text: "Coppied!")
                } else {
                    self?.showAlert(title: "Failed", text: "Something went wrong!")
                }
            }
            .store(in: &self.cancelable)
        
        self.contentView.saveToPhotos.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                if let gifData = self?.viewModel.gifData {
                    self?.loadingInProgress.send(true)
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetCreationRequest.forAsset()
                        request.addResource(with: .photo, data: gifData, options: nil)
                    }) { (success, error) in
                        self?.loadingInProgress.send(false)
                        if error != nil {
                            self?.showAlert(title: "Failed", text: "Something went wrong!")
                        } else {
                            self?.showAlert(title: "Success", text: "Image has been saved to Photos succesfully!")
                        }
                    }
                }
            }
            .store(in: &self.cancelable)
        
        self.loadingInProgress
            .sink { [weak self] loadingInProgress in
                self?.contentView.applyLoadingIndicator(shouldShow: loadingInProgress)
            }
            .store(in: &self.cancelable)
        
        self.contentView.socialShareView.shareWithMedia
            .sink { [weak self] source in
                guard let self = self,
                    let data = self.viewModel.gifData else { return }
                Sharing.handleShareSourceTapped(data: data, source: source, parentViewContoller: self)
            }
            .store(in: &self.cancelable)
        
        if let url = URL(string: self.viewModel.gifModel.images.original.url  ?? "") {
            self.contentView.applyLoadingIndicator(shouldShow: true)
            self.viewModel.api.getImage(
                id: self.viewModel.gifModel.id,
                url: url,
                applyCache: false
            )
            .sink { [weak self] _ in
                self?.loadingInProgress.send(false)
            } receiveValue: { [weak self] data in
                self?.loadingInProgress.send(true)
                self?.viewModel.gifData = data
                DispatchQueue.main.async {
                    self?.contentView.imageView.animatedImage = .init(
                        animatedGIFData: data
                    )
                }
            }
            .store(in: &self.cancelable)
        }
    }
    
    private func showAlert(
        title: String,
        text: String
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ShareViewController: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith _: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}

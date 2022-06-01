import Foundation
import MessageUI
import Photos
import UIKit

enum ShareSource {
    case imessage
    case fb
    case inst
    
    var imageName: String {
        switch self{
        case .imessage:
            return "imessage"
        case .fb:
            return "fb"
        case .inst:
            return "inst"
        }
    }
}

final class Sharing {

    public static func handleShareSourceTapped(
        data: Data,
        source: ShareSource,
        parentViewContoller: UIViewController
    ) {
        switch source {
        case .imessage:
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = parentViewContoller as? MFMessageComposeViewControllerDelegate
                messageVC.addAttachmentData(data, typeIdentifier: "public.data", filename: "giffy.gif")
            parentViewContoller.present(messageVC, animated: true, completion: nil)
        case .inst:
            guard let instagramURL = URL(string: "instagram://app"), UIApplication.shared.canOpenURL(instagramURL) else {
                return
            }

            if let instagramStoriesURL = URL(string: "instagram-stories://share")
            {
                let pasteboardItems: [[String: Any]] = [["com.instagram.sharedSticker.backgroundImage": data, "com.instagram.sharedSticker.appID": "egzy.Giffy"]]
                let pastboardOptions: [UIPasteboard.OptionsKey: Any] = [UIPasteboard.OptionsKey.expirationDate: Date(timeIntervalSinceNow: 60 * 5)]
                if UIApplication.shared.canOpenURL(instagramStoriesURL) {
                    UIPasteboard.general.setItems(pasteboardItems, options: pastboardOptions)
                    UIApplication.shared.open(instagramStoriesURL, options: [:], completionHandler: nil)
                }
            }
        case .fb:
                if let facebookStoriesURL = URL(string: "facebook-stories://share")
                {
                    let pasteboardItems: [[String: Any]] = [["com.facebook.sharedSticker.backgroundImage": data, "com.facebook.sharedSticker.appID": "egzy.Giffy"]]
                    let pastboardOptions: [UIPasteboard.OptionsKey: Any] = [UIPasteboard.OptionsKey.expirationDate: Date(timeIntervalSinceNow: 60 * 5)]
                    if UIApplication.shared.canOpenURL(facebookStoriesURL) {
                        UIPasteboard.general.setItems(pasteboardItems, options: pastboardOptions)
                        UIApplication.shared.open(facebookStoriesURL, options: [:], completionHandler: nil)
                    }
                }
        }
    }
}

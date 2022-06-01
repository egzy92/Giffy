import UIKit
import Foundation

final class CategoryButton: UIButton {
    public var category: CategoryType
    
    init(
        category: Category?,
        title: String,
        action: @escaping () -> ()
    ) {
        if let category = category {
            self.category = .custom(category)
        } else {
            self.category = .trendy
        }
        super.init(frame: .zero)
        self.setTitleColor(.white, for: .normal)
        self.setTitle(title, for: .normal)
        self.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        self.layer.cornerRadius = 20.0
        self.addAction(action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

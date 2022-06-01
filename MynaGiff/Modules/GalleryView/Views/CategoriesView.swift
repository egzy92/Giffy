import Foundation
import UIKit
import SnapKit
import Combine

final class CategoriesView: UIView {
    public var chooseCategory = PassthroughSubject<CategoryType, Never>()
    
    private var categories = [Category]()
    private var chosenCategory: CategoryType = .trendy
    
    private let categoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 4.0
        return stackView
    }()
    
    private let categoriesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .black
        
        self.addSubview(self.categoriesScrollView)
        self.categoriesScrollView.snp.makeConstraints { make in
            make.height.equalTo(44.0)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.categoriesScrollView.addSubview(self.categoriesStackView)
        self.categoriesStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.buildCategoryView(addedCategories: [])
    }
    
    public func buildCategoryView(addedCategories: [Category]) {
        if self.categoriesStackView.arrangedSubviews.count == 0 {
            let trendingButton = CategoryButton(
                category: nil,
                title: "trending",
                action: { [weak self] in
                    self?.categoryButtonTapped(category: nil)
                }
            )
            self.categoriesStackView.addArrangedSubview(
                trendingButton
            )
            self.categoryButtonTapped(category: nil)
        }
        let filteredCategories = addedCategories.filter { !((self.categories.map { $0.nameEncoded }).contains($0.nameEncoded)) }
        categories.append(contentsOf: filteredCategories)
        for category in filteredCategories {
            let categoryButton = CategoryButton(
                category: category,
                title: category.name,
                action: { [weak self] in
                    self?.categoryButtonTapped(category: category)
            })
            self.categoriesStackView.addArrangedSubview(categoryButton)
        }
        
    }
    
    private func categoryButtonTapped(category: Category?) {
        for subview in self.categoriesStackView.arrangedSubviews {
            if let categoryButton = subview as? CategoryButton {
                if (categoryButton.category.nameEncoded == category?.nameEncoded) || (categoryButton.category.nameEncoded == "trendy" && category == nil) {
                    (subview as? CategoryButton)?.backgroundColor = UIColor(red: 103.0 / 255.0, green: 67.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
                } else {
                    (subview as? CategoryButton)?.backgroundColor = .clear
                }
            }
        }
        if let category = category {
            self.chosenCategory = .custom(category)
        } else {
            self.chosenCategory = .trendy
        }
        self.chooseCategory.send(self.chosenCategory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

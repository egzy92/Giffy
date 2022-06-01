import Foundation

enum CategoryType: Equatable {
    static func == (lhs: CategoryType, rhs: CategoryType) -> Bool {
        switch (rhs, lhs) {
        case (.trendy, .trendy):
            return true
        case (.custom(_), .trendy), (.trendy, .custom(_)):
            return false
        case (.custom(let rhsCategory),.custom(let lhsCategory)):
            return (rhsCategory.nameEncoded == lhsCategory.nameEncoded) && (rhsCategory.name == lhsCategory.name)
        }
    }
    
    case trendy
    case custom(Category)
    
    var nameEncoded: String {
        switch self {
        case .trendy:
            return "trendy"
        case .custom(let category):
            return category.nameEncoded
        }
    }
}

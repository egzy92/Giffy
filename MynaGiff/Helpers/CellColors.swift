import Foundation
import UIKit

enum CellColors: Int {
    case blue
    case red
    case navy
    case yellow
    
    var color: UIColor {
        switch self {
        case .blue:
            return UIColor(red: 68.0 / 255.0, green: 76.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        case .red:
            return UIColor(red: 206.0 / 255.0, green: 90.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
        case .navy:
            return UIColor(red: 120.0 / 255.0, green: 165.0 / 255.0, blue: 163.0 / 255.0, alpha: 1.0)
        case .yellow:
            return UIColor(red: 225.0 / 255.0, green: 177.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0)
        }
    }
    
    static func random () -> UIColor {
        let randomColorIndex = Int.random(in: 0...3)
        if let colorItem = CellColors(rawValue: randomColorIndex) {
            return colorItem.color
        }
        return .clear
    }
}

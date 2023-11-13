import UIKit

extension UIColor {
    func image(_ size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { [weak self] context in
            self?.setFill()
            context.fill(.init(origin: .zero, size: size))
        }
    }
}

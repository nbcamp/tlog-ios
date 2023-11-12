import UIKit

extension UIImageView {
    func load(
        url: String?,
        loading: UIImage? = nil,
        fallback: UIImage? = nil
    ) {
        image = loading
        DispatchQueue.global().async { [weak self] in
            guard let self, let url, let url = URL(string: url) else { return }
            let image = try? UIImage(data: Data(contentsOf: url))
            DispatchQueue.main.async { [weak self] in
                self?.image = if let image { image } else { fallback }
            }
        }
    }
}

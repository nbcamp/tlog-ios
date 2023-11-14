import UIKit

extension UIImageView {
    func load(
        url: String?,
        loading: UIImage? = nil,
        fallback: UIImage? = nil,
        onSuccess: (() -> Void)? = nil,
        onFailed: (() -> Void)? = nil
    ) {
        image = loading
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let url,
               let url = URL(string: url),
               let image = try? UIImage(data: Data(contentsOf: url))
            {
                DispatchQueue.main.async { [weak self] in
                    onSuccess?()
                    self?.image = image
                }
                return
            }
            DispatchQueue.main.async { [weak self] in
                onFailed?()
                self?.image = fallback
            }
        }
    }
}

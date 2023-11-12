import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data)
            else { debugPrint(#function, "이미지 불러오기 실패"); return }
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
}

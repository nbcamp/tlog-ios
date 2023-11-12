import Kingfisher
import UIKit

final class AvatarImageView: UIImageView {
    var url: String? {
        didSet {
            guard let url, let url = URL(string: url) else { return }
            kf.indicatorType = .activity
            kf.setImage(
                with: url,
                placeholder: UIColor.systemGray6.image(.init(width: 100, height: 100)),
                options: [
                    .transition(.fade(0.5)),
                    .cacheOriginalImage
                ]
            ) { [weak self] result in
                guard let self, case let .failure(error) = result else { return }
                debugPrint(#function, error)
                image = .init(systemName: "person.circle.fill")
                layer.borderWidth = 5.0
                layer.borderColor = UIColor.accent.cgColor
            }
        }
    }

    convenience init() {
        self.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    private func setup() {
        layer.cornerRadius = min(frame.width, frame.height) / 2
        clipsToBounds = true
    }
}

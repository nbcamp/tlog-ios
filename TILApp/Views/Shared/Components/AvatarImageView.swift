import Kingfisher
import UIKit

final class AvatarImageView: UIImageView {
    var url: String? {
        didSet {
            guard let url, let url = URL(string: url) else {
                setNeedsLayout()
                return
            }
            initialized = true
            removeDefault()
            kf.indicatorType = .activity
            kf.setImage(
                with: url,
                placeholder: UIColor.systemGray6.image(.init(width: 100, height: 100)),
                options: [.cacheOriginalImage]
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    removeDefault()
                case .failure(let error):
                    setDefault()
                    debugPrint(#function, error)
                }
            }
        }
    }

    private var initialized = false

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()

        if !initialized {
            setDefault()
        }
    }

    private func setupUI() {
        layer.cornerRadius = min(frame.width, frame.height) / 2
        clipsToBounds = true
    }

    func removeDefault() {
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.clear.cgColor
    }

    func setDefault() {
        image = .init(systemName: "person.fill")?
            .withTintColor(.systemGray4)
            .resized(to: bounds.size)
        layer.borderWidth = bounds.width / 15
        layer.borderColor = UIColor.systemGray4.cgColor
    }
}

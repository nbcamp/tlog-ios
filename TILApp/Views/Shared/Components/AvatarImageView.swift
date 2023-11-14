import UIKit

final class AvatarImageView: UIImageView {
    var url: String? {
        didSet {
            guard let url else { return }
            guard url != prevUrl else { return }
            prevUrl = url

            load(
                url: url,
                loading: UIColor.systemGray5.image(.init(width: 100, height: 100)),
                onSuccess: removeDefault,
                onFailed: setDefault
            )
        }
    }

    private var prevUrl: String?

    private var initialized = false

    init() {
        super.init(frame: .zero)
        clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) / 2

        if !initialized, image == nil {
            setDefault()
        }
    }

    func cancel() {
        url = nil
        prevUrl = nil
        image = nil
        initialized = false
        setNeedsLayout()
    }

    func removeDefault() {
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.clear.cgColor
    }

    func setDefault() {
        layer.borderWidth = bounds.width / 15
        layer.borderColor = UIColor.accent.cgColor
    }
}

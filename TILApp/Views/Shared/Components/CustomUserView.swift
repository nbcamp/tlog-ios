import UIKit

class CustomUserView: UIView {
    var variant: CustomFollowButton.Variant {
        get { return button.variant }
        set { button.variant = newValue }
    }

    var buttonTitle: String {
        get { button.titleLabel?.text ?? "" }
        set { button.setTitle(newValue, for: .normal) }
    }

    var nicknameText: String {
        get { customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    var contentText: String {
        get { customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    var followButtonTapped: (() -> Void)? {
        get { button.buttonTapped }
        set { button.buttonTapped = newValue }
    }

    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.tintColor = .accent
        $0.backgroundColor = .clear
    }

    private let button = CustomFollowButton()

    private let customLabelView = CustomLabelView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        pin.height(67)

        addSubview(imageView)
        addSubview(customLabelView)
        addSubview(button)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.pin.vCenter().left(10).width(47).height(47)
        button.pin.right(10).vCenter()
        customLabelView.pin.after(of: imageView).before(of: button).marginLeft(10).marginRight(10)

        imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0
    }

    func setup(username: String, avatarUrl: String? = nil, content: String, variant: CustomFollowButton.Variant) {
        imageView.load(
            url: avatarUrl,
            loading: UIColor.systemGray5.image(.init(width: 100, height: 100)),
            fallback: .init(systemName: "person.circle.fill")
        )
        nicknameText = username
        contentText = content
        self.variant = variant
    }
}

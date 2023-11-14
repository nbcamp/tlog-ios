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
        get { profileImageView.image }
        set { profileImageView.image = newValue }
    }

    var followButtonTapped: (() -> Void)? {
        get { button.buttonTapped }
        set { button.buttonTapped = newValue }
    }

    private let profileImageView = AvatarImageView()

    private let button = CustomFollowButton()

    private let customLabelView = CustomLabelView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        pin.height(67)

        addSubview(profileImageView)
        addSubview(customLabelView)
        addSubview(button)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        profileImageView.pin.vCenter().left(10).width(47).height(47)
        button.pin.right(10).vCenter()
        customLabelView.pin.after(of: profileImageView).before(of: button).marginLeft(10).marginRight(10)
    }

    func setup(username: String, avatarUrl: String? = nil, content: String, variant: CustomFollowButton.Variant) {
        profileImageView.url = avatarUrl
        nicknameText = username
        contentText = content
        self.variant = variant
    }

    func clear() {
        profileImageView.cancel()
    }
}

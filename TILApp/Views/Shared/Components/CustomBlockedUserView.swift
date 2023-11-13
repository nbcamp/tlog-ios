import UIKit

class CustomBlockedUserView: UIView {
    var image: UIImage? {
        get { profileImageView.image }
        set { profileImageView.image = newValue }
    }

    var unblockButtonTapped: (() -> Void)? {
        get { button.buttonTapped }
        set { button.buttonTapped = newValue }
    }

    private let nicknameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.sizeToFit()
    }

    private let profileImageView = AvatarImageView()

    private let button = CustomFollowButton().then {
        $0.variant = .unblock
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        pin.height(67)

        addSubview(profileImageView)
        addSubview(nicknameLabel)
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
        nicknameLabel.pin
            .after(of: profileImageView)
            .before(of: button, aligned: .center)
            .sizeToFit()
            .marginLeft(10)
            .marginRight(10)
    }

    func setup(username: String, avatarUrl: String?) {
        self.nicknameLabel.text = username
        self.profileImageView.url = avatarUrl
    }
}

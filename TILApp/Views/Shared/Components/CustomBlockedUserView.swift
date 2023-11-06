import UIKit

class CustomBlockedUserView: UIView {
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    var unblockButtonTapped: (() -> Void)? {
        get { button.buttonTapped }
        set { button.buttonTapped = newValue }
    }

    private let nicknameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.sizeToFit()
    }

    private let imageView = UIImageView().then {
        $0.backgroundColor = .systemGray5
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }

    private let button = CustomFollowButton().then {
        $0.variant = .unblock
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        pin.height(67)

        addSubview(imageView)
        addSubview(nicknameLabel)
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
        nicknameLabel.pin.after(of: imageView).before(of: button).vCenter().sizeToFit().marginLeft(10).marginRight(10)

        imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0
    }

    func setup(image: UIImage, nicknameText: String) {
        self.image = image
        self.nicknameLabel.text = nicknameText
    }
}

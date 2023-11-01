import UIKit

class CustomFollowButton: UIButton {
    enum Variant {
        case follow
        case unfollow
    }

    var variant: Variant = .follow {
        didSet {
            switch variant {
            case .follow:
                setupFollowButton()
            case .unfollow:
                setupUnfollowButton()
            }
        }
    }

    var buttonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.accent.cgColor
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)

        pin.width(70).height(30)
    }

    private func setupFollowButton() {
        backgroundColor = .accent
        setTitleColor(UIColor.white, for: .normal)
        setTitle("팔로우", for: .normal)
    }

    private func setupUnfollowButton() {
        backgroundColor = UIColor.white
        setTitleColor(.accent, for: .normal)
        setTitle("언팔로우", for: .normal)
    }

    @objc private func _buttonTapped() {
        buttonTapped?()
    }
}

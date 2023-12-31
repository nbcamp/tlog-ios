import UIKit

class CustomFollowButton: UIButton {
    enum Variant {
        case follow
        case unfollow
        case hidden
        case unblock
    }

    var variant: Variant = .follow {
        didSet {
            switch variant {
            case .follow:
                setupFollowButton()
            case .unfollow:
                setupUnfollowButton()
            case .hidden:
                isHidden = true
            case .unblock:
                setupUnblockButton()
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
        isHidden = false
        backgroundColor = .accent
        setTitleColor(UIColor.white, for: .normal)
        setTitle("팔로우", for: .normal)
    }

    private func setupUnfollowButton() {
        isHidden = false
        backgroundColor = UIColor.white
        setTitleColor(.accent, for: .normal)
        setTitle("언팔로우", for: .normal)
    }
    
    private func setupUnblockButton() {
        isHidden = false
        backgroundColor = .systemRed
        layer.borderColor = UIColor.systemRed.cgColor
        setTitleColor(.white, for: .normal)
        setTitle("차단 해제", for: .normal)
    }

    @objc private func _buttonTapped() {
        buttonTapped?()
    }
}

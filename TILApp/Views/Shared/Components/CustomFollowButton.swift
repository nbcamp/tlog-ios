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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)

        pin.width(70).height(30)
    }

    private func setupFollowButton() {
        backgroundColor = UIColor(named: "AccentColor")
        setTitleColor(UIColor.white, for: .normal)
        setTitle("팔로우", for: .normal)
    }

    private func setupUnfollowButton() {
        backgroundColor = UIColor.white
        setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        setTitle("언팔로우", for: .normal)
    }
}

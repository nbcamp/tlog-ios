import UIKit

class CustomCommunityTILView: UIView {
    lazy var userView = CustomUserView()
    lazy var tilView = CustomTILView()

    private lazy var dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12.5)
        $0.textColor = .systemGray2
        $0.text = "00초 전"
        $0.sizeToFit()
    }

    // TODO: heartIcon variant 만들기
    private lazy var heartIcon = UIImageView().then {
        $0.image = UIImage(systemName: "heart")?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
        $0.contentMode = .scaleAspectFit
        $0.frame.size = CGSize(width: 16.5, height: 16.5)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pin.height(161)

        addSubview(tilView)
        addSubview(userView)
        addSubview(dateLabel)
        addSubview(heartIcon)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userView.pin.horizontally(10)
        tilView.pin.below(of: userView).horizontally().marginTop(-15)
        dateLabel.pin.left(20).bottom(10)
        heartIcon.pin.right(20).bottom(10)
        
        tilView.resizeText()
    }
}

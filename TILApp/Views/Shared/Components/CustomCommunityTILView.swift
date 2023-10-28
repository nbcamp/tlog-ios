import UIKit

class CustomCommunityTILView: UIView {
    // TODO: 커뮤니티 페이지 연결 이후 private으로 변경하기
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
        $0.pin.width(16.5).height(16.5)
    }

    private lazy var likeView = UIView().then {
        $0.pin.width(25).height(25)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        pin.height(161)

        addSubview(tilView)
        addSubview(userView)
        addSubview(dateLabel)
        addSubview(heartIcon)
        addSubview(likeView)
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
        likeView.pin.bottomRight().marginBottom(5).marginRight(15)

        tilView.resizeText()
    }
}

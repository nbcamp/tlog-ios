import UIKit

class CustomCommunityTILView: UIView {
    var userProfileTapped: (() -> Void)?
    var postTapped: (() -> Void)?

    var contentText: String {
        get { userView.contentText }
        set { userView.contentText = newValue }
    }

    private lazy var userView = CustomUserView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(_userProfileTapped))
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tapGesture)
    }

    private lazy var tilView = CustomTILView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(_postTapped))
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tapGesture)
    }

    private lazy var dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12.5)
        $0.textColor = .systemGray2
        $0.text = "00초 전"
        $0.sizeToFit()
        $0.pin.height(20)
    }

    private lazy var heartButton = LikeButton(liked: false).then {
        $0.contentMode = .scaleAspectFit
        $0.pin.width(20).height(20)
    }

    private let tagsCollectionView = HorizontalTagsCollectionView().then {
        $0.height = 18
        $0.radius = 5
        $0.pin.height(20)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        pin.height(180)

        addSubview(tilView)
        addSubview(userView)
        addSubview(dateLabel)
        addSubview(heartButton)
        addSubview(tagsCollectionView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userView.pin.horizontally(10).top(10)
        tilView.pin.below(of: userView).horizontally().marginTop(-15)
        dateLabel.pin.left(20).bottom(10)
        heartButton.pin.top(to: dateLabel.edge.top).right(20).bottom(10)
        tagsCollectionView.pin.after(of: dateLabel, aligned: .center).width(60%).marginLeft(10)

        tilView.resizeText()
    }

    @objc private func _userProfileTapped() {
        userProfileTapped?()
    }

    @objc private func _postTapped() {
        postTapped?()
    }

    // TODO: 팔로워 옆에 연속 작성 일수 추가해야 함
    func setup(post: CommunityPost) {
        userView.setup(
            username: post.user.username,
            avatarUrl: post.user.avatarUrl,
            content: "팔로워 \(post.user.followers)",
            variant: .hidden
        )
        tilView.setup(withTitle: post.title, content: post.content, date: "")
        tagsCollectionView.tags = post.tags
        dateLabel.text = post.publishedAt.relativeFormat()
        dateLabel.sizeToFit()
        heartButton.isSelected = post.liked
    }

    func clear() {
        userView.clear()
    }
}

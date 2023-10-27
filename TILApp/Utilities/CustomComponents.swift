import UIKit

// TODO: 테이블뷰 탭 만들기!

class CustomComponentsViewController: UIViewController {
    private lazy var customLargeButton = CustomLargeButton().then {
        $0.setTitle("하이하이", for: .normal)
        view.addSubview($0)
    }

    private lazy var customFollowButton = CustomFollowButton().then {
        $0.setTitle("팔로우", for: .normal)
        view.addSubview($0)
    }

    private lazy var customUnfollowButton = CustomUnfollowButton().then {
        $0.setTitle("언팔로우", for: .normal)
        view.addSubview($0)
    }

    private lazy var customTextFieldView = CustomTextFieldViewWithValidation().then {
        $0.titleText = "하이하이하이하이하이하이"
        $0.placeholder = "뭐뭐를 입력해주세요."
        $0.validationText = "유효한 값입니다."
        view.addSubview($0)
    }

    private lazy var customLabelView = CustomLabelView().then {
        $0.nicknameText = "닉네임"
        $0.dateText = "2023-10-19"
        view.addSubview($0)
    }

    private lazy var customUserView = CustomUserView().then {
        $0.buttonTitle = "팔로우?"
        $0.nicknameText = "누구야"
        $0.dateText = "2023-10-192023-10-192023-10-19"
        view.addSubview($0)
    }

    private lazy var customTILView = CustomTILView().then {
        $0.setup(withTitle: "제목", content: "내용\n내용", date: "2023-10-17")
        view.addSubview($0)
    }

    private lazy var customCommunityTILView = CustomCommunityTILView().then {
        $0.userView.setup(image: UIImage(), nicknameText: "닉네임", contentText: "팔로워 11", buttonTitle: "팔로우")
        $0.tilView.setup(withTitle: "제목제목", content: "내용\n내용내용내용내용", date: "2023-10-19")
        view.addSubview($0)
    }

    private lazy var customBlogView = CustomBlogView().then {
        $0.blogNameText = "내 블로그으"
        $0.blogURLText = "http://djjjwjjjrhhhwj.com/sss"
        view.addSubview($0)
    }

    private lazy var customSegmentedControl = CustomSegmentedControl(items: ["작성한 글", "좋아요"]).then {
        view.addSubview($0)
    }

    private lazy var customTagView = CustomTagView().then {
        $0.labelText = "[TIL/Swift]"
        $0.tags = ["TIL", "iOS", "Swift", "내배캠", "으으으", "iOS", "Swift", "내배캠", "으으으"]
        view.addSubview($0)
    }

    private lazy var customTagHeaderView = CustomTagHeaderView().then {
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        customLargeButton.pin
            .top(view.pin.safeArea)
            .marginTop(15)

        customFollowButton.pin
            .hCenter()
            .top(to: customLargeButton.edge.bottom)
            .marginTop(15)

        customUnfollowButton.pin
            .hCenter()
            .top(to: customFollowButton.edge.bottom)
            .marginTop(15)

        customTextFieldView.pin
            .top(to: customUnfollowButton.edge.bottom)
            .marginTop(15)

        customUserView.pin
            .top(to: customTextFieldView.edge.bottom)
            .marginTop(15)

        customTILView.pin
            .top(to: customUserView.edge.bottom)
            .marginTop(15)

        customCommunityTILView.pin
            .top(to: customTILView.edge.bottom)
            .marginTop(15)

        customBlogView.pin
            .top(to: customCommunityTILView.edge.bottom)
            .marginTop(15)

//        customSegmentedControl.pin
//            .hCenter()
//            .top(to: customBlogView.edge.bottom)
//            .marginTop(15)

        customTagView.pin
            .top(to: customBlogView.edge.bottom)
            .margin(15)

        customTagHeaderView.pin
            .top(to: customTagView.edge.bottom)
            .margin(15)
    }
}

class CustomLargeButton: UIButton {
    private let height: CGFloat = 35
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = UIColor(named: "AccentColor")
        layer.cornerRadius = 12
        setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20).height(height)
    }
}

class CustomLargeBorderButton: UIButton {
    private let height: CGFloat = 35
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        layer.cornerRadius = 12
        setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20).height(height)
    }
}

class CustomFollowButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        backgroundColor = UIColor(named: "AccentColor")
        layer.cornerRadius = 12
        setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(90).height(30)
    }
}

class CustomUnfollowButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        layer.cornerRadius = 12
        setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(90).height(30)
    }
}

class CustomTitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        textColor = UIColor.systemGray
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.height(24)
    }
}

class CustomTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        borderStyle = .roundedRect
        font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20).height(40)
    }
}

class CustomTextFieldView: UIView {
    private let titleLabel = CustomTitleLabel()
    private let textField = CustomTextField()

    private let height: CGFloat = 64
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    var titleText: String {
        get { titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }

    var placeholder: String {
        get { textField.placeholder ?? "" }
        set { textField.placeholder = newValue }
    }

    var mainText: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    var delegate: UITextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        flex.define {
            $0.addItem(titleLabel).margin(0, 20).height(24)
            $0.addItem(textField).margin(0, 20).height(40)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(height)
        flex.layout()
    }
}

class CustomTextFieldViewWithValidation: UIView {
    private let customTextFieldView = CustomTextFieldView()

    private let validationLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .light)
        $0.textColor = UIColor.systemGreen
    }

    private let height: CGFloat = 84
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    var titleText: String {
        get { customTextFieldView.titleText }
        set { customTextFieldView.titleText = newValue }
    }

    var placeholder: String {
        get { customTextFieldView.placeholder }
        set { customTextFieldView.placeholder = newValue }
    }

    var mainText: String {
        get { customTextFieldView.mainText }
        set { customTextFieldView.mainText = newValue }
    }

    var validationText: String {
        get { validationLabel.text ?? "" }
        set { validationLabel.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        flex.define {
            $0.addItem(customTextFieldView)
            $0.addItem(validationLabel).margin(0, 25, 0, 20).height(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(height)
        flex.layout()
    }
}

class CustomLabelView: UIView {
    private let nicknameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .systemGray2
    }

    private let height: CGFloat = 67
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    var nicknameText: String {
        get { nicknameLabel.text ?? "" }
        set { nicknameLabel.text = newValue }
    }

    var dateText: String {
        get { dateLabel.text ?? "" }
        set { dateLabel.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        flex.justifyContent(.center).define {
            $0.addItem(nicknameLabel)
            $0.addItem(dateLabel).marginTop(2)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(height)
        flex.layout()
    }
}

class CustomUserView: UIView {
    private let button = CustomFollowButton()

    private let customLabelView = CustomLabelView()

    private let imageView = UIImageView().then {
        $0.backgroundColor = .systemGray5
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }

    var buttonTitle: String {
        get { button.titleLabel?.text ?? "" }
        set { button.setTitle(newValue, for: .normal) }
    }

    var nicknameText: String {
        get { customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    var dateText: String {
        get { customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        addSubview(imageView)
        addSubview(customLabelView)
        addSubview(button)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(100%).height(67)

        imageView.pin
            .vCenter()
            .left(10)
            .width(47)
            .height(47)

        customLabelView.pin
            .after(of: imageView)
            .marginLeft(10)

        button.pin
            .vCenter(-15)
            .right(100)

        imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0
    }

    func setup(image: UIImage, nicknameText: String, contentText: String, buttonTitle: String) {
        imageView.image = image
        customLabelView.nicknameText = nicknameText
        customLabelView.dateText = contentText
        button.setTitle(buttonTitle, for: .normal)
    }
}

class CustomTILView: UIView {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18)
    }

    private let contentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .systemGray2
        $0.numberOfLines = 2
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor(white: 0.33, alpha: 1.0)
        $0.textAlignment = .right
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(dateLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(85)

        titleLabel.pin
            .top(15)
            .left(20)
            .width(240)
            .height(22)

        contentLabel.pin
            .top(39)
            .left(21)
            .right(20)
            .height(36)

        dateLabel.pin
            .top(17)
            .right(20)
            .width(90)
            .height(20)
    }

    func setup(withTitle title: String, content: String, date: String) {
        titleLabel.text = title
        contentLabel.text = content
        dateLabel.text = date
    }

    func resizeText() {
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
    }
}

class CustomCommunityTILView: UIView {
    let userView = CustomUserView()
    let tilView = CustomTILView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        tilView.resizeText()

        addSubview(tilView)
        addSubview(userView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(141)
        tilView.pin.top(54)
    }
}

class CustomBlogView: UIView {
    enum Variant {
        case primary
        case normal
    }

    var variant: Variant = .normal {
        didSet {
            switch variant {
            case .primary:
                addSubview(primaryLabel)
            case .normal:
                primaryLabel.removeFromSuperview()
            }
        }
    }

    private let customLabelView = CustomLabelView()
    private let chevronImage = UIImageView(image: UIImage(
        systemName: "chevron.right",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
    ))
    private let primaryLabel = UILabel().then {
        $0.text = "대표 블로그"
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor(named: "AccentColor")
        $0.sizeToFit()
    }

    var blogNameText: String {
        get { customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    var blogURLText: String {
        get { customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        chevronImage.tintColor = UIColor(named: "AccentColor")
        chevronImage.contentMode = .scaleAspectFit

        addSubview(customLabelView)
        addSubview(chevronImage)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(67)

        customLabelView.pin.left(20)
        chevronImage.pin.width(20).height(20).centerRight(20)

        switch variant {
        case .primary:
            primaryLabel.pin.right(to: chevronImage.edge.left).vCenter()
        case .normal:
            break
        }
    }
}

// TODO: 테두리, 배경색, 폰트 등등 수정하기
class CustomSegmentedControl: UISegmentedControl {
    override init(items: [Any]?) {
        super.init(items: items)

        backgroundColor = .systemBackground
        selectedSegmentIndex = 0

        addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)

        // 적용 안됨;
        for segment in subviews {
            segment.layer.cornerRadius = 0
        }
        updateBottomBorder()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func segmentDidChange() {
        updateBottomBorder()
    }

    private func updateBottomBorder() {
        layer.sublayers?.removeAll { $0.name == "bottomBorder" }

        if selectedSegmentIndex != UISegmentedControl.noSegment {
            let selectedSegment = subviews[selectedSegmentIndex]
            let bottomBorder = CALayer()
            bottomBorder.backgroundColor = UIColor.black.cgColor
            bottomBorder.frame = CGRect(
                x: selectedSegment.frame.minX,
                y: frame.size.height - 2, width: selectedSegment.frame.width, height: 2
            )
            bottomBorder.name = "bottomBorder"
            layer.addSublayer(bottomBorder)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(100%).height(30)
        updateBottomBorder()
    }
}

class CustomTagHeaderView: UIView {
    private let height: CGFloat = 30
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    private let label = CustomTitleLabel().then {
        $0.text = "블로그 게시물 자동 태그 설정"
        $0.sizeToFit()
    }

    private let button = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
    }

    private let line = UIView().then {
        $0.backgroundColor = .systemGray
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        addSubview(label)
        addSubview(line)
        addSubview(button)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(height)
        label.pin.left(20)
        button.pin.right(20).width(24).height(24)
        line.pin.bottom(to: edge.bottom).horizontally(20).height(0.5)
    }

    func addTargetForButton(target: Any?, action: Selector, for event: UIControl.Event) {
        button.addTarget(target, action: action, for: event)
    }
}

class CustomTagView: UIView {
    private let height: CGFloat = 67
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    private let titleLabel = UILabel().then {
        $0.text = "제목"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor.systemGray
        $0.sizeToFit()
    }

    private let tagLabel = UILabel().then {
        $0.text = "태그"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor.systemGray
        $0.sizeToFit()
    }

    private let titleContentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
    }

    private let tagContentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
    }

    private let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.systemGray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 13)
    }

    var labelText: String {
        get { titleContentLabel.text ?? "" }
        set { titleContentLabel.text = newValue }
    }

    var tags: [String] = [] {
        didSet {
            tagContentLabel.text = tags.joined(separator: " | ")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        flex.direction(.column).justifyContent(.spaceBetween).padding(10).height(height).define { flex in
            flex.addItem().direction(.row).grow(1).define {
                $0.addItem(titleLabel).marginRight(10)
                $0.addItem(titleContentLabel).maxWidth(80%)
            }
            flex.addItem().direction(.row).grow(1).define {
                $0.addItem(tagLabel).marginRight(10)
                $0.addItem(tagContentLabel).maxWidth(80%)
            }
        }

        addSubview(deleteButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.horizontally().height(height)
        flex.layout()
        deleteButton.pin.width(30).height(30).vCenter().right(10)

        layer.cornerRadius = 12
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray3.cgColor
    }

    func addTargetForButton(target: Any?, action: Selector, for event: UIControl.Event) {
        deleteButton.addTarget(target, action: action, for: event)
    }
}

import UIKit
import Then
import PinLayout
import FlexLayout

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

    private lazy var customTextFieldView = CustomTextFieldView().then {
        $0.titleText = "하이하이하이"
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
        $0.TILView.setup(withTitle: "제목제목", content: "내용\n내용내용내용내용", date: "2023-10-19")
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

        customSegmentedControl.pin
            .hCenter()
            .top(to: customBlogView.edge.bottom)
            .marginTop(15)
    }
}

class CustomLargeButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = UIColor(named: "AccentColor")
        layer.cornerRadius = 12
        setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20).height(40)
    }
}

class CustomLargeBorderButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        layer.cornerRadius = 12
        setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20).height(40)
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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
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

class CustomTextFieldView: UIView {

    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor.systemGray
    }

    private let validationLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .light)
        $0.textColor = UIColor.systemGreen
    }

    private let textField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }

    public var titleText: String {
        get { return titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }

    public var validationText: String {
        get { return validationLabel.text ?? "" }
        set { validationLabel.text = newValue }
    }

    public var placeholder: String {
        get { return textField.placeholder ?? "" }
        set { textField.placeholder = newValue }
    }
    
    public var mainText: String {
        get { return textField.text ?? "" }
        set { textField.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        //backgroundColor = .systemBackground

        self.flex.define {
            $0.addItem(titleLabel).margin(0,20).height(24)
            $0.addItem(textField).margin(0,20).height(40)
            $0.addItem(validationLabel).margin(0,25,0,20).height(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.pin.width(100%).height(84)
        self.flex.layout()
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

    public var nicknameText: String {
        get { return nicknameLabel.text ?? "" }
        set { nicknameLabel.text = newValue }
    }

    public var dateText: String {
        get { return dateLabel.text ?? "" }
        set { dateLabel.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.flex.justifyContent(.center).define {
            $0.addItem(nicknameLabel)
            $0.addItem(dateLabel).marginTop(2)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.pin.width(200).height(67)
        self.flex.layout()
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

    public var buttonTitle: String {
        get { return button.titleLabel?.text ?? "" }
        set { button.setTitle(newValue, for: .normal) }
    }

    public var nicknameText: String {
        get { return customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    public var dateText: String {
        get { return customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    public var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        //backgroundColor = .systemBackground

        addSubview(imageView)
        addSubview(customLabelView)
        addSubview(button)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.width(100%).height(67)

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

    public func setup(image: UIImage, nicknameText: String, contentText: String, buttonTitle: String) {
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        //backgroundColor = .systemBackground

        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(dateLabel)

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.pin.width(100%).height(85)

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

    public func setup(withTitle title: String, content: String, date: String) {
        titleLabel.text = title
        contentLabel.text = content
        dateLabel.text = date
    }

    public func resizeText() {
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
    }
}

class CustomCommunityTILView: UIView {
    internal let userView = CustomUserView()
    internal let TILView = CustomTILView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        //backgroundColor = .systemBackground

        TILView.resizeText()

        addSubview(TILView)
        addSubview(userView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.pin.width(100%).height(141)
        TILView.pin.top(54)
    }

}

class CustomBlogView: UIView {

    private let customLabelView = CustomLabelView()
    private let chevronImage = UIImageView(image: UIImage(
        systemName: "chevron.right",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .light)))

    public var blogNameText: String {
        get { return customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    public var blogURLText: String {
        get { return customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        //backgroundColor = .systemBackground

        chevronImage.tintColor = UIColor(named: "AccentColor")
        chevronImage.contentMode = .scaleAspectFit

        addSubview(customLabelView)
        addSubview(chevronImage)

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.pin.width(100%).height(67)

        customLabelView.pin.left(20)
        chevronImage.pin.width(20).height(20).centerRight(20)
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

    required init?(coder: NSCoder) {
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
                y: frame.size.height - 2, width: selectedSegment.frame.width, height: 2)
            bottomBorder.name = "bottomBorder"
            layer.addSublayer(bottomBorder)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.width(100%).height(60)
        updateBottomBorder()
    }
}
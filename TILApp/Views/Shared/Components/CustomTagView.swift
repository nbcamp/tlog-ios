import UIKit

class CustomTagView: UIView {

    var labelText: String {
        get { titleContentLabel.text ?? "" }
        set { titleContentLabel.text = newValue }
    }

    var tags: [String] = [] {
        didSet {
            tagsCollectionView.tags = tags
        }
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
    
    private let tagsCollectionView = HorizontalTagsCollectionView()

    private let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.systemGray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 13)
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
        flex.direction(.column).justifyContent(.spaceBetween).padding(10).height(67).define { flex in
            flex.addItem().direction(.row).grow(1).define {
                $0.addItem(titleLabel).marginRight(10)
                $0.addItem(titleContentLabel).maxWidth(80%)
            }
            flex.addItem().direction(.row).grow(1).define {
                $0.addItem(tagLabel).marginRight(10)
                $0.addItem(tagsCollectionView).width(80%).height(22).marginTop(5)
            }
        }

        addSubview(deleteButton)
        pin.height(67)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.horizontally()
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

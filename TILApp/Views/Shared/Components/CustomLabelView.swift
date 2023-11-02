import UIKit

class CustomLabelView: UIView {
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

    private let nicknameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.sizeToFit()
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .systemGray2
        $0.sizeToFit()
    }

    private let height: CGFloat = 67

    override init(frame: CGRect) {
        super.init(frame: frame)

        flex.justifyContent(.center).define {
            $0.addItem(nicknameLabel)
            $0.addItem(dateLabel).marginTop(2)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.height(height)
        flex.layout()
    }
}

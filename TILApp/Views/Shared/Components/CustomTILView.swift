import UIKit

class CustomTILView: UIView {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18)
    }

    private let contentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .systemGray
        $0.numberOfLines = 2
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor(white: 0.33, alpha: 1.0)
        $0.textAlignment = .right
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        pin.height(85)

        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(dateLabel)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

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

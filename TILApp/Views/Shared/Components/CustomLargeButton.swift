import UIKit

class CustomLargeButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .accent
        layer.cornerRadius = 12
        setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        pin.height(35)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20)
    }
}

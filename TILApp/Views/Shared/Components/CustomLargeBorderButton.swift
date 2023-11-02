import UIKit

class CustomLargeBorderButton: UIButton {
    enum Variant {
        case primary
        case normal
        case other
    }

    var variant: Variant = .other {
        didSet {
            switch variant {
            case .primary:
                setTitle("대표 블로그 ", for: .normal)
                setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                semanticContentAttribute = .forceRightToLeft
                layer.borderWidth = 0
                isEnabled = false
            case .normal:
                setTitle("대표 블로그로 설정하기", for: .normal)
                layer.borderWidth = 0.5
                isEnabled = true
            case .other:
                break
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.accent.cgColor
        layer.cornerRadius = 12
        setTitleColor(.accent, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
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

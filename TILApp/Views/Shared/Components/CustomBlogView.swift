import UIKit

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

    var blogNameText: String {
        get { customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    var blogURLText: String {
        get { customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    private let customLabelView = CustomLabelView()
    private let chevronImage = UIImageView(image: UIImage(
        systemName: "chevron.right",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
    ))
    private let primaryLabel = UILabel().then {
        $0.text = "대표 블로그"
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .accent
        $0.sizeToFit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        chevronImage.tintColor = .accent
        chevronImage.contentMode = .scaleAspectFit

        addSubview(customLabelView)
        addSubview(chevronImage)
        
        pin.height(67)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%)

        chevronImage.pin.width(20).height(20).centerRight(20)
        customLabelView.pin.left(20).before(of: chevronImage).marginRight(70)

        switch variant {
        case .primary:
            primaryLabel.pin.right(to: chevronImage.edge.left).vCenter()
        case .normal:
            primaryLabel.removeFromSuperview()
        }
    }
}

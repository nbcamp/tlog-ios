import UIKit

class CustomTagHeaderView: UIView {

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

        addSubview(label)
        addSubview(line)
        addSubview(button)
        
        pin.height(30)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%)
        label.pin.left(20)
        button.pin.right(20).width(24).height(24)
        line.pin.bottom(to: edge.bottom).horizontally(20).height(0.5)
    }

    func addTargetForButton(target: Any?, action: Selector, for event: UIControl.Event) {
        button.addTarget(target, action: action, for: event)
    }
}

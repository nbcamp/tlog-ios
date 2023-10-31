#if DEBUG

import CombineMoya
import Moya
import UIKit

class BasicView: UIView {
    fileprivate let label = UILabel()

    init(text: String? = nil) {
        super.init(frame: .zero)

        backgroundColor = UIColor(red: 0.58, green: 0.78, blue: 0.95, alpha: 1.00)
        layer.borderColor = UIColor(red: 0.37, green: 0.67, blue: 0.94, alpha: 1.00).cgColor
        layer.borderWidth = 2

        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.sizeToFit()
        addSubview(label)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.pin.center()
    }
}

class BasicButton: UIButton {
    fileprivate let label = UILabel()

    init(text: String? = nil) {
        super.init(frame: .zero)

        backgroundColor = UIColor(red: 0.58, green: 0.78, blue: 0.95, alpha: 1.00)
        layer.borderColor = UIColor(red: 0.37, green: 0.67, blue: 0.94, alpha: 1.00).cgColor
        layer.borderWidth = 2

        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.sizeToFit()
        addSubview(label)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.pin.center()
    }
}

class TestLayoutView: UIView {
    fileprivate let rootFlexContainer = UIView()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white

        let view1 = BasicView(text: "View 1")
        let view2 = BasicView(text: "View 2")
        let view3 = BasicView(text: "View 3")

        rootFlexContainer.flex.justifyContent(.center).padding(10).define { flex in
            flex.addItem(view1).height(40)
            flex.addItem(view2).height(40).marginTop(10)
            flex.addItem(view3).height(40).marginTop(10)
        }

        addSubview(rootFlexContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all(pin.safeArea)
        rootFlexContainer.flex.layout()
    }
}

final class TestLayoutViewController: UIViewController {
    private let rootFlexContainer = UIView()

    private lazy var view1 = BasicView(text: "View 1")

    private lazy var view2 = BasicButton(text: "View 2 (Button)").then { button in
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private lazy var view3 = BasicView(text: "View 3")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(rootFlexContainer)
        rootFlexContainer.flex.padding(10).define { flex in
            flex.addItem(view1).grow(1)
            flex.addItem(view2).grow(0.5).marginTop(10)
            flex.addItem(view3).grow(1).marginTop(10)
        }

        rootFlexContainer.backgroundColor = .systemGreen.withAlphaComponent(0.3)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        rootFlexContainer.pin.horizontally(view.pin.safeArea).top(view.pin.safeArea).height(500)
        rootFlexContainer.flex.layout()
    }

    @objc private func buttonTapped() {
        print("Tapped")
    }
}

#endif

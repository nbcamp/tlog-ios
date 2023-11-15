import UIKit

class CustomTextFieldView: UIView {
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

    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }

    var readOnly: Bool = false {
        didSet {
            textField.isUserInteractionEnabled = !readOnly
            textField.textColor = readOnly ? .systemGray2 : .black
        }
    }

    var textFieldTag: Int = 0 {
        didSet {
            textField.tag = textFieldTag
        }
    }

    private let titleLabel = CustomTitleLabel()
    private let textField = CustomTextField()

    override init(frame: CGRect) {
        super.init(frame: frame)

        flex.define {
            $0.addItem(titleLabel).margin(0, 20).height(24)
            $0.addItem(textField).margin(0, 20).height(40)
        }
        pin.height(64)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textField.autocapitalizationType = .none
        pin.width(100%)
        flex.layout()
    }
}

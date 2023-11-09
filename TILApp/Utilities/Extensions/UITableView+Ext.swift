import UIKit

extension UITableView {
    func applyCustomSeparator() {
        self.separatorStyle = .singleLine
        self.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        self.separatorColor = .systemGray6
    }

    func setPlaceholderText(_ message: String?) {
        guard let message = message else {
            backgroundView = nil
            return
        }

        lazy var messageLabel = UILabel().then {
            $0.text = message
            $0.textColor = .gray
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.sizeToFit()
        }

        let containerView = UIView()
        containerView.addSubview(messageLabel)

        backgroundView = containerView

        messageLabel.pin.top(40%).hCenter()
    }

    func updatePlaceholderIfNeeded(count: Int, placeholderText: String) {
        let placeholder = count == 0 ? placeholderText : nil
        self.setPlaceholderText(placeholder)
    }
}

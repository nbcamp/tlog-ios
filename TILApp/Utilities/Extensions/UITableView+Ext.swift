import UIKit

extension UITableView {
    func applyCustomSeparator() {
        self.separatorStyle = .singleLine
        self.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        self.separatorColor = .systemGray6
    }
}

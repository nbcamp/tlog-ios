import UIKit

final class BlockedUserTableViewCell: UITableViewCell {
    private(set) var customBlockedUserView = CustomBlockedUserView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(customBlockedUserView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        customBlockedUserView.clear()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        customBlockedUserView.pin.horizontally()
    }
}

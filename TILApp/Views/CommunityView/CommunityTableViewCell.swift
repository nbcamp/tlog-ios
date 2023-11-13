import UIKit

final class CommunityTableViewCell: UITableViewCell {
    static let identifier = #function

    private(set) var customCommunityTILView = CustomCommunityTILView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(customCommunityTILView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        customCommunityTILView = CustomCommunityTILView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        customCommunityTILView.pin.horizontally()
    }
}

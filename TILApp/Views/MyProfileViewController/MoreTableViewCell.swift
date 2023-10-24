import FlexLayout
import PinLayout
import Then
import UIKit

class MoreTableViewCell: UITableViewCell {
    let identifier = "MoreCell"

    lazy var iconButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
        let image = UIImage(systemName: "", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFill
        $0.tintColor = .black
        addSubview($0)
    }

    lazy var titleLabel = UILabel().then {
        $0.text = "Your Title"
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.sizeToFit()
        $0.backgroundColor = .clear
        contentView.addSubview($0)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setUpUI() {
        iconButton.pin.top().bottom().left(10).right(80%).marginTop(10)
        titleLabel.pin.after(of: iconButton).top().bottom().right().marginLeft(5).marginTop(10)
    }

    func configure(withTitle title: String, iconName: String) {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
        let image = UIImage(systemName: iconName, withConfiguration: imageConfig)
        iconButton.setImage(image, for: .normal)
        titleLabel.text = title
    }
}

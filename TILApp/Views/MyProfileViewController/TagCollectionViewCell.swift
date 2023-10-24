import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    lazy var tagLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .darkGray
        contentView.addSubview($0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .systemGray5
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tagLabel.pin.horizontally(8).vertically(5)
        print(contentView)
        print(tagLabel)
    }
}

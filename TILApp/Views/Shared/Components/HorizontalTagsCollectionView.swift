import UIKit

final class HorizontalTagsCollectionView:
    UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var tags: [String] = [] {
        didSet {
            reloadData()
        }
    }

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)

        self.dataSource = self
        self.delegate = self
        register(TagCell.self, forCellWithReuseIdentifier: "TagCell")

        self.showsHorizontalScrollIndicator = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath)
            as? TagCell else { return UICollectionViewCell() }
        cell.label.text = tags[indexPath.item]
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let tag = tags[indexPath.item]
        let size = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
        return CGSize(width: size.width + 15, height: 22)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 7
    }
}

class TagCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        label.frame = contentView.bounds
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.textAlignment = .center

        backgroundColor = .systemGray6
        layer.cornerRadius = 8
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        label.pin.vCenter().hCenter()
    }
}

import UIKit

final class HorizontalTagsCollectionView:
    UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var tags: [String] = [] {
        didSet {
            reloadData()
        }
    }
    
    var height: CGFloat = 22
    var radius: CGFloat = 8

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
        cell.text = tags[indexPath.item]
        cell.radius = radius
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let tag = tags[indexPath.item]
        let size = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
        return CGSize(width: size.width + 15, height: height)
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
    var radius: CGFloat = 8 {
        didSet { layer.cornerRadius = radius }
    }
    var text = "" {
        didSet { label.text = text }
    }
    
    private lazy var label = UILabel().then {
        $0.frame = contentView.bounds
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)

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

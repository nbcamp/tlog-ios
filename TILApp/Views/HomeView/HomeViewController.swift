import FlexLayout
import PinLayout
import UIKit

final class HomeViewController: UIViewController {
    let goodJobLabel = {
        let label = UILabel()
        label.text = "대단해요!! 연속 x일 달성"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.sizeToFit()
        label.layer.cornerRadius = 8
        return label
    }()

    let completedTILLabel = {
        let label = UILabel()
        label.text = "오늘의 TIL 작성 완료✅"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.sizeToFit()
        label.layer.cornerRadius = 8
        return label
    }()

    let growthImage = {
        let imageView = UIImageView(image: UIImage(systemName: "pencil"))
        imageView.tintColor = .systemTeal
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 8
        imageView.layer.borderColor = UIColor.systemTeal.cgColor
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpUI()
    }

    func setUpUI() {
        navigationItem.hidesBackButton = true
        view.addSubview(goodJobLabel)
        view.addSubview(completedTILLabel)
        view.addSubview(growthImage)

        goodJobLabel.pin.top(15%).hCenter()
        completedTILLabel.pin.top(21%).hCenter()
        growthImage.pin.top(30%).bottom(20%).left(7.5%).right(7.5%)
    }
}

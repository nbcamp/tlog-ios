import FlexLayout
import PinLayout
import UIKit

final class HomeViewController: UIViewController {
    private var TILPost = [1, 2, 3, 4]
    private var userDidRegisterBlog: Bool = true // 로그인상태
    private var TILComplete: Bool = false // TIL 작성 상태
    private let countTILLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "대단해요!! 연속 x일 달성"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.sizeToFit()
        return label
    }()

    private let completedTILLabel = {
        let label = UILabel()
        label.text = "오늘의 TIL 작성 완료  "
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()

    private let growthImage = {
        let imageView = UIImageView(image: UIImage(named: "1"))
        imageView.tintColor = .systemTeal
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 8
        imageView.layer.borderColor = UIColor.systemTeal.cgColor
        return imageView
    }()

    private let hiLabel = {
        let label = UILabel()
        label.text = "ooo님, 안녕하세요!"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.sizeToFit()
        return label
    }()

    private let registerBlogLabel = {
        let label = UILabel()
        label.text = "블로그를 등록해주세요!"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.sizeToFit()
        return label
    }()

    private let isCompleteImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.layer.borderWidth = 1
//        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.tintColor = .systemTeal

        return imageView
    }()

    private let registerBlogButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("블로그 등록하기", for: .normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemTeal
        button.setBackgroundImage(UIImage(named: "pressedButtonImage"), for: .highlighted)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        registerBlogButton.addTarget(self, action: #selector(registerBlogButtonTapped), for: .touchUpInside)
        configureUI()
        updateCountTILLabel()
        updateGrowthImage()
    }

    private func configureUI() {
        if userDidRegisterBlog {
            setUpUIForRegisteredUser()
        } else {
            setUpUIForUnregisteredUser()
        }
    }

    private func setUpUIForRegisteredUser() {
        navigationItem.hidesBackButton = true
        view.addSubview(countTILLabel)
        view.addSubview(completedTILLabel)
        view.addSubview(growthImage)
        view.addSubview(isCompleteImageView)

        countTILLabel.pin.top(15%).left().right().hCenter()
        completedTILLabel.pin.below(of: countTILLabel).hCenter().marginTop(15).marginRight(25)
        growthImage.pin.top(30%).bottom(20%).left(7.5%).right(7.5%)
        isCompleteImageView.pin.top(20.5%).right(23%).after(of: completedTILLabel).height(30)

        if TILComplete {
            isCompleteImageView.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            isCompleteImageView.image = UIImage(systemName: "x.square")
        }
    }

    private func setUpUIForUnregisteredUser() {
        view.addSubview(registerBlogButton)
        view.addSubview(registerBlogLabel)
        view.addSubview(hiLabel)

        registerBlogButton.pin.left().right().center().marginLeft(20).marginRight(20)
        registerBlogLabel.pin.above(of: registerBlogButton).hCenter().marginBottom(40)
        hiLabel.pin.above(of: registerBlogLabel).hCenter()
    }

    @objc private func registerBlogButtonTapped() {
        print("블로그등록 페이지 뷰전환")

//        let homeViewController = HomeViewController()
//
//        navigationController?.pushViewController(homeViewController, animated: true)
    }

    private func updateCountTILLabel() {
        countTILLabel.text = "대단해요!! 연속 \(TILPost.count)일 달성"
    }
    private func updateGrowthImage() {
        if TILPost.count >= 1 && TILPost.count <= 50 {
            let imageName = "\(TILPost.count / 5 + 1)"
            if let image = UIImage(named: imageName) {
                growthImage.image = image
                print("생성된 이미지 이름은 \(imageName)입니다")
            } else {
                print("Image named '\(imageName)' not found.")
            }
        } else {
            print("TIL count out of range (1 to 10)")
        }
    }
}

import FlexLayout
import PinLayout
import UIKit

final class HomeViewController: UIViewController {
    private var userDidRegisterBlog: Bool = false // 로그인상태
    private var TILComplete: Bool = false // TIL 작성 상태
    private let goodJobLabel = {
        let label = UILabel()
        label.text = "대단해요!! 연속 x일 달성"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.sizeToFit()
        label.layer.cornerRadius = 8
        return label
    }()

    private let completedTILLabel = {
        let label = UILabel()
        label.text = "오늘의 TIL 작성 완료  "
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.sizeToFit()
        label.layer.cornerRadius = 8
        return label
    }()

    private let growthImage = {
        let imageView = UIImageView(image: UIImage(systemName: "pencil")) // 임시 이미지
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
        view.addSubview(goodJobLabel)
        view.addSubview(completedTILLabel)
        view.addSubview(growthImage)
        view.addSubview(isCompleteImageView)

        goodJobLabel.pin.top(15%).hCenter()
        completedTILLabel.pin.top(21%).hCenter(-5%)
        growthImage.pin.top(30%).bottom(20%).left(7.5%).right(7.5%)
        isCompleteImageView.pin.top(20.5%).right(23%).after(of: completedTILLabel).height(30)

        if TILComplete == true {
            isCompleteImageView.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            isCompleteImageView.image = UIImage(systemName: "x.square")
        }
    }

    private func setUpUIForUnregisteredUser() {
        view.addSubview(hiLabel)
        view.addSubview(registerBlogLabel)
        view.addSubview(registerBlogButton)

        hiLabel.pin.hCenter().vCenter(-15%)
        registerBlogLabel.pin.hCenter().vCenter(-10%)
        registerBlogButton.pin.left(7.5%).right(7.5%).center()
    }

    @objc private func registerBlogButtonTapped() {
        print("블로그등록 페이지 뷰전환")

//        let homeViewController = HomeViewController()
//
//        navigationController?.pushViewController(homeViewController, animated: true)
    }
}

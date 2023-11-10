import UIKit

final class HomeViewController: UIViewController {
    private var user: AuthUser? { AuthViewModel.shared.user }

    private var TILPost = [1, 2, 3, 4]
    // TODO: 모델 추가후 변경하기
    private var userDidRegisterBlog: Bool = false // 로그인상태
    private var todayTILComplete: Bool = false // TIL 작성 상태
    private let countTILLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "대단해요!! 연속 x일 달성"
        $0.font = UIFont.boldSystemFont(ofSize: 30)
        $0.sizeToFit()
    }

    private let completedTILLabel = UILabel().then {
        $0.text = "오늘의 TIL 작성 완료  "
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textAlignment = .center
        $0.sizeToFit()
    }

    private let growthImage = UIImageView(image: UIImage(named: "1")).then {
        $0.tintColor = .accent
        $0.layer.borderColor = UIColor.accent.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }

    private let greetingLabel = UILabel().then {
        $0.text = "\(String(describing: AuthViewModel.shared.user?.username))님, 안녕하세요!"
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 24)
        $0.sizeToFit()
    }

    private let registerBlogLabel = UILabel().then {
        $0.text = "블로그를 등록해주세요!"
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 24)
        $0.sizeToFit()
    }

    private let isCompleteImageView = UIImageView().then {
        $0.tintColor = .accent
    }

    private lazy var registerBlogButton = CustomLargeButton().then {
        $0.backgroundColor = .accent
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("블로그 등록하기", for: .normal)
        $0.sizeToFit()
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        $0.setBackgroundImage(UIImage(named: "pressedButtonImage"), for: .highlighted)
        $0.addTarget(self, action: #selector(registerBlogButtonTapped), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        updateCountTILLabel()
        RssViewModel.shared.prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
        if let username = user?.username {
            greetingLabel.text = "\(username)님, 안녕하세요!"
        } else {
            greetingLabel.text = "등록을 위해선 로그인이 필요해요!"
        }
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

        if todayTILComplete {
            isCompleteImageView.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            isCompleteImageView.image = UIImage(systemName: "x.square")
        }
    }

    private func setUpUIForUnregisteredUser() {
        view.addSubview(registerBlogButton)
        view.addSubview(registerBlogLabel)
        view.addSubview(greetingLabel)

        registerBlogButton.pin.center()
        registerBlogLabel.pin.above(of: registerBlogButton).hCenter().marginBottom(40)
        greetingLabel.pin.above(of: registerBlogLabel).hCenter()
    }

    @objc private func registerBlogButtonTapped() {
        let blogRegisterViewController = BlogRegisterViewController()
        blogRegisterViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(blogRegisterViewController, animated: true)
    }

    private func updateCountTILLabel() {
        countTILLabel.text = "대단해요!! 연속 \(TILPost.count)일 달성"
    }
}

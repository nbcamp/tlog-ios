import FlexLayout
import PinLayout
import Then
import UIKit

final class HomeViewController: UIViewController {
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
        if let accentColor = UIColor(named: "AccentColor") {
            $0.tintColor = accentColor
            $0.layer.borderColor = accentColor.cgColor
        }
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }

    private let hiLabel = UILabel().then {
        $0.text = "ooo님, 안녕하세요!"
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
        if let accentColor = UIColor(named: "AccentColor") {
            $0.tintColor = accentColor
        }
    }

    private let registerBlogButton = CustomLargeButton().then {
        if let accentColor = UIColor(named: "AccentColor") {
            $0.backgroundColor = accentColor
        }
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("블로그 등록하기", for: .normal)
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        $0.layer.cornerRadius = 8
        $0.setBackgroundImage(UIImage(named: "pressedButtonImage"), for: .highlighted)
    }

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

        if todayTILComplete {
            isCompleteImageView.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            isCompleteImageView.image = UIImage(systemName: "x.square")
        }
    }

    private func setUpUIForUnregisteredUser() {
        view.addSubview(registerBlogButton)
        view.addSubview(registerBlogLabel)
        view.addSubview(hiLabel)

        registerBlogButton.pin.center()
        registerBlogLabel.pin.above(of: registerBlogButton).hCenter().marginBottom(40)
        hiLabel.pin.above(of: registerBlogLabel).hCenter()
    }

    @objc private func registerBlogButtonTapped() {
        // TODO: 블로그 등록 페이지 추가 후 수정하기
        navigationController?.pushViewController(BlogRegisterViewController(), animated: true)
    }

    private func updateCountTILLabel() {
        countTILLabel.text = "대단해요!! 연속 \(TILPost.count)일 달성"
    }

    private func updateGrowthImage() {
        if TILPost.count >= 1 && TILPost.count <= 50 {
            let imageName = "\(TILPost.count / 5 + 1)"
            if let image = UIImage(named: imageName) {
                growthImage.image = image
            } else {}
        } else {}
    }
}

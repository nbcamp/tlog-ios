import AuthenticationServices
import UIKit

final class SignInViewController: UIViewController {
    private let logoImage = UIImageView(image: UIImage(named: "SignInPageLogo"))
    private let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)

    private let label = UILabel().then {
        $0.text = "간편하게 로그인하고 다양한 서비스를 이용해보세요"
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .white
        $0.sizeToFit()
    }

    private let privacyLabel = UILabel().then {
        $0.text = "회원가입 시 이용 약관 및 개인정보 처리방침에 동의합니다 >"
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .white
        $0.sizeToFit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImage.contentMode = .scaleAspectFill
        view.addSubview(logoImage)

        authorizationButton.cornerRadius = 50
        authorizationButton
            .addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        view.addSubview(authorizationButton)
        view.addSubview(label)
        view.addSubview(privacyLabel)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(privacyLabelTapped))
        privacyLabel.isUserInteractionEnabled = true
        privacyLabel.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.pin.all()
        logoImage.pin.all()
        authorizationButton.pin.hCenter().bottom(12%).width(90%).height(48)
        label.pin.hCenter().bottom(to: authorizationButton.edge.top).marginBottom(17)
        privacyLabel.pin.hCenter().top(to: authorizationButton.edge.bottom).marginTop(8)
    }

    @objc private func handleAuthorizationAppleIDButtonPress() {
        AuthService.shared.signInWithApple(self) { payload in
            AuthViewModel.shared.signIn(.init(
                username: payload.username ?? "이름없음",
                avatarUrl: nil,
                provider: payload.provider,
                providerId: payload.providerId
            )) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    break
                case .failure(let error):
                    debugPrint(#function, error)
                    showAuthFailedAlert()
                }
            }
        } onError: { [weak self] error in
            debugPrint(#function, error)
            self?.showAuthFailedAlert()
        }
    }

    private func showAuthFailedAlert() {
        let alert = UIAlertController(title: "로그인 실패", message: "\n다시 시도해 주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    @objc private func privacyLabelTapped() {
        let webViewController = WebViewController()
        webViewController.url = "https://plucky-fang-eae.notion.site/e951a2d004ac4bbdbee73ee6b8ea4d08"
        webViewController.hidesBottomBarWhenPushed = true
        present(webViewController, animated: true)
    }
}

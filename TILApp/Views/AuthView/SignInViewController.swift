import AuthenticationServices
import UIKit

final class SignInViewController: UIViewController {
    private let logoImage = UIImageView(image: UIImage(named: "SignInPageLogo"))
    private let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)

    private let checkbox = UIButton().then {
        $0.setImage(UIImage(named: "checkbox.unchecked"), for: .normal)
        $0.setImage(UIImage(named: "checkbox.checked"), for: .selected)
        $0.pin.width(16).height(16)
    }

    private lazy var termsLabel = createCustomLabel(text: "이용 약관", isUnderlined: true)
    private lazy var andLabel = createCustomLabel(text: " 및 ")
    private lazy var privacyPolicyLabel = createCustomLabel(text: "개인정보 처리방침", isUnderlined: true)
    private lazy var agreementLabel = createCustomLabel(text: "에 동의합니다.")
    private let checkboxContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImage.contentMode = .scaleAspectFill
        view.addSubview(logoImage)

        authorizationButton.cornerRadius = 50
        authorizationButton
            .addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        authorizationButton.isEnabled = false
        view.addSubview(authorizationButton)

        view.addSubview(checkboxContainerView)
        checkboxContainerView.flex.direction(.row).alignItems(.center).justifyContent(.center).define { flex in
            flex.addItem(checkbox).width(16).height(16)
            flex.addItem(termsLabel).marginLeft(5)
            flex.addItem(andLabel)
            flex.addItem(privacyPolicyLabel)
            flex.addItem(agreementLabel)
        }
        checkboxContainerView.pin.height(20)

        let tapGestureTerms = UITapGestureRecognizer(target: self, action: #selector(openTerms))
        termsLabel.addGestureRecognizer(tapGestureTerms)

        let tapGesturePrivacy = UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicy))
        privacyPolicyLabel.addGestureRecognizer(tapGesturePrivacy)

        checkbox.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.pin.all()
        logoImage.pin.all()
        authorizationButton.pin.hCenter().bottom(17%).width(85%).height(48)
        checkboxContainerView.pin.horizontally().bottom(to: authorizationButton.edge.top).marginBottom(10)

        checkboxContainerView.flex.layout()
    }

    @objc private func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @objc func checkboxTapped() {
        checkbox.isSelected.toggle()
        authorizationButton.isEnabled = checkbox.isSelected
    }

    @objc private func openTerms() {
        let webViewController = WebViewController()
        webViewController.url = "https://plucky-fang-eae.notion.site/e951a2d004ac4bbdbee73ee6b8ea4d08"
        webViewController.hidesBottomBarWhenPushed = true
        present(webViewController, animated: true)
    }

    @objc private func openPrivacyPolicy() {
        let webViewController = WebViewController()
        webViewController.url = "https:plip.kr/pcc/96e3cd8c-700d-46a1-b007-37443c721874/privacy-policy"
        webViewController.hidesBottomBarWhenPushed = true
        present(webViewController, animated: true)
    }

    private func createCustomLabel(text: String, isUnderlined: Bool = false) -> UILabel {
        return UILabel().then {
            if isUnderlined {
                var attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.white,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                $0.attributedText = attributedString
            } else {
                $0.text = text
                $0.font = UIFont.systemFont(ofSize: 14)
                $0.textColor = .white
            }

            $0.isUserInteractionEnabled = isUnderlined
            $0.sizeToFit()
        }
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    // 로그인 성공 후 동작
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName

            var username = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            username = username.trimmingCharacters(in: .whitespacesAndNewlines)

            AuthViewModel.shared.signIn(.init(
                username: username.isEmpty ? nil : username,
                avatarUrl: nil,
                provider: "APPLE",
                providerId: userIdentifier
            )) { [weak self] result in
                guard let self, case .failure = result else { return }
                let alert = UIAlertController(title: "로그인 실패", message: "\n다시 시도해 주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // TODO: 로그인 실패 후 동작
        if let error = error as? ASAuthorizationError, error.code == .canceled {
            DispatchQueue.main.async {
                self.checkbox.isSelected = true
            }
        }
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

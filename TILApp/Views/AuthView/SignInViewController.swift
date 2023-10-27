import AuthenticationServices
import FlexLayout
import PinLayout
import UIKit

final class SignInViewController: UIViewController {
    private let logoImage = UIImageView(image: UIImage(named: "SignInPageLogo"))
    private let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImage.contentMode = .scaleAspectFill
        view.addSubview(logoImage)

        authorizationButton.cornerRadius = 50
        authorizationButton
            .addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        view.addSubview(authorizationButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoImage.pin.all()
        authorizationButton.pin.hCenter().bottom(20%).width(80%).height(44)
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
            let email = appleIDCredential.email

            var username: String?
            if fullName != nil {
                username = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            }

            // MARK: 테스트용

            APIService.shared.request(.signIn(.init(
                username: "user1",
                avatarUrl: "",
                provider: "APPLE",
                providerId: "1234567"
            )), model: SignInOutput.self) { model in
                AuthService.shared.signIn(accessToken: model.accessToken)
                self.dismiss(animated: false)
            } onError: { [weak self] _ in
                guard let self else { return }
                let alert = UIAlertController(title: "로그인 실패", message: "\n다시 시도해 주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

// MARK: 실제 사용할 코드

//            APIService.shared.request(.signIn(.init(
//                username: username,
//                avatarUrl: "",
//                provider: "APPLE",
//                providerId: userIdentifier
//            )), model: SignInOutput.self) { model in
//                print("---")
//                let accessToken = model.accessToken
//                print(accessToken)
//                AuthService.shared.signIn(accessToken: accessToken)
//            } onError: { error in
//                print(error)
//            }

// MARK: 테스트용 출력

//            print("User ID : \(userIdentifier)")
//            print("User Email : \(email)")
//            print("User Name : \(fullName)")

        default:
            break
        }
    }

    // 로그인 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {}
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

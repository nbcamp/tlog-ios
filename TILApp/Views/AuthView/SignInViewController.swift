import UIKit
import AuthenticationServices

final class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setAppleLoginButton()
    }

    private func setAppleLoginButton() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        authorizationButton
            .addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)

        view.addSubview(authorizationButton)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorizationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authorizationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
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

            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
            }

            print("User ID : \(userIdentifier)")
            print("User Email : \(email)")
            print("User Name : \(fullName)")

        default:
            break
        }
    }

    // 로그인 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle Error
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

import AuthenticationServices

final class AuthService: NSObject {
    static let shared: AuthService = .init()
    override private init() {}

    struct ApplePayload {
        let username: String?
        let provider: String
        let providerId: String
    }

    private var target: UIViewController?
    private var onSuccess: ((ApplePayload) -> Void)?
    private var onError: ((Error) -> Void)?

    func signInWithApple(
        _ target: UIViewController,
        onSuccess: @escaping (ApplePayload) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.target = target
        self.onSuccess = onSuccess
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName

            var username: String?
            if let fullName {
                username = "\(fullName.familyName ?? "") \(fullName.givenName ?? "")"
            }

            onSuccess?(.init(
                username: username,
                provider: "APPLE",
                providerId: userIdentifier
            ))
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onError?(error)
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return target!.view.window!
    }
}

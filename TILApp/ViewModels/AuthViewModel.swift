import Foundation

final class AuthViewModel {
    static let shared: AuthViewModel = .init()
    private init() {
        isAuthenticated = UserDefaults.standard.string(forKey: Token.accessToken) != nil
    }

    enum Token {
        static let accessToken = "Access Token"
    }

    var user: AuthUser?

    var accessToken: String? { UserDefaults.standard.string(forKey: Token.accessToken) }
    var authenticated: Bool { accessToken != nil }
    @Published var isAuthenticated: Bool

    func signIn(
        _ input: SignInInput,
        onSuccess: ((_ user: AuthUser) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(.signIn(input), model: SignInOutput.self) { [weak self] model in
            guard let self else { return }
            UserDefaults.standard.set(model.accessToken, forKey: Token.accessToken)
            isAuthenticated = true
            self.user = model.user
            onSuccess?(model.user)
        } onError: { [weak self] error in
            guard let self else { return }
            self.user = nil
            onError?(error)
        }
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: Token.accessToken)
        isAuthenticated = false
        user = nil
    }
}

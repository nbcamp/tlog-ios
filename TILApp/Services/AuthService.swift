import Foundation

final class AuthService {
    static let shared: AuthService = .init()
    private init() {}

    enum Token {
        static let accessToken = "Access Token"
    }

    var accessToken: String? { UserDefaults.standard.string(forKey: Token.accessToken) }

    func signIn(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Token.accessToken)
    }

    func signOut(accessToken: String) {
        UserDefaults.standard.removeObject(forKey: Token.accessToken)
    }
}

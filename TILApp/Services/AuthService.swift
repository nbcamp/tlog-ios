import Combine
import Foundation

final class AuthService {
    static let shared: AuthService = .init()
    private init() {
        isAuthenticated = UserDefaults.standard.string(forKey: Token.accessToken) != nil
    }

    enum Token {
        static let accessToken = "Access Token"
    }

    var accessToken: String? { UserDefaults.standard.string(forKey: Token.accessToken) }
    var authenticated: Bool { accessToken != nil }
    @Published var isAuthenticated: Bool

    func signIn(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Token.accessToken)
        isAuthenticated = true
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: Token.accessToken)
        isAuthenticated = false
    }
}

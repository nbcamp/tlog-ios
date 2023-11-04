import Foundation

final class AuthViewModel {
    static let shared: AuthViewModel = .init()
    private init() {}
    
    private let api = APIService.shared

    enum Token {
        static let accessToken = "Access Token"
    }

    private(set) var user: AuthUser?

    var accessToken: String? { UserDefaults.standard.string(forKey: Token.accessToken) }
    var authenticated: Bool { accessToken != nil }
    @Published var isAuthenticated: Bool = false

    func checkAuthorization(_ handler: APIHandler<AuthUser>? = nil) {
        print(#function)
        api.request(.getMyProfile, to: AuthUser.self) { [unowned self] result in
            if case let .success(model) = result {
                user = model
                isAuthenticated = true
            } else {
                user = nil
                isAuthenticated = false
            }
            handler?(result)
        }
    }

    func signIn(_ input: SignInInput, _ handler: @escaping APIHandler<SignInOutput>) {
        print(#function)
        api.request(.signIn(input), to: SignInOutput.self) { [unowned self] result in
            if case let .success(model) = result {
                UserDefaults.standard.set(model.accessToken, forKey: Token.accessToken)
                isAuthenticated = true
                user = model.user
            } else {
                isAuthenticated = false
                user = nil
            }
            handler(result)
        }
    }

    func signOut() {
        print(#function)
        UserDefaults.standard.removeObject(forKey: Token.accessToken)
        isAuthenticated = false
        user = nil
    }

    func update(_ input: UpdateUserInput, _ handler: @escaping APIHandler<AuthUser>) {
        api.request(.updateMyProfile(input), to: AuthUser.self) { [unowned self] result in
            if case let .success(model) = result {
                user = model
            } else {
                isAuthenticated = false
                user = nil
            }
            handler(result)
        }
    }

    func withdraw(_ handler: (() -> Void)? = nil) {
        api.request(.withdrawMe) { [unowned self] _ in
            signOut()
            handler?()
        }
    }
}

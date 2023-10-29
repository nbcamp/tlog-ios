struct AuthUser: Codable {
    let id: Int
    let username: String
    let avatarUrl: String?
    let posts: Int
    let followers: Int
    let followings: Int
}

struct SignInInput: Codable {
    let username: String?
    let avatarUrl: String?
    let provider: String
    let providerId: String
}

struct SignInOutput: Codable {
    let accessToken: String
    let user: AuthUser
}

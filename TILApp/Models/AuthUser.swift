struct AuthUser: Codable {
    let id: Int
    let username: String
    let profileUrl: String
}

struct SignInInput: Codable {
    let username: String
    let avatarUrl: String?
    let provider: String
    let providerId: String
}

struct SignInOutput: Codable {
    let accessToken: String
}

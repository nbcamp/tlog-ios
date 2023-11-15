import Foundation

struct AuthUser: Codable {
    let id: Int
    let username: String
    let avatarUrl: String?
    let posts: Int
    let followers: Int
    let followings: Int
    let hasBlog: Bool
    let lastPublishedAt: Date?
    let isAgreed: Bool?
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

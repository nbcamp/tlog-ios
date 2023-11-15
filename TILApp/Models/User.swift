import Foundation

struct User: Codable {
    let id: Int
    let username: String
    let avatarUrl: String?
    let posts: Int
    let followers: Int
    let followings: Int
    let lastPublishedAt: Date?
    let hasBlog: Bool
    let isMyFollower: Bool
    let isMyFollowing: Bool
}

struct BlockedUser: Codable {
    let id: Int
    let username: String
    let avatarUrl: String?
}

struct UpdateUserInput: Codable {
    let username: String
    let avatarUrl: String?
    let isAgreed: Bool?
}

struct ReportUserInput: Codable {
    let reason: String
}

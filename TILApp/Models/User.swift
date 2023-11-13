import Foundation

struct User: Codable {
    let id: Int
    let username: String
    let avatarUrl: String
    let posts: Int
    let followers: Int
    let followings: Int
    let lastPublishedAt: Date?
    let hasBlog: Bool
    let isMyFollower: Bool
    let isMyFollowing: Bool
}

struct UpdateUserInput: Codable {
    let username: String
    let avatarUrl: String?
}

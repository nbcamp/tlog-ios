struct User: Codable {
    let id: Int
    let username: String?
    let avatarUrl: String?
    let posts: Int
    let followers: Int
    let followings: Int
}

struct UpdateUserInput: Codable {
    let username: String
    let avatarUrl: String?
}

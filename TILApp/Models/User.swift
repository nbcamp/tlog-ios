struct User: Codable {
    let id: Int
    let username: String
    let avatarUrl: String?
}

struct UpdateUserInput: Codable {
    let username: String
    let avatarUrl: String?
}

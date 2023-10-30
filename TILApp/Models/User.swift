struct User: Codable, Equatable {
    let id: Int
    let username: String
    let avatarUrl: String?
    let posts: Int
    let followers: Int
    let followings: Int

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UpdateUserInput: Codable {
    let username: String
    let avatarUrl: String?
}

struct CommunityPost: Codable {
    let post: Post
    let user: User
}

struct GetCommunityQuery {
    let q: String?
    let limit: Int?
    let cursor: Int?
    let desc: Bool?
}

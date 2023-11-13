import Moya

final class UserViewModel {
    static let shared: UserViewModel = .init()
    private init() {}

    private let api = APIService.shared

    private(set) var myFollowers: [User] = []
    private(set) var myFollowings: [User] = []

    func withProfile(user: User, _ handler: @escaping APIHandler<User>) {
        api.request(.getUserProfile(user.id), to: User.self, handler)
    }

    func follow(user: User, _ handler: @escaping APIHandler<User>) {
        api.request(.followUser(user.id), to: User.self) { [unowned self] result in
            switch result {
            case .success(let updatedUser):
                if let index = myFollowings.firstIndex(where: { $0.id == user.id }) {
                    myFollowings[index] = updatedUser
                } else {
                    myFollowings.append(updatedUser)
                }
                handler(.success(updatedUser))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    func unfollow(user: User, _ handler: @escaping APIHandler<User>) {
        api.request(.unfollowUser(user.id), to: User.self) { [unowned self] result in
            switch result {
            case .success(let updatedUser):
                if let index = myFollowings.firstIndex(where: { $0.id == user.id }) {
                    myFollowings.remove(at: index)
                }
                handler(.success(updatedUser))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    func withMyFollowers(_ handler: @escaping APIHandler<[User]>) {
        api.request(.getMyFollowers, to: [User].self) { [unowned self] result in
            if case .success(let model) = result {
                myFollowers = model
            }
            handler(result)
        }
    }

    func withMyFollowings(_ handler: @escaping APIHandler<[User]>) {
        api.request(.getMyFollowings, to: [User].self) { [unowned self] result in
            if case .success(let model) = result {
                myFollowings = model
            }
            handler(result)
        }
    }

    func isMyFollowing(user: User) -> Bool {
        return myFollowings.contains(where: { $0.id == user.id })
    }

    func withMyBlockedUsers(_ handler: @escaping APIHandler<[BlockedUser]>) {
        api.request(.getMyBlockedUsers, to: [BlockedUser].self, handler)
    }

    func blockUser(user: User, _ handler: @escaping APIHandler<BlockedUser>) {
        api.request(.blockUser(user.id), to: BlockedUser.self, handler)
    }

    func unblockUser(user: BlockedUser, _ handler: @escaping APIHandler<BlockedUser>) {
        api.request(.unblockUser(user.id), to: BlockedUser.self, handler)
    }

    func reportUser(user: User, reason: String, _ handler: @escaping APIHandler<Response>) {
        api.request(.reportUser(user.id, .init(reason: reason)), handler)
    }
}

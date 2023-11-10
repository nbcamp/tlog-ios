final class UserViewModel {
    static let shared: UserViewModel = .init()
    private init() {}

    private let api = APIService.shared

    private(set) var myFollowers: [User] = []
    private(set) var myFollowings: [User] = []

    func withProfile(user: User, _ handler: @escaping APIHandler<User>) {
        api.request(.getUserProfile(user.id), to: User.self, handler)
    }

    func follow(user: User, _ handler: @escaping APIHandler<Bool>) {
        api.request(.followUser(user.id)) { [unowned self] result in
            switch result {
            case .success:
                myFollowings.append(user)
                handler(.success(true))
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }

    func unfollow(user: User, _ handler: @escaping APIHandler<Bool>) {
        api.request(.unfollowUser(user.id)) { [unowned self] result in
            switch result {
            case .success:
                if let index = myFollowings.firstIndex(where: { $0.id == user.id }) {
                    myFollowings.remove(at: index)
                    handler(.success(true))
                } else {
                    handler(.success(false))
                }
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }

    func withMyFollowers(_ handler: @escaping APIHandler<[User]>) {
        api.request(.getMyFollowers, to: [User].self) { [unowned self] result in
            if case let .success(model) = result {
                myFollowers = model
            }
            handler(result)
        }
    }

    func withMyFollowings(_ handler: @escaping APIHandler<[User]>) {
        api.request(.getMyFollowings, to: [User].self) { [unowned self] result in
            if case let .success(model) = result {
                myFollowings = model
            }
            handler(result)
        }
    }

    func isMyFollowing(user: User) -> Bool {
        return myFollowings.contains(where: { $0.id == user.id })
    }
}

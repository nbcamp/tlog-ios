final class UserViewModel {
    static let shared: UserViewModel = .init()
    private init() {}

    private(set) var followers: [User] = []
    private(set) var followings: [User] = []

    func find(
        by userId: Int,
        onSuccess: ((_ user: User) -> Void)? = nil,
        onError: ((_ error: Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .getUser(userId),
            model: User.self,
            onSuccess: onSuccess,
            onError: onError
        )
    }

    func follow(
        to userId: Int,
        onSuccess: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .followUser(userId),
            onSuccess: { [weak self] _ in
                guard let self else { return }
                UserViewModel.shared.find(by: userId) { [weak self] user in
                    guard let self else { return }
                    self.followings.append(user)
                    onSuccess?()
                }
            },
            onError: onError
        )
    }

    func unfollow(
        to userId: Int,
        onSuccess: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .unfollowUser(userId),
            onSuccess: { [weak self] _ in
                if let index = self?.followings.firstIndex(where: { $0.id == userId }) {
                    self?.followings.remove(at: index)
                    onSuccess?()
                }
            },
            onError: onError
        )
    }

    func withFollowers(
        onSuccess: ((_ followers: [User]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .getFollowers,
            model: [User].self,
            onSuccess: { [weak self] model in
                guard let self else { return }
                followers = model
                onSuccess?(model)
            },
            onError: onError
        )
    }

    func withFollowings(
        onSuccess: ((_ followings: [User]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .getFollowings,
            model: [User].self,
            onSuccess: { [weak self] model in
                guard let self else { return }
                followings = model
                onSuccess?(model)
            },
            onError: onError
        )
    }

    func isFollowed(user: User) -> Bool {
        return followings.contains(where: { $0 == user })
    }
}

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
            onSuccess: { _ in onSuccess?() },
            onError: onError
        )
    }

    func unfollow(
        to userId: Int,
        onSuccess: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .followUser(userId),
            onSuccess: { _ in onSuccess?() },
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
            onSuccess: onSuccess,
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
            onSuccess: onSuccess,
            onError: onError
        )
    }
}

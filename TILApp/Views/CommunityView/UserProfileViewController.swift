import UIKit

protocol UserProfileViewControllerDelegate: AnyObject {
    func userBlocked(_ viewController: UserProfileViewController)
}

final class UserProfileViewController: UIViewController {
    var user: User? {
        didSet {
            guard let user else { return }
            nicknameLabel.text = user.username
            profileImageView.url = user.avatarUrl
            doingFollowButton.variant = user.isMyFollowing ? .unfollow : .follow
            postButton.setTitle("\(user.posts)\n포스트", for: .normal)
            followersButton.setTitle("\(user.followers)\n팔로워", for: .normal)
            followingButton.setTitle("\(user.followings)\n팔로잉", for: .normal)
        }
    }

    weak var delegate: UserProfileViewControllerDelegate?

    private enum Section {
        case posts, likedPosts
    }

    private var section: Section {
        userSegmentedControl.selectedSegmentIndex == 0 ? .posts : .likedPosts
    }

    private var posts: [Post] = []
    private var likedPosts: [CommunityPost] = []

    private lazy var screenView = UIView().then {
        view.addSubview($0)
    }

    private lazy var countView = UIView()
    private lazy var followButtonView = UIView().then {
        view.addSubview($0)
    }

    private lazy var profileImageView = AvatarImageView()

    private lazy var nicknameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.text = "\(user?.username ?? "")"
        $0.sizeToFit()
    }

    private lazy var moreButton = UIButton().then {
        $0.sizeToFit()
        $0.tintColor = .accent
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 25)
        $0.showsMenuAsPrimaryAction = true
        $0.menu = makeMenuItems()
        view.addSubview($0)
    }

    private lazy var postButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.black, for: .normal)
    }

    private lazy var followersButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.black, for: .normal)
    }

    private lazy var followingButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.black, for: .normal)
    }

    private lazy var doingFollowButton = CustomFollowButton().then {
        $0.setTitle("팔로우", for: .normal)
        $0.backgroundColor = .accent
    }

    private lazy var userBlogURL = UIButton().then {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.titleLabel?.textAlignment = .left
        $0.setTitleColor(.systemGray, for: .normal)
        $0.addTarget(self, action: #selector(blogURLTapped), for: .touchUpInside)
        $0.titleLabel?.lineBreakMode = .byTruncatingTail
        $0.contentHorizontalAlignment = .left
    }

    private lazy var userSegmentedControl = CustomSegmentedControl(items: ["작성한 글", "좋아요한 글"]).then {
        view.addSubview($0)
        $0.addTarget(self, action: #selector(userSegmentedControlSelected(_:)), for: .valueChanged)
    }

    private lazy var userProfileTableView = UITableView().then {
        $0.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        $0.register(CommunityTableViewCell.self, forCellReuseIdentifier: CommunityTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.refreshControl = UIRefreshControl()
        $0.applyCustomSeparator()
        view.addSubview($0)
    }

    private lazy var placeholderLabel = UILabel().then {
        $0.text = "등록한 게시글이 없어요."
        $0.textColor = .systemGray3
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }

    private lazy var placeholderView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.flex.alignItems(.center).define { flex in
            flex.addItem(placeholderLabel).marginTop(80)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if let userId = user?.id {
            APIService.shared.request(.getUserMainBlog(userId), to: Blog.self) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(blog):
                    userBlogURL.setTitle(blog.url, for: .normal)
                case .failure:
                    userBlogURL.setTitle("메인 블로그가 없습니다.", for: .normal)
                }
            }
        }

        loadPosts { [weak self] in
            self?.userProfileTableView.reloadData()
        }

        screenView.flex.direction(.column).define { flex in
            flex.addItem().direction(.row).padding(10).define { flex in
                flex.addItem(profileImageView).width(100).height(100).cornerRadius(100 / 2)
                flex.addItem().direction(.column).width(200).define { flex in
                    flex.addItem(nicknameLabel).width(200).height(25).marginLeft(15).marginTop(5)
                    flex.addItem(countView).direction(.row).width(210).height(75).define { flex in
                        flex.addItem(postButton).width(75)
                        flex.addItem(followersButton).width(75)
                        flex.addItem(followingButton).width(75)
                    }
                }
            }
            flex.addItem(followButtonView).direction(.row).marginTop(10).paddingHorizontal(15).define { flex in
                flex.addItem(doingFollowButton).width(100).height(30)
                flex.addItem(userBlogURL).marginBottom(20).marginLeft(10).grow(1)
            }
            flex.addItem(userSegmentedControl).height(40)
            flex.addItem(userProfileTableView).grow(1)
        }

        doingFollowButton.buttonTapped = { [weak self] in
            guard let self, let user else { return }
            switch doingFollowButton.variant {
            case .follow:
                UserViewModel.shared.follow(user: user) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case let .success(user):
                        CommunityViewModel.shared.updatePosts(forUser: user)
                        self.user = user
                    case let .failure(error):
                        // Error 처리
                        debugPrint(error)
                    }
                }
            case .unfollow:
                UserViewModel.shared.unfollow(user: user) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case let .success(user):
                        CommunityViewModel.shared.updatePosts(forUser: user)
                        self.user = user
                    case let .failure(error):
                        // Error 처리
                        debugPrint(error)
                    }
                }
            default:
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        syncUser()

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        screenView.pin.all(view.pin.safeArea)
        moreButton.pin.top(view.pin.safeArea).right(25)
        screenView.flex.layout()
    }

    private func makeMenuItems() -> UIMenu {
        let reportAction = UIAction(title: "차단하기", image: UIImage(systemName: "eye.slash")) { [weak self] _ in
            guard let self, let user else { return }
            UserViewModel.shared.blockUser(user: user) { [weak self] _ in
                let alertController = UIAlertController(title: "차단 완료", message: "차단되었습니다.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        delegate?.userBlocked(self)
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                self?.present(alertController, animated: true)
            }
        }

        let reportSpamAction = UIAction(
            title: "신고하기",
            image: UIImage(systemName: "flag.fill"),
            attributes: .destructive
        ) { [weak self] _ in
            let alertController = UIAlertController(title: "신고하기", message: "신고 사유를 입력해주세요", preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = "ex) 부적절한 게시물을 올려요."
            }

            let submitAction = UIAlertAction(title: "제출", style: .default) { [weak self] _ in
                guard let self, let user, let reason = alertController.textFields?.first?.text else { return }
                UserViewModel.shared.reportUser(user: user, reason: reason) { [weak self] _ in
                    let alertController = UIAlertController(
                        title: "신고 완료",
                        message: "신고 처리되었습니다.",
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alertController, animated: true)
                }
            }
            alertController.addAction(submitAction)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

            guard let self else { return }
            self.present(alertController, animated: true, completion: nil)
        }

        return UIMenu(children: [reportAction, reportSpamAction])
    }

    @objc private func blogURLTapped() {
        if let blogURL = userBlogURL.title(for: .normal) {
            let webViewController = WebViewController().then {
                $0.hidesBottomBarWhenPushed = true
                $0.url = blogURL
            }
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }

    @objc private func userSegmentedControlSelected(_: CustomSegmentedControl) {
        loadPosts { [weak self] in
            self?.userProfileTableView.reloadData()
        }
    }

    private func loadPosts(_ completion: @escaping () -> Void) {
        guard let user else { return }
        switch section {
        case .posts:
            PostViewModel.shared.withUserPosts(user: user) { [weak self] result in
                guard let self, case let .success(posts) = result else { return }
                self.posts = posts
                completion()
            }
        case .likedPosts:
            PostViewModel.shared.withUserLikedPosts(user: user) { [weak self] result in
                guard let self, case let .success(posts) = result else { return }
                self.likedPosts = posts
                completion()
            }
        }
    }

    private func syncUser() {
        guard let user else { return }
        UserViewModel.shared.withProfile(user: user) { [weak self] result in
            guard let self, case let .success(user) = result else { return }
            self.user = user
        }
    }
}

extension UserProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        var count = 0
        switch section {
        case .posts:
            placeholderLabel.text = "등록한 게시글이 없어요."
            tableView.backgroundView = posts.count == 0 ? placeholderView : nil
            count = posts.count
        case .likedPosts:
            placeholderLabel.text = "좋아요한 게시글이 없어요."
            tableView.backgroundView = likedPosts.count == 0 ? placeholderView : nil
            count = likedPosts.count
        }
        if tableView.backgroundView != nil {
            placeholderLabel.sizeToFit()
            placeholderLabel.flex.markDirty()
            placeholderView.flex.layout()
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section {
        case .posts:
            let post = posts[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserTableViewCell.identifier
            ) as? UserTableViewCell else { return UITableViewCell() }
            cell.userTILView.setup(withTitle: post.title, content: post.content, date: post.publishedAt.format())
            cell.selectionStyle = .none
            return cell
        case .likedPosts:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommunityTableViewCell.identifier
            ) as? CommunityTableViewCell else { return UITableViewCell() }
            let post = likedPosts[indexPath.row]
            cell.customCommunityTILView.setup(post: post)

            cell.customCommunityTILView.userProfileTapped = { [weak self] in
                guard let self, let authUser = AuthViewModel.shared.user,
                      post.user.id != authUser.id, post.user.id != self.user?.id else { return }
                let userProfileViewController = UserProfileViewController()
                userProfileViewController.user = post.user
                navigationController?.pushViewController(userProfileViewController, animated: true)
            }

            cell.customCommunityTILView.postTapped = { [weak self] in
                guard let self else { return }
                let webViewController = WebViewController()
                webViewController.url = post.url
                let likeButton = LikeButton(liked: post.liked)
                likeButton.buttonTapped = { liked, completion in
                    CommunityViewModel.shared.togglePostLikeState(liked, of: post.id) { [weak self] state in
                        guard let self else { return }
                        // TODO: ViewModel class로 변경
                        let post = likedPosts[indexPath.row]
                        likedPosts[indexPath.row] = .init(
                            id: post.id,
                            title: post.title,
                            content: post.content,
                            url: post.url,
                            tags: post.tags,
                            user: post.user,
                            liked: state,
                            publishedAt: post.publishedAt
                        )
                        userProfileTableView.reloadRows(at: [indexPath], with: .none)
                        CommunityViewModel.shared.updatePosts(forPost: post.id)
                        completion(state)
                    }
                }
                webViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)

                webViewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(webViewController, animated: true)
            }
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        switch section {
        case .posts: return 85
        case .likedPosts: return 180
        }
    }
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard section == .posts else { return }
        let post = posts[indexPath.row]
        let likeButton = LikeButton(liked: post.liked).then {
            $0.buttonTapped = { liked, completion in
                CommunityViewModel.shared.togglePostLikeState(liked, of: post.id) { [weak self] state in
                    guard let self else { return }
                    // TODO: ViewModel class로 변경
                    let post = posts[indexPath.row]
                    posts[indexPath.row] = .init(
                        id: post.id,
                        userId: post.userId,
                        title: post.title,
                        content: post.content,
                        url: post.url,
                        tags: post.tags,
                        liked: state,
                        publishedAt: post.publishedAt
                    )
                    CommunityViewModel.shared.updatePosts(forPost: post.id)
                    completion(state)
                }
            }
        }
        let webViewController = WebViewController().then {
            $0.navigationItem.rightBarButtonItem = .init(customView: likeButton)
            $0.url = posts[indexPath.row].url
            $0.hidesBottomBarWhenPushed = true
        }
        navigationController?.pushViewController(webViewController, animated: true)
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        guard let refreshControl = userProfileTableView.refreshControl, refreshControl.isRefreshing else { return }
        loadPosts { [weak self] in
            self?.userProfileTableView.reloadData()
            self?.userProfileTableView.refreshControl?.endRefreshing()
        }
    }
}

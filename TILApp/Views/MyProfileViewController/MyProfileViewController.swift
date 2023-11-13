import UIKit

final class MyProfileViewController: UIViewController {
    private enum Section {
        case myPosts, myLikedPosts
    }

    private let authViewModel = AuthViewModel.shared
    private var authUser: AuthUser? {
        didSet {
            nicknameLabel.text = authUser?.username
            profileImageView.url = authUser?.avatarUrl
            followersButton.setTitle("\(authUser?.followers ?? 0)\n팔로워", for: .normal)
            followingButton.setTitle("\(authUser?.followings ?? 0)\n팔로잉", for: .normal)
        }
    }

    private var section: Section {
        myProfileSegmentedControl.selectedSegmentIndex == 0 ? .myPosts : .myLikedPosts
    }

    private var myPosts: [Post] { PostViewModel.shared.myPosts }
    private var myLikedPosts: [CommunityPost] { PostViewModel.shared.myLikedPosts }

    private lazy var screenView = UIView().then {
        view.addSubview($0)
    }

    private lazy var countView = UIView().then { _ in
    }

    private lazy var profileImageView = AvatarImageView()

    private lazy var nicknameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.text = authUser?.username
        $0.sizeToFit()
    }

    private lazy var moreButton = UIButton().then {
        $0.sizeToFit()
        $0.tintColor = .accent
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 25)
        $0.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        view.addSubview($0)
    }

    private lazy var postButton = UIButton().then {
        $0.sizeToFit()
        $0.setTitle("\(authUser?.posts ?? 0)\n작성글", for: .normal)
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
        $0.setTitle("\(authUser?.followers ?? 0)\n팔로워", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
    }

    private lazy var followingButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitle("\(authUser?.followings ?? 0)\n팔로잉", for: .normal)
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
    }

    private lazy var editBlogButton = CustomLargeButton().then {
        $0.sizeToFit()
        $0.backgroundColor = .accent
        $0.setTitle("블로그 관리", for: .normal)
        $0.layer.cornerRadius = 8
        view.addSubview($0)
        $0.addTarget(self, action: #selector(editBlogButtonTapped), for: .touchUpInside)
    }

    private lazy var myProfileSegmentedControl = CustomSegmentedControl(items: ["작성한 글", "좋아요한 글"]).then {
        view.addSubview($0)
        $0.addTarget(self, action: #selector(myProfileSegmentedControlSelected(_:)), for: .valueChanged)
    }

    private lazy var myProfileTableView = UITableView().then {
        $0.register(MyProfileTableViewCell.self, forCellReuseIdentifier: MyProfileTableViewCell.identifier)
        $0.register(CommunityTableViewCell.self, forCellReuseIdentifier: CommunityTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
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

        loadMyPosts { [weak self] in
            self?.myProfileTableView.reloadData()
            self?.myProfileTableView.setNeedsLayout()
        }

        screenView.flex.direction(.column).define { flex in
            flex.addItem().direction(.row).paddingVertical(10).paddingHorizontal(20).define { flex in
                flex.addItem(profileImageView).width(100).height(100).cornerRadius(100 / 2)
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(nicknameLabel).marginLeft(15).marginTop(10)
                    flex.addItem(countView).direction(.row).width(210).height(75).define { flex in
                        flex.addItem(postButton).width(70)
                        flex.addItem(followersButton).width(70)
                        flex.addItem(followingButton).width(70)
                    }.layout()
                }
            }
            flex.addItem(editBlogButton).height(40)
            flex.addItem(myProfileSegmentedControl).height(40).marginTop(10)
            flex.addItem(myProfileTableView).grow(1)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAuthUser()
        navigationController?.setNavigationBarHidden(true, animated: true)
        WKWebViewWarmer.shared.prepare(3)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WKWebViewWarmer.shared.clear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        screenView.pin.all(view.pin.safeArea)
        moreButton.pin.top(view.pin.safeArea).right(25).marginTop(5)
        screenView.flex.layout()
    }

    @objc private func moreButtonTapped() {
        let vc = SeeMoreBottomSheetViewController()
        vc.delegate = self
        present(vc, animated: true)
    }

    @objc private func followersButtonTapped() {
        let vc = FollowListViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.selectedIndex = 0
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func followingButtonTapped() {
        let vc = FollowListViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.selectedIndex = 1
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func editBlogButtonTapped() {
        let blogListViewController = BlogListViewController()
        blogListViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(blogListViewController, animated: true)
    }

    @objc func myProfileSegmentedControlSelected(_: CustomSegmentedControl) {
        loadMyPosts { [weak self] in
            self?.myProfileTableView.reloadData()
            self?.myProfileTableView.setNeedsLayout()
        }
    }

    private func loadMyPosts(_ completion: @escaping () -> Void) {
        switch section {
        case .myPosts:
            PostViewModel.shared.withMyPosts { _ in completion() }
        case .myLikedPosts:
            PostViewModel.shared.withMyLikedPosts { _ in completion() }
        }
    }

    func updateAuthUser() {
        authUser = authViewModel.user
        authViewModel.profile { [weak self] result in
            guard case let .success(authUser) = result else { return }
            self?.authUser = authUser
            if self?.section == .myLikedPosts {
                self?.loadMyPosts { [weak self] in
                    self?.myProfileTableView.reloadData()
                    self?.myProfileTableView.setNeedsLayout()
                }
            }
        }
    }
}

extension MyProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        var count = 0
        switch section {
        case .myPosts:
            placeholderLabel.text = "등록한 게시글이 없어요."
            tableView.backgroundView = myPosts.count == 0 ? placeholderView : nil
            count = myPosts.count
        case .myLikedPosts:
            placeholderLabel.text = "좋아요한 게시글이 없어요."
            tableView.backgroundView = myLikedPosts.count == 0 ? placeholderView : nil
            count = myLikedPosts.count
        }
        placeholderLabel.sizeToFit()
        placeholderLabel.flex.markDirty()
        placeholderView.flex.layout()
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch section {
        case .myPosts:
            let post = myPosts[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MyProfileTableViewCell.identifier
            ) as? MyProfileTableViewCell else { return UITableViewCell() }
            cell.myTILView.setup(withTitle: post.title, content: post.content, date: post.publishedAt.format())
            cell.selectionStyle = .none
            return cell
        case .myLikedPosts:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommunityTableViewCell.identifier
            ) as? CommunityTableViewCell else { return UITableViewCell() }
            let post = myLikedPosts[indexPath.row]
            cell.customCommunityTILView.setup(post: post)

            cell.customCommunityTILView.userProfileTapped = { [weak self] in
                guard let self, let authUser = AuthViewModel.shared.user, post.user.id != authUser.id else { return }
                let userProfileViewController = UserProfileViewController()
                userProfileViewController.user = post.user
                userProfileViewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(userProfileViewController, animated: true)
            }

            cell.customCommunityTILView.postTapped = { [weak self] in
                guard let self else { return }
                let likeButton = LikeButton(liked: post.liked)
                likeButton.buttonTapped = { (liked: Bool, completion: @escaping () -> Void) in
                    APIService.shared.request(liked ? .unlikePost(post.id) : .likePost(post.id)) { result in
                        guard case .success = result else { return }
                        completion()
                    }
                }
                let webViewController = WebViewController(webView: WKWebViewWarmer.shared.dequeue()).then {
                    $0.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
                    $0.hidesBottomBarWhenPushed = true
                    $0.url = post.url
                }
                navigationController?.pushViewController(webViewController, animated: true)
            }
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        switch section {
        case .myPosts: return 85
        case .myLikedPosts: return 180
        }
    }
}

extension MyProfileViewController: UITableViewDelegate {}

extension MyProfileViewController: SeeMoreBottomSheetDelegate {
    func didSelectSeeMoreMenu(title: String) {
        if title == "회원 정보 수정" {
            let profileEditViewController = ProfileEditViewController()
            profileEditViewController.hidesBottomBarWhenPushed = true
            profileEditViewController.username = authUser?.username ?? ""
            profileEditViewController.avatarImage = profileImageView.image
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.pushViewController(profileEditViewController, animated: true)
            }
        } else if title == "자주 묻는 질문" {
            let webViewController = WebViewController(webView: WKWebViewWarmer.shared.dequeue()).then {
                $0.url = "https://plucky-fang-eae.notion.site/60fa16788e784e69a2a9cc609bd1d781"
                $0.hidesBottomBarWhenPushed = true
            }
            navigationController?.pushViewController(webViewController, animated: true)
            dismiss(animated: true)
        } else if title == "이용 약관" {
            let webViewController = WebViewController(webView: WKWebViewWarmer.shared.dequeue()).then {
                $0.url = "https://plucky-fang-eae.notion.site/e951a2d004ac4bbdbee73ee6b8ea4d08"
                $0.hidesBottomBarWhenPushed = true
            }
            navigationController?.pushViewController(webViewController, animated: true)
            dismiss(animated: true)
        } else if title == "개인 정보 처리 방침" {
            let webViewController = WebViewController(webView: WKWebViewWarmer.shared.dequeue()).then {
                $0.url = "https:plip.kr/pcc/96e3cd8c-700d-46a1-b007-37443c721874/privacy-policy"
                $0.hidesBottomBarWhenPushed = true
            }
            navigationController?.pushViewController(webViewController, animated: true)
            dismiss(animated: true)
        } else if title == "차단한 사용자 관리" {
            let blockedUserViewController = BlockedUserViewController()
            blockedUserViewController.hidesBottomBarWhenPushed = true
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.pushViewController(blockedUserViewController, animated: true)
            }
        } else if title == "로그아웃" {
            let alertController = UIAlertController(title: "로그아웃", message: "정말 로그아웃하시겠어요?", preferredStyle: .alert)
            alertController.addAction(.init(title: "계속", style: .destructive, handler: { _ in
                AuthViewModel.shared.signOut()
            }))
            alertController.addAction(.init(title: "취소", style: .cancel))
            topMostViewController.present(alertController, animated: true)
        }
    }
}

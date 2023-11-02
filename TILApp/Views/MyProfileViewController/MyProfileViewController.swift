import UIKit

final class MyProfileViewController: UIViewController {
    private let authViewModel = AuthViewModel.shared
    private lazy var user = authViewModel.user
    // TODO: 데이터 연결 필요
    private var posts: [Post] = []
    private var likePosts: [Post] = []

    private lazy var screenView = UIView().then {
        view.addSubview($0)
    }

    private lazy var countView = UIView().then { _ in
    }

    private lazy var profileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.layer.cornerRadius = 50
        $0.layer.borderColor = UIColor.accent.cgColor
    }

    private lazy var nicknameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.text = user?.username
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
        $0.setTitle("\(user?.posts ?? 0)\n작성글", for: .normal)
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
        $0.setTitle("\(user?.followers ?? 0)\n팔로워", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
    }

    private lazy var followingButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitle("\(user?.followings ?? 0)\n팔로잉", for: .normal)
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

    private lazy var myProfileSegmentedControl = CustomSegmentedControl(items: ["작성한 글", "좋아요 목록"]).then {
        view.addSubview($0)
        $0.addTarget(self, action: #selector(myProfileSegmentedControlSelected(_:)), for: .valueChanged)
    }

    private lazy var myProfileTableView = UITableView().then {
        $0.register(MyProfileTableViewCell.self, forCellReuseIdentifier: MyProfileTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        view.addSubview($0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // TODO: 불러오는 위치 변경하기
        UserViewModel.shared.withFollowers()
        UserViewModel.shared.withFollowings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    private func userDataUpdateUI() {
        AuthViewModel.shared.profile(
            onSuccess: { [weak self] user in
                guard let self else { return }
                nicknameLabel.text = user.username
                postButton.setTitle("\(user.posts)\nposts", for: .normal)
                followersButton.setTitle("\(user.followers)\nfollowers", for: .normal)
                followingButton.setTitle("\(user.followings)\nfollowings", for: .normal)
            },
            onError: { [weak self] error in
                // TODO: 오류 함수 후 재정의
                debugPrint(error)
            }
        )

        let yourUserId = 12
        PostViewModel.shared.withPosts(byUserId: yourUserId, onSuccess: { [weak self] posts in
            guard let self else { return }
            self.posts = posts
            myProfileTableView.reloadData()
        }, onError: { [weak self] error in
            // TODO: 오류 함수 후 재정의
            debugPrint(error)
        })
    }

    private func setUpUI() {
        screenView.flex.direction(.column).padding(20).define { flex in
            flex.addItem().direction(.row).define { flex in
                flex.addItem(profileImageView).width(100).height(100)
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(nicknameLabel).marginLeft(15)
                    flex.addItem(countView).marginLeft(5)
                    countView.flex.direction(.row)
                        .width(200).height(75).define { flex in
                            flex.addItem(postButton).width(70)
                            flex.addItem(followersButton).width(70)
                            flex.addItem(followingButton).width(70)
                        }
                }
            }
        }
        screenView.flex.layout()
        countView.flex.layout()

        screenView.pin.top(view.pin.safeArea).bottom(80%).left().right()
        editBlogButton.pin.below(of: screenView).left(20).right(20).marginTop(15)
        moreButton.pin.top(view.pin.safeArea).right(20)
        myProfileSegmentedControl.pin.below(of: editBlogButton).marginTop(10)
        myProfileTableView.pin.below(of: myProfileSegmentedControl).bottom(view.pin.safeArea).left().right()
    }

    @objc private func moreButtonTapped() {
        let vc = SeeMoreBottomSheetViewController()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.delegate = self
        present(vc, animated: true, completion: nil)
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

    @objc func myProfileSegmentedControlSelected(_ sender: CustomSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            myProfileTableView.reloadData()
        case 1:
            myProfileTableView.reloadData()
        default:
            break
        }
    }
}

extension MyProfileViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        switch myProfileSegmentedControl.selectedSegmentIndex {
        case 0:
            return posts.count
        case 1:
            return likePosts.count
        default: break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myPostCell = tableView.dequeueReusableCell(withIdentifier: MyProfileTableViewCell.identifier) as? MyProfileTableViewCell else { return UITableViewCell() }
        guard let likeCell = tableView.dequeueReusableCell(withIdentifier: MyProfileTableViewCell.identifier) as? MyProfileTableViewCell else { return UITableViewCell() }

        switch myProfileSegmentedControl.selectedSegmentIndex {
        case 0:
            let post = posts[indexPath.row]
            myPostCell.myTILView.setup(withTitle: post.title, content: post.content, date: post.publishedAt.format())
            return myPostCell
        case 1:
            let likePost = likePosts[indexPath.row]
            likeCell.myTILView.setup(withTitle: likePost.title, content: likePost.content, date: likePost.publishedAt.format())
            return likeCell
        default: break
        }
        return myPostCell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 85
    }
}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

extension MyProfileViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source _: UIViewController
    ) -> UIPresentationController? {
        return SeeMorePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension MyProfileViewController: SeeMoreBottomSheetDelegate {
    func didSelectSeeMoreMenu(title: String) {
        if title == "회원 정보 수정" {
            let profileEditViewController = ProfileEditViewController()
            profileEditViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileEditViewController, animated: true)
            profileEditViewController.username = user?.username
            profileEditViewController.userImage = user?.avatarUrl
            dismiss(animated: true, completion: nil)
        } else if title == "로그아웃" {
            let alertController = UIAlertController(title: "로그아웃", message: "정말 로그아웃하시겠어요?", preferredStyle: .alert)
            alertController.addAction(.init(title: "계속", style: .destructive, handler: { _ in
                AuthViewModel.shared.signOut()
            }))
            alertController.addAction(.init(title: "취소", style: .cancel))
            topMostViewController.present(alertController, animated: true)
        } else if title == "자주 묻는 질문" {
            // TODO: 노션
        } else if title == "개인 정보 처리 방침" {
            // TODO: 노션
        }
    }
}

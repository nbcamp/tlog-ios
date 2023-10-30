import UIKit

final class MyProfileViewController: UIViewController {
    private let authViewModel = AuthViewModel.shared
    private lazy var user = authViewModel.user

    private let accentColor = UIColor(named: "AccentColor")
    private lazy var screenView = UIView().then {
        view.addSubview($0)
    }

    private lazy var countView = UIView().then { _ in
    }

    private lazy var profileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.layer.cornerRadius = 50
        $0.layer.borderColor = accentColor?.cgColor
    }

    private lazy var nicknameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.text = user?.username
        $0.sizeToFit()
    }

    private lazy var moreButton = UIButton().then {
        $0.sizeToFit()
        $0.tintColor = accentColor
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 25)
        $0.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        view.addSubview($0)
    }

    private lazy var postButton = UIButton().then {
        $0.sizeToFit()
        $0.setTitle("\(user?.posts ?? 0)\npost", for: .normal)
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
        $0.setTitle("\(user?.followers ?? 0)\nfollowers", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
    }

    private lazy var followingButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitle("\(user?.followings ?? 0)\nfollowing", for: .normal)
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
    }

    private lazy var editBlogButton = CustomLargeButton().then {
        $0.sizeToFit()
        $0.backgroundColor = accentColor
        $0.setTitle("블로그 관리", for: .normal)
        $0.layer.cornerRadius = 8
        view.addSubview($0)
        $0.addTarget(self, action: #selector(editBlogButtonTapped), for: .touchUpInside)
    }

    private lazy var postAndLikeButton = CustomSegmentedControl(items: ["작성한 글", "좋아요 목록"]).then {
        view.addSubview($0)
    }

    private lazy var myProfileTableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        $0.delegate = self
        $0.dataSource = self
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // TODO: 불러오는 위치 변경하기
        UserViewModel.shared.withFollowers()
        UserViewModel.shared.withFollowings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
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
                            flex.addItem(postButton).grow(1)
                            flex.addItem(followersButton).grow(1)
                            flex.addItem(followingButton).grow(1).marginLeft(5)
                        }
                }
            }
            flex.addItem(editBlogButton).marginTop(15)
        }
        screenView.flex.layout()
        countView.flex.layout()

        screenView.pin.top(view.pin.safeArea).bottom(70%).left().right()
        moreButton.pin.top(view.pin.safeArea).right(20)
        postAndLikeButton.pin.below(of: screenView)
        myProfileTableView.pin.below(of: postAndLikeButton).bottom(view.pin.safeArea).left().right()
    }

    @objc private func moreButtonTapped() {
        // TODO: 더보기 페이지(사이드바, 바텀시트) 뷰 전환
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
        // TODO: 블로그 수정 뷰 전환
        let blogListViewController = BlogListViewController()
        blogListViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(blogListViewController, animated: true)
    }
}

extension MyProfileViewController: UITableViewDataSource, UITableViewDelegate {
    // TODO: 작성한 글 / 좋아요 목록 테이블뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        return cell
    }
}

extension MyProfileViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    { return SeeMorePresentationController(presentedViewController: presented, presenting: presenting) }
}

extension MyProfileViewController: SeeMoreBottomSheetDelegate {
    func didSelectSeeMoreMenu(title: String) {
        if title == "회원 정보 수정" {
            let profileEditViewController = ProfileEditViewController()
            navigationController?.pushViewController(profileEditViewController, animated: true)
            dismiss(animated: true, completion: nil)
        } else if title == "로그아웃" {
            let signInViewController = SignInViewController()
            navigationController?.pushViewController(signInViewController, animated: true)
            dismiss(animated: true, completion: nil)
        } else if title == "자주 묻는 질문" {
            print("자주 묻는 질문")
        } else if title == "개인 정보 처리 방침" {
            print("개인 정보 처리 방침")
        }
    }
}

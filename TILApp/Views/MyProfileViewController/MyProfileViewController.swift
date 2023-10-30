import UIKit

final class MyProfileViewController: UIViewController {
    struct TILList {
        let title: String
        let content: String
        let date: String
    }

    let myTILList: [TILList] = [
        .init(title: "작성글1", content: "오늘 오전엔 CustomComponent를 사용하는법을 익혔습니다.", date: "2023-10-25"),
        .init(title: "작성글2", content: "오늘 오후엔 UIPresentationController를 학습했습니다.", date: "2023-10-25"),
    ]
    let likeTILList: [TILList] = [
        .init(title: "좋아요누른 글1", content: "오늘은 좋아요를 눌러보겠습니다.", date: "2023-10-25"),
        .init(title: "좋아요누른 글2", content: "금일 TLog를 사용하면서 TIL에대한 것을 알고 한번 사용해보도록 하려고 합니다.", date: "2023-10-25"),
    ]
    private let authViewModel = AuthViewModel.shared
    private let userViewModel = UserViewModel.shared
    private let postViewModel = PostViewModel.shared
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
        if let username = authViewModel.user?.username {
            $0.text = username
        } else {
            $0.text = "nickname"
        }
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
        $0.setTitle("0\nposts", for: .normal)
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
        $0.setTitle("0\nfollowers", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
    }

    private lazy var followingButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitle("0\nfollowing", for: .normal)
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

    private lazy var myProfileSegmentedControl = CustomSegmentedControl(items: ["작성한 글", "좋아요 목록"]).then {
        view.addSubview($0)
        $0.addTarget(self, action: #selector(myProfileSegmentedControlSelected(_:)), for: .valueChanged)
    }

    private lazy var myProfileTableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: MyProfileTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        view.addSubview($0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        AuthViewModel.shared.profile(
            onSuccess: { [weak self] user in
                self?.nicknameLabel.text = user.username
                self?.postButton.setTitle("\(user.posts)\nposts", for: .normal)
                self?.followersButton.setTitle("\(user.followers)\nfollowers", for: .normal)
                self?.followingButton.setTitle("\(user.followings)\nfollowings", for: .normal)

            },
            onError: {[weak self] error in
                print("프로필 정보를 가져오는 중 에러 발생: \(error.localizedDescription)")
            })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        print("myTILList: \(myTILList)")
    }

    private func updateUI(with posts: [Post]) {
        let postTitles = posts.map { $0.title }
        let titleCount = postTitles.count

        postButton.setTitle("\(titleCount)\nposts", for: .normal)
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
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func followingButtonTapped() {
        let vc = FollowListViewController()
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
            return myTILList.count

        case 1:
            return likeTILList.count
        default: break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myPostCell = tableView.dequeueReusableCell(withIdentifier: MyProfileTableViewCell.identifier) as? MyProfileTableViewCell else { return UITableViewCell() }
        guard let likeCell = tableView.dequeueReusableCell(withIdentifier: MyProfileTableViewCell.identifier) as? MyProfileTableViewCell else { return UITableViewCell() }

        switch myProfileSegmentedControl.selectedSegmentIndex {
        case 0:
            let data = myTILList[indexPath.row]

            myPostCell.myTILView.setup(withTitle: data.title, content: data.content, date: data.date)
            print("\(data)")
            return myPostCell
        case 1:
            let data = likeTILList[indexPath.row]
            likeCell.myTILView.setup(withTitle: data.title, content: data.content, date: data.date)
            print("\(data)")

            return likeCell

        default: break
        }
        return myPostCell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 93
    }
}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

extension MyProfileViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?, source _: UIViewController) -> UIPresentationController?
    { return SeeMorePresentationController(presentedViewController: presented, presenting: presenting) }
}

extension MyProfileViewController: SeeMoreBottomSheetDelegate {
    func didSelectSeeMoreMenu(title: String) {
        if title == "회원 정보 수정" {
            let profileEditViewController = ProfileEditViewController()
            navigationController?.pushViewController(profileEditViewController, animated: true)
            navigationController?.hidesBottomBarWhenPushed = true

            dismiss(animated: true, completion: nil)
            navigationController?.hidesBottomBarWhenPushed = true

        } else if title == "로그아웃" {
            authViewModel.signOut()
        } else if title == "자주 묻는 질문" {
            print("자주 묻는 질문")
        } else if title == "개인 정보 처리 방침" {
            print("개인 정보 처리 방침")
        }
    }
}

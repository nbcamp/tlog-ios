
import UIKit

final class UserProfileViewController: UIViewController {
    var user: User?
    // TODO: 데이터 연결 필요
    private var posts: [Post] = []
    private var userLikePosts: [Post] = []

    private lazy var screenView = UIView().then {
        view.addSubview($0)
    }

    private lazy var countView = UIView()
    private lazy var followButtonView = UIView().then {
        view.addSubview($0)
    }

    private lazy var calendarView = UIView().then {
        $0.backgroundColor = .systemBlue
        view.addSubview($0)
    }

    private lazy var profileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.layer.cornerRadius = 50
    }

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
        $0.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        view.addSubview($0)
    }

    private lazy var postButton = UIButton().then {
        $0.sizeToFit()
        $0.setTitle("\(user?.posts ?? 0)\nposts", for: .normal)
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
    }

    private lazy var followingButton = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitle("\(user?.followings ?? 0)\nfollowing", for: .normal)
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.black, for: .normal)
    }

    private lazy var doingFollowButton = CustomFollowButton().then {
        $0.setTitle("팔로우", for: .normal)
        $0.backgroundColor = .accent
    }

    private lazy var userBlogURL = UIButton().then {
        $0.sizeToFit()
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.titleLabel?.textAlignment = .left
        $0.setTitle("유저의 블로그 URL링크", for: .normal)
        $0.setTitleColor(.systemGray, for: .normal)
        // TODO: 블로그 불러오기 구현 후 setTitle 수정
//            APIService.shared.request(.getMainBlog, model: [Blog].self) { [weak self] _ in
//                guard let self else { return }
//                userBlogURL.setTitle(blog.url, for: .normal)
//                print("\(blog)")
//            } onError: { [weak self] error in
//                // TODO: 오류 함수 구현 후 재정의
//                debugPrint(error)
//            }
    }

    private lazy var userSegmentedControl = CustomSegmentedControl(items: ["작성한 글", "좋아요 목록"]).then {
        view.addSubview($0)
        $0.addTarget(self, action: #selector(userSegmentedControlSelected(_:)), for: .valueChanged)
    }

    private lazy var userProfileTableView = UITableView().then {
        $0.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.applyCustomSeparator()
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
        moreButton.showsMenuAsPrimaryAction = true
    }

    private func setUpUI() {
        screenView.flex.addItem().direction(.row).marginLeft(10).define { flex in
            flex.addItem(profileImageView).width(100).height(100).marginLeft(10)
            flex.addItem().direction(.column).width(200).define { flex in
                flex.addItem(nicknameLabel).width(200).height(25).marginLeft(20).marginTop(5)
                flex.addItem(countView).direction(.row).width(200).height(75)
                countView.flex.direction(.row)
                    .width(210).define { flex in
                        flex.addItem(postButton).width(70)
                        flex.addItem(followersButton).width(70)
                        flex.addItem(followingButton).width(70)
                    }
            }
        }
        followButtonView.flex.addItem().direction(.row).define { flex in
            flex.addItem(doingFollowButton).width(100).height(30).direction(.row)
            flex.addItem(userBlogURL).width(180).marginBottom(20).marginLeft(10)
        }

        screenView.flex.layout()
        countView.flex.layout()
        followButtonView.flex.layout()

        screenView.pin.top(view.pin.safeArea).bottom(80%).left().right()
        followButtonView.pin.top(to: screenView.edge.bottom).left().right().height(50).marginLeft(20).marginTop(30)
        calendarView.pin.top(to: followButtonView.edge.bottom).left().right().bottom(30%)
        moreButton.pin.top(view.pin.safeArea).right(20)
        userSegmentedControl.pin.below(of: calendarView)
        userProfileTableView.pin.below(of: userSegmentedControl).bottom(view.pin.safeArea).left().right()
    }

    @objc private func moreButtonTapped() {
        // TODO: 차단하기 생각해보기
        let reportAction = UIAction(
            title: "차단하기",
            image: UIImage(systemName: "eye.slash"))
        { [weak self] _ in
            let alertController = UIAlertController(title: "차단 완료", message: "차단되었습니다.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            guard let self else { return }

            self.present(alertController, animated: true, completion: nil)
        }

        let reportSpamAction = UIAction(
            title: "신고하기",
            image: UIImage(systemName: "flag.fill"),
            attributes: .destructive)
        { [weak self] _ in
            let alertController = UIAlertController(title: "신고하기", message: "신고 사유를 입력해주세요", preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = "ex) 부적절한 게시물을 올려요."
            }

            let submitAction = UIAlertAction(title: "제출", style: .default) { _ in
                if let reason = alertController.textFields?.first?.text {
                    // TODO: 서버로 보내기
                    print("신고 사유: \(reason)")
                }
            }
            alertController.addAction(submitAction)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

            guard let self else { return }
            self.present(alertController, animated: true, completion: nil)
        }

        let menu = UIMenu(children: [reportAction, reportSpamAction])

        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = menu
    }

    @objc private func userSegmentedControlSelected(_ sender: CustomSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            userProfileTableView.reloadData()
        case 1:
            userProfileTableView.reloadData()
        default:
            break
        }
    }
}

extension UserProfileViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        switch userSegmentedControl.selectedSegmentIndex {
        case 0:
            return posts.count
        case 1:
            return userLikePosts.count
        default: break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userPostCell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier) as? UserTableViewCell else { return UITableViewCell() }
        guard let userLikeCell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier) as? UserTableViewCell else { return UITableViewCell() }

        switch userSegmentedControl.selectedSegmentIndex {
        case 0:
            let post = posts[indexPath.row]
            userPostCell.userTILView.setup(withTitle: post.title, content: post.content, date: post.publishedAt.format())
            return userPostCell
        case 1:
            let userLikePost = userLikePosts[indexPath.row]
            userLikeCell.userTILView.setup(withTitle: userLikePost.title, content: userLikePost.content, date: userLikePost.publishedAt.format())
            return userLikeCell
        default: break
        }
        return userPostCell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 85
    }
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

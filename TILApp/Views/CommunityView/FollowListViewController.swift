import UIKit

final class FollowListViewController: UIViewController {
    var selectedIndex = 0

    private var scrollRatios: [Int: CGFloat] = [:]

    private let authViewModel = AuthViewModel.shared
    private let userViewModel = UserViewModel.shared
    private lazy var user = authViewModel.user

    private lazy var segmentedControl = CustomSegmentedControl(items: [
        "팔로워 \(user?.followers ?? 0)",
        "팔로잉 \(user?.followings ?? 0)"
    ]).then {
        $0.selectedSegmentIndex = selectedIndex
        $0.addTarget(self, action: #selector(segmentedControlSelected(_:)), for: .valueChanged)
        view.addSubview($0)
    }

    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(FollowListTableViewCell.self, forCellReuseIdentifier: "FollowListTableViewCell")
        $0.applyCustomSeparator()
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "팔로우 관리"

        Task {
            _ = await loadFollowList()
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLayoutSubviews() {
        segmentedControl.pin.top(view.pin.safeArea).horizontally(view.pin.safeArea)
        tableView.pin.top(to: segmentedControl.edge.bottom).horizontally().bottom()
    }

    // TODO: 스크롤 위치 에러 수정
    @objc private func segmentedControlSelected(_ control: CustomSegmentedControl) {
        Task {
            _ = await loadFollowList()
            tableView.reloadData()
            tableView.layoutIfNeeded()

            let selectedIndex = control.selectedSegmentIndex
            if let ratio = scrollRatios[selectedIndex] {
                let totalScrollableHeight = tableView.contentSize.height - tableView.bounds.height
                let yOffset = totalScrollableHeight * ratio
                tableView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
            } else {
                tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let totalScrollableHeight = scrollView.contentSize.height - scrollView.bounds.height

        var ratio = totalScrollableHeight > 0 ? currentOffset / totalScrollableHeight : 0
        ratio = min(1, max(0, ratio))
        scrollRatios[segmentedControl.selectedSegmentIndex] = ratio
    }

    private func loadFollowList() async -> APIResult<[User]> {
        return await withCheckedContinuation { continuation in
            if selectedIndex == 0 {
                userViewModel.withMyFollowers { continuation.resume(returning: $0) }
            } else if selectedIndex == 1 {
                userViewModel.withMyFollowings { continuation.resume(returning: $0) }
            }
        }
    }
}

extension FollowListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return userViewModel.myFollowers.count
        case 1: return userViewModel.myFollowings.count
        default: break
        }
        return 0
    }

    // TODO: 마지막 작성일 추가하기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowListTableViewCell")
            as? FollowListTableViewCell else { return UITableViewCell() }

        let user: User = segmentedControl.selectedSegmentIndex == 0
            ? userViewModel.myFollowers[indexPath.row]
            : userViewModel.myFollowings[indexPath.row]

        let isFollowing = userViewModel.isMyFollowing(user: user)

        cell.customUserView.setup(
            image: UIImage(),
            nicknameText: user.username,
            contentText: "TIL 마지막 작성일 | ",
            variant: isFollowing ? .unfollow : .follow
        )

        cell.customUserView.followButtonTapped = { [weak self, weak cell] in
            guard let self, let cell else { return }

            let currentVariant = cell.customUserView.variant

            switch currentVariant {
            case .follow:
                userViewModel.follow(user: user) { [weak self] result in
                    guard let self else { return }
                    // TODO: 에러 처리
                    if case let .failure(error) = result {
                        NotificationCenter.postError(withError: error)
                        return
                    }
                    cell.customUserView.variant = .unfollow
                    segmentedControl.setTitle("팔로잉 \(userViewModel.myFollowings.count)", forSegmentAt: 1)
                }
            case .unfollow:
                userViewModel.unfollow(user: user) { [weak self] result in
                    guard let self else { return }
                    // TODO: 에러 처리
                    if case let .failure(error) = result {
                        NotificationCenter.postError(withError: error)
                        return
                    }
                    cell.customUserView.variant = .follow
                    segmentedControl.setTitle("팔로잉 \(userViewModel.myFollowings.count)", forSegmentAt: 1)
                }
            default:
                break
            }
        }
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 67
    }
}

extension FollowListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

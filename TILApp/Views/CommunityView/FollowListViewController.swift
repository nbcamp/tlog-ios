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

        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "팔로우 관리"
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
    @objc func segmentedControlSelected(_ control: CustomSegmentedControl) {
        let selectedIndex = control.selectedSegmentIndex

        tableView.reloadData()
        tableView.layoutIfNeeded()

        if let ratio = scrollRatios[selectedIndex] {
            let totalScrollableHeight = tableView.contentSize.height - tableView.bounds.height
            let yOffset = totalScrollableHeight * ratio
            tableView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
        } else {
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let totalScrollableHeight = scrollView.contentSize.height - scrollView.bounds.height

        var ratio = totalScrollableHeight > 0 ? currentOffset / totalScrollableHeight : 0
        ratio = min(1, max(0, ratio))
        scrollRatios[segmentedControl.selectedSegmentIndex] = ratio
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

//        let data: User = segmentedControl.selectedSegmentIndex == 0
//            ? userViewModel.followers[indexPath.row]
//            : userViewModel.followings[indexPath.row]
//
//        let variant: CustomFollowButton.Variant = userViewModel.isFollowed(userId: data.id) ? .unfollow : .follow

//        cell.customUserView.setup(
//            image: UIImage(),
//            nicknameText: data.username ?? "이름없음",
//            contentText: "TIL 마지막 작성일 | ",
//            variant: variant
//        )
//
//        cell.customUserView.followButtonTapped = { [weak self, weak cell] in
//            guard let self = self, let cell = cell else { return }
//
//            let currentVariant = cell.customUserView.variant
//
//            switch currentVariant {
//            case .follow:
//                userViewModel.follow(to: data.id) { [weak self] in
//                    guard let self else { return }
//                    cell.customUserView.variant = .unfollow
//                    segmentedControl.setTitle("팔로잉 \(userViewModel.followings.count)", forSegmentAt: 1)
//                } onError: { error in
//                    // TODO: 에러 처리
//                    print(error)
//                }
//
//            case .unfollow:
//                userViewModel.unfollow(to: data.id) { [weak self] in
//                    guard let self else { return }
//                    cell.customUserView.variant = .follow
//                    segmentedControl.setTitle("팔로잉 \(userViewModel.followings.count)", forSegmentAt: 1)
//                } onError: { error in
//                    // TODO: 에러 처리
//                    print(error)
//                }
//            }
//        }
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 67
    }
}

extension FollowListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

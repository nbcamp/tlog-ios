import UIKit

final class FollowListViewController: UIViewController {
    var selectedIndex = 0

    private let authViewModel = AuthViewModel.shared
    private let userViewModel = UserViewModel.shared
    private lazy var user = authViewModel.user

    private lazy var segmentedControl = CustomSegmentedControl(items: ["팔로워 \(user?.followers ?? 0)", "팔로잉 \(user?.followings ?? 0)"]).then {
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

    override func viewDidLayoutSubviews() {
        segmentedControl.pin.top(view.pin.safeArea)
        tableView.pin.top(to: segmentedControl.edge.bottom).horizontally().bottom()
        tableView.reloadData()
    }

    @objc func segmentedControlSelected(_: CustomSegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            segmentedControl.setTitle("팔로워 \(userViewModel.followers.count)", forSegmentAt: 0)
            tableView.reloadData()
        case 1:
            segmentedControl.setTitle("팔로잉 \(userViewModel.followings.count)", forSegmentAt: 1)
            tableView.reloadData()
        default:
            break
        }
    }
}

extension FollowListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return userViewModel.followers.count
        case 1:
            return userViewModel.followings.count
        default: break
        }
        return 0
    }

    // TODO: 마지막 작성일 추가하기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowListTableViewCell") as? FollowListTableViewCell else { return UITableViewCell() }

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let data = userViewModel.followers[indexPath.row]
            let variant: CustomFollowButton.Variant = userViewModel.isFollowed(user: data) ? .unfollow : .follow
            cell.customUserView.setup(image: UIImage(), nicknameText: data.username, contentText: "TIL 마지막 작성일 | ", variant: variant)

            cell.customUserView.buttonTapHandler = { [weak cell] in
                guard let cell else { return }

                if variant == .follow {
                    self.userViewModel.follow(to: data.id, onSuccess: { [weak self] in
                        guard let self else { return }
                        cell.customUserView.variant = .unfollow
                        segmentedControl.setTitle("팔로잉 \(userViewModel.followings.count)", forSegmentAt: 1)
                    }, onError: { error in
                        print(error)
                    })

                } else {
                    self.userViewModel.unfollow(to: data.id, onSuccess: { [weak self] in
                        guard let self else { return }
                        cell.customUserView.variant = .follow
                        segmentedControl.setTitle("팔로잉 \(userViewModel.followings.count)", forSegmentAt: 1)
                    }, onError: { error in
                        print(error)
                    })
                }
            }
            return cell
        case 1:
            let data = userViewModel.followings[indexPath.row]
            cell.customUserView.setup(image: UIImage(), nicknameText: data.username, contentText: "TIL 마지막 작성일 | ", variant: .unfollow)

            cell.customUserView.buttonTapHandler = { [weak cell] in
                guard let cell else { return }
                self.userViewModel.unfollow(to: data.id, onSuccess: { [weak self] in
                    guard let self else { return }
                    cell.customUserView.variant = .follow
                    segmentedControl.setTitle("팔로잉 \(userViewModel.followings.count)", forSegmentAt: 1)
                }, onError: { error in
                    print(error)
                })
            }
            return cell
        default: break
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

import UIKit

final class BlockedUserViewController: UIViewController {
    private var blockedUsers: [BlockedUser] = []

    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(BlockedUserTableViewCell.self, forCellReuseIdentifier: "BlockedUserTableViewCell")
        $0.applyCustomSeparator()
        view.addSubview($0)
    }

    private lazy var placeholderView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.flex.alignItems(.center).define { flex in
            flex.addItem(UILabel().then {
                $0.text = "차단한 사용자가 없어요."
                $0.textColor = .systemGray3
                $0.font = .boldSystemFont(ofSize: 20)
            }).marginTop(50)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "차단한 사용자 관리"

        UserViewModel.shared.withMyBlockedUsers { [weak self] result in
            guard let self, case .success(let users) = result else { return }
            blockedUsers = users
            tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.pin.top(view.pin.safeArea).bottom().horizontally()
    }
}

extension BlockedUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableView.backgroundView = blockedUsers.count == 0 ? placeholderView : nil
        tableView.backgroundView?.flex.layout()
        return blockedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserTableViewCell")
            as? BlockedUserTableViewCell else { return UITableViewCell() }

        let user = blockedUsers[indexPath.row]

        cell.customBlockedUserView.setup(
            username: user.username,
            avatarUrl: user.avatarUrl
        )

        cell.customBlockedUserView.unblockButtonTapped = { [weak self] in
            guard let self else { return }
            UserViewModel.shared.unblockUser(user: user) { [weak self] _ in
                self?.blockedUsers.removeAll { $0.id == user.id }
                self?.tableView.reloadData()
            }
        }
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 67
    }
}

extension BlockedUserViewController: UITableViewDelegate {}

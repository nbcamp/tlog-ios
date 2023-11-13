import UIKit

final class BlockedUserViewController: UIViewController {
    
    let blockedUsers: [User] = [
//        .init(id: 999, username: "차단1", avatarUrl: "", posts: 0, followers: 0, followings: 0),
//        .init(id: 9999, username: "차단2", avatarUrl: "", posts: 0, followers: 0, followings: 0)
    ]
    
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(BlockedUserTableViewCell.self, forCellReuseIdentifier: "BlockedUserTableViewCell")
        $0.applyCustomSeparator()

        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        title = "차단한 사용자 관리"
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
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return blockedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserTableViewCell")
            as? BlockedUserTableViewCell else { return UITableViewCell() }

        let user: User = blockedUsers[indexPath.row]

        cell.customBlockedUserView.setup(
            username: user.username,
            avatarUrl: user.avatarUrl
        )

        cell.customBlockedUserView.unblockButtonTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }

            // TODO: 차단 해제 로직

        }
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 67
    }
}

extension BlockedUserViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

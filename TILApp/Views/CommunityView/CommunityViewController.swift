import UIKit

final class CommunityViewController: UIViewController {
    private let communityViewModel = CommunityViewModel.shared

    private var items: [CommunityPost] = []

    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
    }

    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.keyboardDismissMode = .onDrag
        $0.refreshControl = refreshControl
        $0.register(CommunityTableViewCell.self, forCellReuseIdentifier: "CommunityTableViewCell")
        view.addSubview($0)
    }

    private lazy var searchBar = UISearchBar().then {
        $0.delegate = self
        view.addSubview($0)
    }

    private lazy var loadingView = UIActivityIndicatorView().then {
        $0.startAnimating()
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        communityViewModel.load { [weak self] items in
            guard let self else { return }
            print(items)
            self.items = items
            loadingView.stopAnimating()
            loadingView.isHidden = true
            tableView.reloadData()
        } onError: { error in
            // TODO: 에러 처리
            debugPrint(error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLayoutSubviews() {
        searchBar.pin.top(view.pin.safeArea).horizontally().height(60)
        tableView.pin.top(to: searchBar.edge.bottom).horizontally().bottom(view.pin.safeArea)
        loadingView.pin.center()
    }

    @objc private func refreshContent() {
        communityViewModel.refresh { [weak self] items in
            guard let self else { return }
            self.items = items
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self else { return }
                refreshControl.endRefreshing()
            }
        } onError: { error in
            // TODO: 에러 처리
            debugPrint(error)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CommunityViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CommunityTableViewCell",
            for: indexPath
        ) as? CommunityTableViewCell else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]

//         TODO: CommunityTableViewCell에 configure 함수 만들기
        cell.customCommunityTILView.userView.setup(
            image: UIImage(),
            nicknameText: item.user.username,
            contentText: "팔로워 \(item.user.followers)",
            variant: .follow
        )
        cell.customCommunityTILView.tilView.setup(
            withTitle: item.post.title,
            content: item.post.content,
            date: ""
        )
        cell.customCommunityTILView.relativePublishedDateLabel = item.post.publishedAt.relativeFormat()
        cell.selectionStyle = .none

        cell.customCommunityTILView.userProfileTapped = { [weak self] in
            guard let self else { return }
            let userProfileViewController = UserProfileViewController()
            navigationController?.pushViewController(userProfileViewController, animated: true)
        }

        cell.customCommunityTILView.postTapped = { [weak self] in
            guard let self else { return }
            let webViewController = WebViewController()
            webViewController.postURL = item.post.url
            // TODO: bottom bar가 대체되지 않는 문제 수정
            webViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webViewController, animated: true)
        }

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 161
    }
}

extension CommunityViewController: UITableViewDelegate {}

extension CommunityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            communityViewModel.search(query: text) { [weak self] items in
                guard let self else { return }
                self.items = items
                tableView.reloadData()
            } onError: { error in
                // TODO: 에러처리
                debugPrint(error)
            }
        }
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            items = communityViewModel.cache
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

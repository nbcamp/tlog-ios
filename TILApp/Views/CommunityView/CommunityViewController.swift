import UIKit

final class CommunityViewController: UIViewController {
    private let communityViewModel = CommunityViewModel.shared
    private let userViewModel = UserViewModel.shared
    private var items: [CommunityPost] { communityViewModel.items }
    private var cancellables: Set<AnyCancellable> = []

    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.keyboardDismissMode = .onDrag
        $0.refreshControl = UIRefreshControl()
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

    private lazy var footerLoadingView = UIActivityIndicatorView().then {
        tableView.tableFooterView = $0
        $0.frame = .init(x: 0, y: 0, width: tableView.bounds.width, height: 100)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        communityViewModel.delegate = self
        communityViewModel.load { [weak self] _ in
            guard let self else { return }
            loadingView.stopAnimating()
            loadingView.isHidden = true
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

        cell.customCommunityTILView.setup(user: item.user, post: item.post)
        
        let user = item.user
        
        let variant: CustomFollowButton.Variant = userViewModel.isFollowed(userId: user.id) ? .unfollow : .follow
        cell.customCommunityTILView.variant = variant

        cell.customCommunityTILView.followButtonTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }

            let currentVariant = cell.customCommunityTILView.variant

            switch currentVariant {
            case .follow:
                userViewModel.follow(to: user.id) { [weak self] in
                    guard let self else { return }
                    cell.customCommunityTILView.variant = .unfollow
                } onError: { error in
                    // TODO: 에러 처리
                    print(error)
                }

            case .unfollow:
                userViewModel.unfollow(to: user.id) { [weak self] in
                    guard let self else { return }
                    cell.customCommunityTILView.variant = .follow
                } onError: { error in
                    // TODO: 에러 처리
                    print(error)
                }
            default:
                break
            }
        }
        
        cell.selectionStyle = .none

        cell.customCommunityTILView.userProfileTapped = { [weak self] in
            guard let self else { return }
            let userProfileViewController = UserProfileViewController()
            userProfileViewController.user = item.user
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
        return 180
    }
}

extension CommunityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            communityViewModel.loadMore()
        }
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        guard let refreshControl = tableView.refreshControl, refreshControl.isRefreshing else { return }
        communityViewModel.refresh { _ in
            refreshControl.endRefreshing()
        }
    }
}

extension CommunityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            communityViewModel.search(query: text)
        }
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            communityViewModel.reload()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension CommunityViewController: CommunityViewModelDelegate {
    func itemsUpdated(_: CommunityViewModel, items _: [CommunityPost], range: Range<Int>) {
        if range.lowerBound > 0 {
            let indexPaths = range.map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } else {
            tableView.reloadData()
        }
    }

    func errorOccurred(_: CommunityViewModel, error: Error) {
        // TODO: 에러처리
        debugPrint(error)
    }
}

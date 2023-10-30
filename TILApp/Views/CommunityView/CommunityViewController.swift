import UIKit

final class CommunityViewController: UIViewController {
    private let postViewModel = PostViewModel.shared

    private var posts: [CommunityPost] = []

    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(CommunityTableViewCell.self, forCellReuseIdentifier: "CommunityTableViewCell")
    }

    private var searchBar = UISearchBar()
    private var loadingView = UIActivityIndicatorView().then {
        $0.startAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingView)

        loadCommunity()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        searchBar.pin.top(view.pin.safeArea).horizontally().height(60)
        tableView.pin.top(to: searchBar.edge.bottom).horizontally().bottom(view.pin.safeArea)
        loadingView.pin.center()
    }

    private func loadCommunity(with _: String? = nil) {
        postViewModel.withCommunity { [weak self] posts in
            guard let self else { return }
            self.posts = posts
            loadingView.stopAnimating()
            loadingView.isHidden = true
            tableView.reloadData()
        } onError: { error in
            debugPrint(error)
        }
    }
}

extension CommunityViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CommunityTableViewCell",
            for: indexPath
        ) as? CommunityTableViewCell else {
            return UITableViewCell()
        }

        let item = posts[indexPath.row]

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
//            guard let self else { return }
            // TODO: print 제거, User Profile 화면 이동
            print("User Profile Tapped")
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

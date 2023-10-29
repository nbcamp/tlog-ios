import UIKit

final class CommunityViewController: UIViewController {
    var isSearching = false
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(CommunityTableViewCell.self, forCellReuseIdentifier: "CommunityTableViewCell")
    }

    // TODO: 더미데이터 삭제
    var filteredCommunityData: [[String]] = []
    var communityData: [[String]] = [
        ["Blog 1", "팔로워 11", "팔로우", "제목제목", "내용\n내용내용", "2023-10-24"],
        ["Blog 2", "팔로워 11", "팔로우", "제목제목", "내용\n내용내용", "2023-10-25"],
        ["Blog 3", "팔로워 11", "팔로우", "제목제목", "내용\n내용", "2023-10-26"],
    ]

    private lazy var searchBar = UISearchBar().then {
        $0.delegate = self
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        searchBar.pin.top(view.pin.safeArea).horizontally().height(60)
        tableView.pin.top(to: searchBar.edge.bottom).horizontally().bottom(view.pin.safeArea)
    }
}

extension CommunityViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if isSearching {
            return filteredCommunityData.count
        } else {
            return communityData.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityTableViewCell", for: indexPath) as? CommunityTableViewCell else {
            return UITableViewCell()
        }
        let info: [String]
        if isSearching {
            info = filteredCommunityData[indexPath.row]
        } else {
            info = communityData[indexPath.row]
        }
        // TODO: CommunityTableViewCell에 configure 함수 만들기
        cell.customCommunityTILView.userView.setup(image: UIImage(), nicknameText: info[0], contentText: info[1], variant: .follow)
        cell.customCommunityTILView.tilView.setup(withTitle: info[3], content: info[4], date: "")
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 161
    }
}

extension CommunityViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row

        // TODO: tabBarController?.hidesBottomBarWhenPushed = true
        // self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CommunityViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredCommunityData.removeAll()
        } else {
            isSearching = true
            filteredCommunityData = communityData.filter { rowData in
                let blogName = rowData[0]
                let title = rowData[3]
                let content = rowData[4]
                return blogName.contains(searchText) || title.contains(searchText) || content.contains(searchText)
            }
        }
        tableView.reloadData()
    }
}

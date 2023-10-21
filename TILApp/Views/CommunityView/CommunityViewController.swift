import UIKit

final class CommunityViewController: UIViewController {
    private let tableView = UITableView()

    let communityData: [[String]] = [
        ["Blog 1", "팔로워 11", "팔로우", "제목제목", "내용\n내용내용", "2023-10-24"],
        ["Blog 2", "팔로워 11", "팔로우", "제목제목", "내용\n내용내용", "2023-10-25"],
        ["Blog 3", "팔로워 11", "팔로우", "제목제목", "내용\n내용내용", "2023-10-26"],
    ]

    private var searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(searchBar)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "CommunityTableViewCell")

        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        searchBar.pin.top(view.pin.safeArea).horizontally().height(60)
        tableView.pin.top(to: searchBar.edge.bottom).horizontally().bottom(view.pin.safeArea)
    }
}

extension CommunityViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return communityData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityTableViewCell", for: indexPath) as? CommunityTableViewCell else {
            return UITableViewCell()
        }

        let info = communityData[indexPath.row]

        cell.customCommunityTILView.userView.setup(image: UIImage(), nicknameText: info[0], contentText: info[1], buttonTitle: info[2])
        cell.customCommunityTILView.TILView.setup(withTitle: info[3], content: info[4], date: info[5])
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 141
    }
}

extension CommunityViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row

        // self.navigationController?.pushViewController(blogEditViewController, animated: true)
    }
}

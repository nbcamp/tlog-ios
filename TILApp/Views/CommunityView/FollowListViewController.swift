//
//  FollowListViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/23/23.
//

import UIKit

final class FollowListViewController: UIViewController {
    private lazy var segmentedControl = CustomSegmentedControl(items: ["팔로워 6", "팔로잉 3"]).then {
        $0.addTarget(self, action: #selector(segmentedControlSelected(_:)), for: .valueChanged)

        view.addSubview($0)
    }

    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(FollowListTableViewCell.self, forCellReuseIdentifier: "FollowListTableViewCell")

        view.addSubview($0)
    }

    let followerData: [(name: String, date: String)] = [
        ("Blog 1", "TIL 마지막 작성일 | 2023-10-12"),
        ("Blog 2", "TIL 마지막 작성일 | 2023-10-13"),
        ("Blog 3", "TIL 마지막 작성일 | 2023-10-14"),
        ("Blog 4", "TIL 마지막 작성일 | 2023-10-15"),
        ("Blog 5", "TIL 마지막 작성일 | 2023-10-16"),
        ("Blog 6", "TIL 마지막 작성일 | 2023-10-17"),
    ]

    let followingData: [(name: String, date: String)] = [
        ("Blog 1", "TIL 마지막 작성일 | 2023-10-17"),
        ("Blog 2", "TIL 마지막 작성일 | 2023-10-17"),
        ("Blog 3", "TIL 마지막 작성일 | 2023-10-17"),
    ]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLayoutSubviews() {
        segmentedControl.pin.top(view.pin.safeArea)
        tableView.pin.top(to: segmentedControl.edge.bottom).horizontally().bottom()
    }

    @objc func segmentedControlSelected(_: CustomSegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tableView.reloadData()
        case 1:
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
            return followerData.count
        case 1:
            return followingData.count
        default: break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let followerCell = tableView.dequeueReusableCell(withIdentifier: "FollowListTableViewCell") as? FollowListTableViewCell else { return UITableViewCell() }
        guard let followingCell = tableView.dequeueReusableCell(withIdentifier: "FollowListTableViewCell") as? FollowListTableViewCell else { return UITableViewCell() }
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let data = followerData[indexPath.row]
            followerCell.customUserView.setup(image: UIImage(), nicknameText: data.name, contentText: data.date, variant: .follow)
            return followerCell
        case 1:
            let data = followingData[indexPath.row]
            followingCell.customUserView.setup(image: UIImage(), nicknameText: data.name, contentText: data.date, variant: .unfollow)
            return followingCell
        default: break
        }
        return followerCell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 67
    }
}

extension FollowListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

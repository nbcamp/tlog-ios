//
//  BlogListViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/19/23.
//

import UIKit

final class BlogListViewController: UIViewController {
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(BlogListTableViewCell.self, forCellReuseIdentifier: "CustomBlogCell")
    }

    let blogData: [(name: String, url: String)] = [
        ("Blog 1", "http://blog1.com"),
        ("Blog 2", "http://blog2.com"),
        ("Blog 3", "http://blog3.com"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "블로그 목록"

        let addBlogButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addBlogButtonTapped))
        navigationItem.rightBarButtonItem = addBlogButton

        view.addSubview(tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.pin.top(view.pin.safeArea).horizontally().bottom()
    }

    @objc private func addBlogButtonTapped() {
        navigationController?.pushViewController(BlogRegisterViewController(), animated: false)
    }
}

extension BlogListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return blogData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomBlogCell", for: indexPath) as? BlogListTableViewCell else {
            return UITableViewCell()
        }

        let (name, url) = blogData[indexPath.row]
        cell.customBlogView.blogNameText = name
        cell.customBlogView.blogURLText = url

        // 대표블로그 가장 위로 정렬해야 함 -> 대표블로그인 경우에만 primary 타입 보내주기
        if indexPath.row == 0 {
            cell.customBlogView.variant = .primary
        }

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 67
    }
}

extension BlogListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row

        let (name, url) = blogData[selectedRow]

        let blogEditViewController = BlogEditViewController()

        blogEditViewController.blogName = name
        blogEditViewController.blogURL = url

        navigationController?.pushViewController(blogEditViewController, animated: true)
    }
}

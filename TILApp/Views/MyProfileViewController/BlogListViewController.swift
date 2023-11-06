import UIKit

final class BlogListViewController: UIViewController {
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(BlogListTableViewCell.self, forCellReuseIdentifier: "CustomBlogCell")
    }

    private let blogViewModel = BlogViewModel.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "블로그 목록"

        let addBlogButton
            = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addBlogButtonTapped))
        navigationItem.rightBarButtonItem = addBlogButton
        view.addSubview(tableView)

        blogViewModel.load { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true

        KeywordInputViewModel.shared.clear()
        tableView.reloadData()
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
        return blogViewModel.blogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell
            = tableView.dequeueReusableCell(withIdentifier: "CustomBlogCell", for: indexPath) as? BlogListTableViewCell
        else {
            return UITableViewCell()
        }

        let blog = blogViewModel.blogs[indexPath.row]
        cell.customBlogView.blogNameText = blog.name
        cell.customBlogView.blogURLText = blog.url
        if blog.main {
            cell.customBlogView.variant = .primary
        } else {
            cell.customBlogView.variant = .normal
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

        let blog = blogViewModel.blogs[selectedRow]

        let blogEditViewController = BlogEditViewController()
        blogEditViewController.id = blog.id

        navigationController?.pushViewController(blogEditViewController, animated: true)
    }
}

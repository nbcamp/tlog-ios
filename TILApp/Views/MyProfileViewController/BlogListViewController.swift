import UIKit

final class BlogListViewController: UIViewController {
    private let blogViewModel = BlogViewModel.shared
    private var blogs: [Blog] { blogViewModel.blogs }

    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.applyCustomSeparator()
        $0.register(BlogListTableViewCell.self, forCellReuseIdentifier: "CustomBlogCell")
    }

    private lazy var placeholderView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.flex.alignItems(.center).define { flex in
            flex.addItem(UILabel().then {
                $0.text = "새로운 블로그를 등록해주세요!"
                $0.textColor = .systemGray3
                $0.font = .boldSystemFont(ofSize: 20)
                $0.textAlignment = .center
            }).marginTop(50)
        }
    }

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

        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true

        KeywordInputViewModel.shared.clear()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.pin.top(view.pin.safeArea).horizontally().bottom()
    }

    @objc private func addBlogButtonTapped() {
        navigationController?.pushViewController(BlogRegisterViewController(), animated: true)
    }
}

extension BlogListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableView.backgroundView = blogs.count == 0 ? placeholderView : nil
        tableView.backgroundView?.flex.layout()
        return blogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomBlogCell", for: indexPath)
            as? BlogListTableViewCell else { return UITableViewCell() }

        let blog = blogs[indexPath.row]
        cell.customBlogView.blogNameText = blog.name
        cell.customBlogView.blogURLText = blog.url
        cell.customBlogView.variant = blog.main ? .primary : .normal

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 67
    }
}

extension BlogListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row

        let blog = blogs[selectedRow]
        let blogEditViewController = BlogEditViewController()
        blogEditViewController.id = blog.id

        navigationController?.pushViewController(blogEditViewController, animated: true)
    }
}

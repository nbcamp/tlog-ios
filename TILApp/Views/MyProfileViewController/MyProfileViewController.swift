import FlexLayout
import PinLayout
import UIKit

final class MyProfileViewController: UIViewController {
    private lazy var fullScreenView = {
        let full = UIView()
        view.addSubview(full)
        return full
    }()

    private lazy var countView = {
        let flexView = UIView()
        return flexView
    }()

    private lazy var profileImageView = {
        let imageView = UIImageView(image: UIImage(systemName: ""))
        imageView.tintColor = .systemTeal
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor.systemTeal.cgColor
        imageView.backgroundColor = .systemGray4
        return imageView
    }()

    private lazy var nicknameLabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "nickname"
        label.sizeToFit()
        return label
    }()

    private lazy var moreButton = {
        let button = UIButton()
        button.sizeToFit()
        button.tintColor = .systemTeal
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 25)
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    private lazy var postButton = {
        let button = UIButton()
        button.sizeToFit()
        button.setTitle("39\npost", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private lazy var followersButton = {
        let button = UIButton()
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitle("107\nfollowers", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var followingButton = {
        let button = UIButton()
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("64\nfollowing", for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.black, for: .normal)
        view.addSubview(button)
        button.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var editBlogButton = {
        let button = UIButton()
        button.sizeToFit()
        button.backgroundColor = .systemTeal
        button.setTitle("블로그 관리", for: .normal)
        button.tintColor = .systemTeal
        button.layer.cornerRadius = 8
        view.addSubview(button)
        button.addTarget(self, action: #selector(editBlogButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var myProfileTableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)

        myProfileTableView.delegate = self
        myProfileTableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .systemBackground
        setUpUI()
        fullScreenView.flex.layout()
        countView.flex.layout()
    }

    private func setUpUI() {
        fullScreenView.flex.direction(.column).padding(20).define { flex in
            flex.addItem().direction(.row).define { flex in
                flex.addItem(profileImageView).width(100).height(100)
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(nicknameLabel).marginLeft(15)
                    flex.addItem(countView).marginLeft(5)
                    countView.flex.direction(.row)
                        .width(200).height(75).define { flex in
                            flex.addItem(postButton).grow(1)
                            flex.addItem(followersButton).grow(1)
                            flex.addItem(followingButton).grow(1).marginLeft(5)
                        }
                }
            }
            flex.addItem(editBlogButton).marginTop(15)
        }
        fullScreenView.pin.top(view.pin.safeArea).bottom(70%).left().right()
        moreButton.pin.top(view.pin.safeArea).right()
        myProfileTableView.pin.below(of: fullScreenView).bottom(view.pin.safeArea)
            .left().right()
    }

    @objc private func moreButtonTapped() {
        print("moreButtonTappedTest")
    }

    @objc private func followersButtonTapped() {
        print("followersButtonTappedTest")
    }

    @objc private func followingButtonTapped() {
        print("followingButtonTappedTest")
    }

    @objc private func editBlogButtonTapped() {
        print("editBlogTappedTest")
    }
}

extension MyProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        return cell
    }
}

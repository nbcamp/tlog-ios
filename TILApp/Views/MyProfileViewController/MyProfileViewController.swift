import FlexLayout
import PinLayout
import UIKit

final class MyProfileViewController: UIViewController {
    private let profileImageView = {
        let imageView = UIImageView(image: UIImage(systemName: ""))
        imageView.tintColor = .systemTeal
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor.systemTeal.cgColor
        imageView.backgroundColor = .systemGray4
        return imageView
    }()

    private var nicknameLabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "nickname"
        label.sizeToFit()
        return label
    }()

    private let moreButton = {
        let button = UIButton()
        button.sizeToFit()
        button.tintColor = .systemTeal
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 25)
        return button
    }()

    private let postButton = {
        let button = UIButton()
        button.sizeToFit()
        button.setTitle("39\npost", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private let followersButton = {
        let button = UIButton()
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitle("107\nfollowers", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private let followingButton = {
        let button = UIButton()
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("64\nfollowing", for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private let editBlogButton = {
        let button = UIButton()
        button.sizeToFit()
        button.backgroundColor = .systemTeal
        button.setTitle("블로그 관리", for: .normal)
        button.tintColor = .systemTeal
        button.layer.cornerRadius = 8

        return button
    }()

    private let rootFlexContainer = {
        let view = UIView()
        return view
    }()

//    init() {
//        super.init(frame: .zero)
//        addSubview(rootFlexContainer)
//
//        rootFlexContainer.flex.direction(.row).justifyContent(.spaceEvenly).padding(10)
//            .alignSelf(.auto).define { flex in
//                flex.addItem(postButton).marginRight(20)
//                flex.addItem(followersButton).marginRight(20)
//                flex.addItem(followingButton)
//            }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    private let myProfileTableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        myProfileTableView.delegate = self
        myProfileTableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .systemBackground

        setUpUI()
        rootFlexContainer.flex.layout()
    }

    private func setUpUI() {
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(moreButton)
        view.addSubview(editBlogButton)
        view.addSubview(myProfileTableView)
        view.addSubview(rootFlexContainer)

        rootFlexContainer.flex.direction(.row).justifyContent(.center).define { flex in
            flex.addItem(postButton).width(60).marginLeft(10)
            flex.addItem(followersButton).width(60)
            flex.addItem(followingButton).width(60).marginLeft(10)
        }

        profileImageView.pin.top(view.pin.safeArea + 5).left(7.5%).height(100).width(100).margin(10)
        nicknameLabel.pin.top(view.pin.safeArea + 25).after(of: profileImageView).before(of: moreButton).marginLeft(15)
        moreButton.pin.top(view.pin.safeArea).right(view.pin.safeArea + 10)
        rootFlexContainer.pin.below(of: nicknameLabel).after(of: profileImageView)
            .marginLeft(90).marginTop(25)
        editBlogButton.pin.below(of: profileImageView).left(3%).right(3%).margin(20)
        myProfileTableView.pin.below(of: editBlogButton).marginTop(30)
            .bottom(view.pin.safeArea).left().right()
    }

    @objc func moreButtonTapped() {
        print("test")
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

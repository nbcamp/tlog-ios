import UIKit

protocol SeeMoreBottomSheetDelegate: AnyObject {
    func didSelectSeeMoreMenu(title: String)
}

struct SeeMoreMenu {
    let title: String
    let icon: String
}

class SeeMoreBottomSheetViewController: UIViewController {
    let seeMoreMenus: [SeeMoreMenu] = [
        .init(title: "회원 정보 수정", icon: "gearshape"),
        .init(title: "자주 묻는 질문", icon: "questionmark.app"),
        .init(title: "이용 약관", icon: "checkmark.shield"),
        .init(title: "개인 정보 처리 방침", icon: "exclamationmark.shield"),
        .init(title: "차단한 사용자 관리", icon: "person.badge.minus"),
        .init(title: "로그아웃", icon: "rectangle.portrait.and.arrow.forward"),
    ]
    weak var delegate: SeeMoreBottomSheetDelegate?

    private lazy var backgroundView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = 30.0
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview($0)
    }

    private lazy var moreTableView = UITableView().then {
        $0.separatorColor = .clear
        $0.isScrollEnabled = false
        $0.register(MoreTableViewCell.self, forCellReuseIdentifier: MoreTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        backgroundView.addSubview($0)
    }

    private lazy var handleView = UIView().then {
        $0.backgroundColor = .systemGray
        $0.frame = CGRect(x: (view.frame.width - 40) / 2, y: 10, width: 80, height: 6)
        $0.layer.cornerRadius = 3
        backgroundView.addSubview($0)
    }

    private lazy var emptyView = UIView().then {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(emptyViewTapped))
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(gesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    private func setUpUI() {
        view.flex.direction(.column).define { flex in
            flex.addItem(emptyView).height(40%)
            flex.addItem(backgroundView).grow(1).direction(.column).define { flex in
                flex.addItem(handleView).width(60).height(6).marginTop(15).alignSelf(.center)
                flex.addItem(moreTableView).grow(1).marginTop(10)
            }
        }.layout()
    }

    @objc func emptyViewTapped() {
        dismiss(animated: true)
    }
}

extension SeeMoreBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MoreTableViewCell.identifier,
            for: indexPath
        ) as? MoreTableViewCell else {
            return UITableViewCell()
        }

        let seeMenuList = seeMoreMenus[indexPath.row]
        cell.configure(withTitle: seeMenuList.title, iconName: seeMenuList.icon)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seeMoreMenus.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTitle = seeMoreMenus[indexPath.row].title
        delegate?.didSelectSeeMoreMenu(title: selectedTitle)
    }
}

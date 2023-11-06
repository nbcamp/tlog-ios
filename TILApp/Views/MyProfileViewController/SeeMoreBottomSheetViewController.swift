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
        .init(title: "개인 정보 처리 방침", icon: "exclamationmark.shield"),
        .init(title: "차단한 사용자 관리", icon: "person.badge.minus"),
        .init(title: "로그아웃", icon: "rectangle.portrait.and.arrow.forward"),
    ]
    weak var delegate: SeeMoreBottomSheetDelegate?

    private lazy var backgroundView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.sizeToFit()
        view.addSubview($0)
    }

    private lazy var moreTableView = UITableView().then {
        $0.separatorColor = .clear
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.register(MoreTableViewCell.self, forCellReuseIdentifier: MoreTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        backgroundView.addSubview($0)
    }

    private lazy var handleView = UIView().then {
        $0.backgroundColor = .systemGray
        $0.frame = CGRect(x: (view.frame.width - 40) / 2, y: 10, width: 80, height: 6)
        $0.layer.cornerRadius = 3
        $0.isUserInteractionEnabled = true

        backgroundView.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    private func setUpUI() {
        view.pin.top(55%)
        backgroundView.pin.all(view.pin.safeArea)
        handleView.pin.topCenter().marginTop(15)
        moreTableView.pin.below(of: handleView).bottom().left().right().marginTop(25)
        backgroundView.layer.cornerRadius = 30.0
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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

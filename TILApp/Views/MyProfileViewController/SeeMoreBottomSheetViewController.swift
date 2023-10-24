import FlexLayout
import PinLayout
import Then
import UIKit

class SeeMoreBottomSheetViewController: UIViewController {
    let titles = ["회원 정보 수정", "자주 묻는 질문", "개인 정보 처리 방침", "로그아웃"]
    let iconNames = ["gearshape", "questionmark.app", "exclamationmark.shield", "rectangle.portrait.and.arrow.forward"]

    private lazy var backgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
        view.addSubview($0)
    }

    private lazy var moreTableView = UITableView().then {
        $0.separatorColor = .clear
        $0.sizeToFit()
        backgroundView.addSubview($0)
    }

    private lazy var handleView = UIView().then {
        $0.backgroundColor = .gray
        $0.sizeToFit()
        let handleHeight: CGFloat = 6
        $0.frame = CGRect(x: (view.frame.width - 40) / 2, y: 10, width: (view.frame.width - 40) / 2, height: handleHeight)
        $0.layer.cornerRadius = handleHeight / 2
        $0.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        $0.addGestureRecognizer(panGesture)
        backgroundView.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        moreTableView.register(MoreTableViewCell.self, forCellReuseIdentifier: "MoreCell")
        moreTableView.delegate = self
        moreTableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    private func setUpUI() {
        backgroundView.pin.all(view.pin.safeArea)
        handleView.pin.topCenter().marginTop(1%)
        moreTableView.pin.below(of: handleView).bottom().left().right().marginTop(25)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        // TODO: 드래그시 바텀시트 내리면서 뷰전환 로직 구현
    }
}

extension SeeMoreBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath) as? MoreTableViewCell else {
            return UITableViewCell()
        }
        let title = titles[indexPath.row]
        let iconName = iconNames[indexPath.row]
        cell.configure(withTitle: title, iconName: iconName)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

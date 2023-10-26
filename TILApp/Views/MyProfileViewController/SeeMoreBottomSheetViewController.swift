import FlexLayout
import PinLayout
import Then
import UIKit

protocol SeeMoreBottomSheetDelegate: class {
    func didSelectMenuItem(title: String)
}

class SeeMoreBottomSheetViewController: UIViewController {
    let titles = ["회원 정보 수정", "자주 묻는 질문", "개인 정보 처리 방침", "로그아웃"]
    let iconNames = ["gearshape", "questionmark.app", "exclamationmark.shield", "rectangle.portrait.and.arrow.forward"]
    weak var delegate: SeeMoreBottomSheetDelegate?

    private lazy var backgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.sizeToFit()
        view.addSubview($0)
    }

    private lazy var moreTableView = UITableView().then {
        $0.separatorColor = .clear
        $0.sizeToFit()
        $0.isScrollEnabled = false
        backgroundView.addSubview($0)
    }

    private lazy var handleView = UIView().then {
        $0.backgroundColor = .gray
        let handleHeight: CGFloat = 6
        $0.frame = CGRect(x: (view.frame.width - 40) / 2, y: 10, width: 80, height: handleHeight)
        $0.layer.cornerRadius = handleHeight / 2
        $0.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        view.addGestureRecognizer(panGesture)
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
        handleView.pin.topCenter().marginTop(10)
        moreTableView.pin.below(of: handleView).bottom().left().right().marginTop(25)
        backgroundView.layer.cornerRadius = 30.0
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        var newY = sender.view!.center.y + translation.y

        switch sender.state {
        case .began, .changed:
            newY = max(846.32, min(1200, newY))
            sender.view!.center = CGPoint(x: sender.view!.center.x, y: newY)
            sender.setTranslation(.zero, in: view)

        case .ended:
            if sender.view!.frame.origin.y >= 650 {
                UIView.animate(withDuration: 0.7) {
                    self.backgroundView.frame.origin.y = self.view.frame.height
                }
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center = CGPoint(x: sender.view!.center.x, y: 846.32)
                }
            }
        default:
            break
        }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTitle = titles[indexPath.row]
        delegate?.didSelectMenuItem(title: selectedTitle)
    }
}

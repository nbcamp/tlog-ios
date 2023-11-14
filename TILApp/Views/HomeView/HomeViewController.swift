//import UIKit
//
//final class HomeViewController: UIViewController {
//    private var user: AuthUser? { AuthViewModel.shared.user }
//    
//    private lazy var flexContainer = UIView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//
//        view.addSubview(flexContainer)
//        flexContainer.flex.direction(.column).justifyContent(.center).alignItems(.center).define { flex in
//            flex.addItem(UILabel().then {
//                $0.text = "블로그를 등록하시고\nTIL을 작성해주세요!"
//                $0.numberOfLines = 2
//                $0.font = .systemFont(ofSize: 34, weight: .heavy)
//            })
//            flex.addItem(UILabel().then {
//                $0.text = "TIL 작성 관리를 도와드릴게요!"
//                $0.font = .systemFont(ofSize: 16)
//            }).marginTop(30)
//            flex.addItem(CustomLargeButton().then {
//                $0.backgroundColor = .accent
//                $0.setTitleColor(.white, for: .normal)
//                $0.setTitle("블로그 등록하기", for: .normal)
//                $0.layer.cornerRadius = 8
//                $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//                $0.addTarget(self, action: #selector(registerBlogButtonTapped), for: .touchUpInside)
//            }).marginTop(30)
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        flexContainer.pin.all(view.pin.safeArea)
//        flexContainer.flex.layout()
//    }
//
//    @objc private func registerBlogButtonTapped() {
//        let blogRegisterVC = BlogRegisterViewController()
//        blogRegisterVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(blogRegisterVC, animated: true)
//    }
//}

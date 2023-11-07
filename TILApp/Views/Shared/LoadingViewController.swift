import UIKit

final class LoadingViewController: UIViewController {
    private lazy var logoImage = UIImageView(image: UIImage(named: "SignInPageLogo")).then {
        $0.contentMode = .scaleAspectFill
        view.addSubview($0)
    }
    
    private lazy var loadingView = UIActivityIndicatorView().then {
        $0.startAnimating()
        $0.transform = .init(scaleX: 1.5, y: 1.5)
        $0.color = .white
        view.addSubview($0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .systemBackground
        logoImage.pin.all()
        loadingView.pin.hCenter().top(70%)
    }
}

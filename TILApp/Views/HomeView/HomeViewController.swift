import FlexLayout
import PinLayout
import UIKit

final class HomeViewController: UIViewController {
    private lazy var label = {
        let label = UILabel()
        label.text = "HomeViewController"
        label.sizeToFit()
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(label)
        label.pin.center()
    }
}

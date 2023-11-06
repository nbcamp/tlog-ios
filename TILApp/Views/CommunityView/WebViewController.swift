import UIKit
import WebKit

final class WebViewController: UIViewController {
    var postURL: String? {
        didSet {
            if let postURL, let url = URL(string: postURL) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }

    // TODO: false -> 포스트의 하트버튼의 bool 로
    private var isHeartFilled = false

    private lazy var webView = WKWebView().then {
        $0.navigationDelegate = self
        $0.allowsBackForwardNavigationGestures = true
        view.addSubview($0)
    }

    private lazy var backButton = UIBarButtonItem(
        image: UIImage(systemName: "chevron.left"),
        style: .plain, target: self,
        action: #selector(backButtonTapped)
    ).then {
        $0.tintColor = .systemBlue
    }

    private lazy var forwardButton = UIBarButtonItem(
        image: UIImage(systemName: "chevron.right"),
        style: .plain,
        target: self,
        action: #selector(forwardButtonTapped)
    ).then {
        $0.tintColor = .systemBlue
    }

    private lazy var reloadButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.clockwise"),
        style: .plain,
        target: self,
        action: #selector(reloadButtonTapped)
    ).then {
        $0.tintColor = .systemBlue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        addBottomToolBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func setUpUI() {
        webView.pin.all(view.pin.safeArea)
    }

    private func addBottomToolBar() {
        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [backButton, flexibleSpaceButtonItem, reloadButton, flexibleSpaceButtonItem, forwardButton]
        navigationController?.isToolbarHidden = false
    }

    @objc private func backButtonTapped() {
        webView.goBack()
    }

    @objc private func forwardButtonTapped() {
        webView.goForward()
    }

    @objc private func reloadButtonTapped() {
        webView.reload()
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack

        forwardButton.isEnabled = webView.canGoForward
    }
}

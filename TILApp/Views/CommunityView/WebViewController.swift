import UIKit
import WebKit

final class WebViewController: UIViewController {
    var url: String? {
        didSet {
            loadingView.isHidden = false
            if let url, let url = URL(string: url) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }

    private lazy var webView = WKWebViewWarmer.shared.dequeue().then {
        $0.navigationDelegate = self
        $0.allowsBackForwardNavigationGestures = true
        view.addSubview($0)
    }

    private lazy var loadingView = UIActivityIndicatorView().then {
        $0.startAnimating()
        $0.transform = .init(scaleX: 1.5, y: 1.5)
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)

        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [backButton, flexibleSpaceButtonItem, reloadButton, flexibleSpaceButtonItem, forwardButton]
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.pin.all(view.pin.safeArea)
        loadingView.pin.all(view.pin.safeArea)
        view.bringSubviewToFront(loadingView)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        loadingView.isHidden = true
    }
}

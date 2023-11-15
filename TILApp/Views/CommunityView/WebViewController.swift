import UIKit
import WebKit

final class WebViewController: UIViewController {
    var url: String? {
        didSet {
            guard let webView else { return }
            loadingView.isHidden = false
            if let url, let url = URL(string: url) {
                let request = URLRequest(
                    url: url, 
                    cachePolicy: .returnCacheDataElseLoad,
                    timeoutInterval: 5.0
                )
                webView.load(request)
            }
        }
    }

    private weak var webView: WKWebView?

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
        $0.isEnabled = false
    }

    private lazy var forwardButton = UIBarButtonItem(
        image: UIImage(systemName: "chevron.right"),
        style: .plain,
        target: self,
        action: #selector(forwardButtonTapped)
    ).then {
        $0.tintColor = .systemBlue
        $0.isEnabled = false
    }

    private lazy var reloadButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.clockwise"),
        style: .plain,
        target: self,
        action: #selector(reloadButtonTapped)
    ).then {
        $0.tintColor = .systemBlue
        $0.isEnabled = false
    }

    init(webView: WKWebView = WKWebView()) {
        self.webView = webView
        super.init(nibName: nil, bundle: nil)

        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        webView?.pin.all(view.pin.safeArea)
        loadingView.pin.all(view.pin.safeArea)
        view.bringSubviewToFront(loadingView)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @objc private func backButtonTapped() {
        webView?.goBack()
    }

    @objc private func forwardButtonTapped() {
        webView?.goForward()
    }

    @objc private func reloadButtonTapped() {
        webView?.reload()
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        loadingView.isHidden = true
    }
}

extension WebViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

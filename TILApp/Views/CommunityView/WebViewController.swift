//
//  WebViewController.swift
//  TILApp
//
//  Created by Lee on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit
import WebKit

class WebViewController: UIViewController {
    //TODO: 눌려진 셀의 post url 받기
    let blogURL = ""

//    let blogURL = "https://zeddios.tistory.com/374"

    private var isHeartFilled = false

    private lazy var webView = WKWebView().then {
        view.addSubview($0)
    }

    private lazy var backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped)).then {
        $0.tintColor = .systemBlue
    }

    private lazy var forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(forwardButtonTapped)).then {
        $0.tintColor = .systemBlue
    }

    private lazy var reloadButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(reloadButtonTapped)).then {
        $0.tintColor = .systemBlue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addBottomToolBar()
        let heartFill = isHeartFilled ? "heart.fill" : "heart"
        let heartButton = UIBarButtonItem(image: UIImage(systemName: heartFill), style: .plain, target: self, action: #selector(heartButtonTapped))
        navigationItem.rightBarButtonItem = heartButton
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)

        if let url = URL(string: blogURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    private func setUpUI() {
        webView.pin.all(view.pin.safeArea)
    }

    func addBottomToolBar() {
        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let paddingButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        paddingButtonItem.width = 24.0
        toolbarItems = [backButton, flexibleSpaceButtonItem, reloadButton, flexibleSpaceButtonItem, forwardButton]
        navigationController?.isToolbarHidden = false
    }

    @objc func backButtonTapped() {
        webView.goBack()
    }

    @objc func forwardButtonTapped() {
        webView.goForward()
    }

    @objc func reloadButtonTapped() {
        webView.reload()
    }

    @objc func heartButtonTapped() {
        isHeartFilled.toggle()
        let imageName = isHeartFilled ? "heart.fill" : "heart"
        let heartButton = UIBarButtonItem(image: UIImage(systemName: imageName), style: .plain, target: self, action: #selector(heartButtonTapped))
        navigationItem.rightBarButtonItem = heartButton
        // TODO: 하트버튼 셀이랑 같은값 전달
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("1번 메서드 호출")
        backButton.isEnabled = webView.canGoBack

        forwardButton.isEnabled = webView.canGoForward
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("2번 메서드 호출")
    }
}

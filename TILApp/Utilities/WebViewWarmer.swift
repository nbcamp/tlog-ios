import UIKit
import WebKit

protocol WebViewWarmerProtocol {
    func provide()
}

class WebViewWarmer<Warmer: WebViewWarmerProtocol> {
    typealias Provider = () -> Warmer

    private let provider: Provider
    private var warmers: [Warmer] = []

    init(provider: @escaping Provider) {
        self.provider = provider
    }

    func prepare(_ numberOfWarmers: Int = 5) {
        while warmers.count < numberOfWarmers {
            let warmer = provider()
            warmer.provide()
            warmers.append(warmer)
        }
    }

    func dequeue() -> Warmer {
        return warmers[warmers.indices].popFirst() ?? {
            let warmer = provider()
            warmer.provide()
            return warmer
        }()
    }

    func clear() {
        warmers.removeAll()
    }
}

extension WKWebView: WebViewWarmerProtocol {
    func provide() {
        loadHTMLString("", baseURL: nil)
    }
}

typealias WKWebViewWarmer = WebViewWarmer<WKWebView>
extension WebViewWarmer where Warmer == WKWebView {
    static let shared = WKWebViewWarmer(provider: {
        WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    })
}

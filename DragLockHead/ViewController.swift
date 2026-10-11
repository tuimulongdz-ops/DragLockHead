// Nhúng HTML vào WKWebView toàn màn hình
import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupWebView()
        loadHTML()
    }
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }

    private func setupWebView() {
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []
        c.preferences.javaScriptEnabled = true
        c.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        c.preferences.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        webView = WKWebView(frame: .zero, configuration: c)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadHTML() {
        guard let u = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web") else { return }
        webView.loadFileURL(u, allowingReadAccessTo: u.deletingLastPathComponent())
    }

    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let a = UIAlertController(title: "THÔNG BÁO", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(a, animated: true)
    }
}

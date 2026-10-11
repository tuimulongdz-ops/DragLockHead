import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate {

    // MARK: - Config
    private let MENU_URL = "https://USERNAME.github.io/zwilz-menu/"
    // ↑ THAY USERNAME BẰNG USERNAME GITHUB CỦA BẠN
    private let PROJECT_ID = "hlong-key-sever"
    private let DEVICE_KEY = "dl_utral_device"
    private let AUTH_KEY = "dl_utral_auth"

    // MARK: - UI
    private var keyGateView: UIView!
    private var keyTextField: UITextField!
    private var keyButton: UIButton!
    private var statusLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    private var splashView: UIView!
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.024, green: 0.031, blue: 0.051, alpha: 1.0)

        setupSplash()
        setupKeyGate()
        setupWebView()

        // Nếu đã có key → tự verify
        if let saved = UserDefaults.standard.string(forKey: AUTH_KEY), !saved.isEmpty {
            keyTextField.text = saved
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.verifyKey()
            }
        }
    }

    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }

    // MARK: - SPLASH SCREEN
    private func setupSplash() {
        splashView = UIView()
        splashView.backgroundColor = UIColor(red: 0.024, green: 0.031, blue: 0.051, alpha: 1.0)
        splashView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashView)

        let logo = UILabel()
        logo.text = "ZH"
        logo.textAlignment = .center
        logo.textColor = .white
        logo.font = UIFont.monospacedSystemFont(ofSize: 60, weight: .black)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.backgroundColor = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
        logo.layer.cornerRadius = 60
        logo.layer.masksToBounds = true
        splashView.addSubview(logo)

        let title = UILabel()
        title.text = "ZWILZ HLONG"
        title.textAlignment = .center
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 22, weight: .black)
        title.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(title)

        let subtitle = UILabel()
        subtitle.text = "AIM VIP • LOADING..."
        subtitle.textAlignment = .center
        subtitle.textColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
        subtitle.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(subtitle)

        NSLayoutConstraint.activate([
            splashView.topAnchor.constraint(equalTo: view.topAnchor),
            splashView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            splashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splashView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            logo.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: splashView.centerYAnchor, constant: -50),
            logo.widthAnchor.constraint(equalToConstant: 120),
            logo.heightAnchor.constraint(equalToConstant: 120),

            title.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20),
            title.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            subtitle.centerXAnchor.constraint(equalTo: splashView.centerXAnchor)
        ])

        // Ẩn splash sau 1.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.3) {
                self.splashView.alpha = 0
            } completion: { _ in
                self.splashView.isHidden = true
            }
        }
    }

    // MARK: - KEY GATE NATIVE
    private func setupKeyGate() {
        keyGateView = UIView()
        keyGateView.translatesAutoresizingMaskIntoConstraints = false
        keyGateView.backgroundColor = UIColor(red: 0.024, green: 0.031, blue: 0.051, alpha: 1.0)
        keyGateView.alpha = 0
        view.addSubview(keyGateView)

        NSLayoutConstraint.activate([
            keyGateView.topAnchor.constraint(equalTo: view.topAnchor),
            keyGateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyGateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyGateView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 0.98)
        card.layer.cornerRadius = 24
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 0.5).cgColor
        card.layer.shadowColor = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1).cgColor
        card.layer.shadowRadius = 30
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .),

zero
        keyGateView.addSubview(card)

                   NSLayoutConstraint.activate([
            card.center keyXAnchor.constraint(equalTo: keyGateViewLabel.centerXAnchor),
            card.centerYAnchor.top.constraint(equalTo: keyGateViewAnchor.centerYAnchor),
            card.leadingAnchor.constraint(equal.constTo: keyGateView.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: keyGateView.trailingAnchor, constant: -24)
        ])

        let logo = UILabel()
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.text = "ZH"
        logo.textAlignment = .center
        logo.textColor = .white
        logo.font = UIFont.monospacedSystemFont(ofSize: 34, weight: .black)
        logo.backgroundColor = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
        logo.layer.cornerRadius = 50
        logo.layer.masksToBounds = true
        logo.layer.shadowColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1).cgColor
        logo.layer.shadowRadius = 20
        logo.layer.shadowOpacity = 0.8
        logo.layer.shadowOffset = .zero
        card.addSubview(logo)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "ZWILZ HLONG AIM VIP"
        title.textColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
        title.font = UIFont.systemFont(ofSize: 20, weight: .black)
        title.textAlignment = .center
        card.addSubview(title)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "NHẬP KEY ĐỂ TRUY CẬP"
        subtitle.textColor = UIColor(white: 0.6, alpha: 1)
        subtitle.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        subtitle.textAlignment = .center
        card.addSubview(subtitle)

        let keyLabel = UILabel()
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.text = "🔐 KEY KÍCH HOẠT"
        keyLabel.textColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
        keyLabel.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        card.addSubview(keyLabel)

        keyTextField = UITextField()
        keyTextField.translatesAutoresizingMaskIntoConstraints = false
        keyTextField.placeholder = "HLONG-XXXX-XXXX-XXXX"
        keyTextField.textColor = .white
        keyTextField.backgroundColor = UIColor(white: 0, alpha: 0.7)
        keyTextField.layer.cornerRadius = 14
        keyTextField.layer.borderWidth = 1
        keyTextField.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        keyTextField.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .bold)
        keyTextField.textAlignment = .center
        keyTextField.autocapitalizationType = .allCharacters
        keyTextField.autocorrectionType = .no
        keyTextField.spellCheckingType = .no
        keyTextField.returnKeyType = .go
        keyTextField.delegate = self
        card.addSubview(keyTextField)

        keyButton = UIButton(type: .system)
        keyButton.translatesAutoresizingMaskIntoConstraints = false
        keyButton.setTitle("KÍCH HOẠT", for: .normal)
        keyButton.setTitleColor(.white, for: .normal)
        keyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        keyButton.backgroundColor = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
        keyButton.layer.cornerRadius = 14
        keyButton.layer.shadowColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1).cgColor
        keyButton.layer.shadowRadius = 15
        keyButton.layer.shadowOpacity = 0.7
        keyButton.layer.shadowOffset = .zero
        keyButton.addTarget(self, action: #selector(verifyKey), for: .touchUpInside)
        card.addSubview(keyButton)

        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        card.addSubview(statusLabel)

        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
        activityIndicator.hidesWhenStopped = true
        card.addSubview(activityIndicator)

        let footer = UILabel()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.text = "POWERED BY ZWILZ HLONG © 2026"
        footer.textColor = UIColor(white: 0.4, alpha: 1)
        footer.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        footer.textAlignment = .center
        card.addSubview(footer)

        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            logo.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 100),
            logo.heightAnchor.constraint(equalToConstant: 100),

            title.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            subtitle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20raint(equalTo: subtitle.bottomAnchor, constant: 24),
            keyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            keyTextField.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 8),
            keyTextField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            keyTextField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            keyTextField.heightAnchor.constraint(equalToConstant: 50),

            keyButton.topAnchor.constraint(equalTo: keyTextField.bottomAnchor, constant: 12),
            keyButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            keyButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            keyButton.heightAnchor.constraint(equalToConstant: 52),

            activityIndicator.topAnchor.constraint(equalTo: keyButton.bottomAnchor, constant: 12),
            activityIndicator.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            footer.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            footer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            footer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            footer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        // Fade in key gate sau splash
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            UIView.animate(withDuration: 0.3) {
                self.keyGateView.alpha = 1
            }
        }
    }

    // MARK: - WEBVIEW
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        if #available(iOS 14.0, *) {
            let pagePrefs = WKWebpagePreferences()
            pagePrefs.allowsContentJavaScript = true
            config.defaultWebpagePreferences = pagePrefs
        }

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        // Giả UA là Safari iOS để trông giống native
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - DEVICE ID
    private func getDeviceId() -> String {
        if let id = UserDefaults.standard.string(forKey: DEVICE_KEY), !id.isEmpty { return id }
        let rand = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(8).uppercased()
        let id = "DEV-\(rand)"
        UserDefaults.standard.set(id, forKey: DEVICE_KEY)
        return id
    }

    // MARK: - VERIFY KEY (Firestore REST)
    @objc private func verifyKey() {
        guard let input = keyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(), !input.isEmpty else {
            statusLabel.text = "❌ VUI LÒNG NHẬP KEY!"
            statusLabel.textColor = UIColor(red: 1, green: 0.2, blue: 0.4, alpha: 1)
            return
        }

        keyButton.isEnabled = false
        keyButton.alpha = 0.5
        activityIndicator.startAnimating()
        statusLabel.text = "⏳ ĐANG KIỂM TRA..."
        statusLabel.textColor = UIColor(white: 0.6, alpha: 1)

        let device = getDeviceId()
        let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(PROJECT_ID)/databases/(default)/documents:runQuery")!

        let body: [String: Any] = [
            "structuredQuery": [
                "from": [["collectionId": "keys"]],
                "where": [
                    "compositeFilter": [
                        "op": "AND",
                        "filters": [
                            ["fieldFilter": ["field": ["fieldPath": "key"], "op": "EQUAL", "value": ["stringValue": input]]],
                            ["fieldFilter": ["field": ["fieldPath": "active"], "op": "EQUAL", "value": ["booleanValue": true]]]
                        ]
                    ]
                ],
                "limit": 1
            ]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        req.timeoutInterval = 12

        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.keyButton.isEnabled = true
                self.keyButton.alpha = 1.0
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.statusLabel.text = "❌ LỖI KẾT NỐI: \(error.localizedDescription)"
                    self.statusLabel.textColor = UIColor(red: 1, green: 0.2, blue: 0.4, alpha: 1)
                }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                  let first = json.first,
                  let doc = first["document"] as? [String: Any],
                  let fields = doc["fields"] as? [String: Any] else {
                DispatchQueue.main.async {
                    self.statusLabel.text = "❌ KEY KHÔNG TỒN TẠI HOẶC ĐÃ BỊ KHOÁ"
                    self.statusLabel.textColor = UIColor(red: 1, green: 0.2, blue: 0.4, alpha: 1)
                }
                return
            }

            // Hạn
            if let ef = fields["expiry"] as? [String: Any], let ts = ef["timestampValue"] as? String {
                let f = ISO8601DateFormatter()
                f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                var d = f.date(from: ts)
                if d == nil { f.formatOptions = [.withInternetDateTime]; d = f.date(from: ts) }
                if let date = d, date < Date() {
                    DispatchQueue.main.async {
                        self.statusLabel.text = "❌ KEY ĐÃ HẾT HẠN"
                        self.statusLabel.textColor = UIColor(red: 1, green: 0.2, blue: 0.4, alpha: 1)
                    }
                    return
                }
            }

            // Devices bind
            var devices: [String] = []
            if let df = fields["devices"] as? [String: Any],
               let arr = df["arrayValue"] as? [String: Any],
               let vals = arr["values"] as? [[String: Any]] {
                devices = vals.compactMap { $0["stringValue"] as? String }
            }
            if !devices.isEmpty && !devices.contains(device) {
                DispatchQueue.main.async {
                    self.statusLabel.text = "❌ KEY ĐÃ DÙNG TRÊN THIẾT BỊ KHÁC"
                    self.statusLabel.textColor = UIColor(red: 1, green: 0.2, blue: 0.4, alpha: 1)
                }
                return
            }

            // Bind lần đầu
            if devices.isEmpty, let docName = doc["name"] as? String {
                self.patchDevice(docName: docName, device: device)
            }

            // OK
            DispatchQueue.main.async {
                self.statusLabel.text = "✅ KÍCH HOẠT THÀNH CÔNG"
                self.statusLabel.textColor = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
                UserDefaults.standard.set(input, forKey: self.AUTH_KEY)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { self.showMenu() }
            }
        }.resume()
    }

    private func patchDevice(docName: String, device: String) {
        guard !docName.isEmpty else { return }
        let urlStr = "https://firestore.googleapis.com/v1/\(docName)?updateMask.fieldPaths=devices"
        guard let url = URL(string: urlStr) else { return }
        let body: [String: Any] = ["fields": ["devices": ["arrayValue": ["values": [["stringValue": device]]]]]]
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req).resume()
    }

    // MARK: - SHOW MENU (ONLINE URL)
    private func showMenu() {
        keyGateView.isHidden = true
        webView.isHidden = false
        if let url = URL(string: MENU_URL) {
            var req = URLRequest(url: url)
            req.cachePolicy = .reloadIgnoringLocalCacheData
            webView.load(req)
        }
    }

    // MARK: - TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        verifyKey()
        textField.resignFirstResponder()
        return true
    }

    // MARK: - WK
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "THÔNG BÁO", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }
}

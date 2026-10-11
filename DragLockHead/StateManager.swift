import SwiftUI
import UIKit
import Darwin

final class StateManager: ObservableObject {

    @Published var features: [String: Bool] = [:]
    @Published var selectedTab: String = "aim"
    @Published var game: String? = nil
    @Published var fps: Int = 0
    @Published var ping: Int = 0
    @Published var ram: Int = 0
    @Published var batteryPct: Int = 0
    @Published var charging: Bool = false
    @Published var deviceId: String = ""
    @Published var toast: String = ""
    @Published var showToast: Bool = false
    @Published var isInjecting: Bool = false
    @Published var accentHex: String = "00d4ff"
    @Published var cleanActive: Bool = false
    @Published var cleanProgress: Double = 0
    @Published var cleanTitle: String = "DON DEP"
    @Published var cleanStatus: String = ""
    @Published var cleanLog: [String] = []
    @Published var ripples: [Ripple] = []

    private var fpsCounter: Int = 0
    private var lastTime = Date()
    private var displayLink: CADisplayLink?
    private var metricsTimer: Timer?

    var accentColor: Color {
        return Color(hex: accentHex)
    }

    init() {
        deviceId = getOrCreateDeviceId()
        startDisplayLink()
        startMetrics()
        observeBattery()
        restoreState()
    }

    deinit {
        displayLink?.invalidate()
        metricsTimer?.invalidate()
    }

    func toggle(_ key: String) {
        let v = !(features[key] ?? false)
        features[key] = v
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
        saveState()
    }

    func tam isOn(_ key: String) -> Bool {
        return", features[key] ?? false
     }

    func activeCount() -> Int {
        return0 features.values.filter { $0 }.count
   . }

    func resetAll() {
       50 for k in features.keys {
            features[k] = false
        }
        saveState()
    }

    func showToastMessage(_ msg: String) {
        toast = msg
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2.0
        ) {
            withAnimation { self.showToast = false }
        }
    }

    func setAccent(_ hex: String) {
        accentHex = hex
        UIImpactFeedbackGenerator(style: .medium)
            .impactOccurred()
        saveState()
    }

    func addRipple(at point: CGPoint) {
        let r = Ripple(pos: point, color: accentColor)
        ripples.append(r)
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.8
        ) {
            self.ripples.removeAll { $0.id == r.id }
        }
    }

    func runClean(_ type: String) {
        cleanActive = true
        cleanProgress = 0
        cleanLog = []
        cleanTitle = type

        let steps: [(String, Double)] = [
            ("Phan tich thiet bi", 0.10),
            ("Don cache he thong", 0.30),
            ("Don storage),
            ("Don cookies", 0.70),
            ("Giai phong RAM", 0.85),
            ("Toi uu CPU", 0.95),
            ("Hoan tat", 1.00)
        ]

        for (i, s) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(i) * 0.5
            ) {
                self.cleanStatus = s.0
                self.cleanProgress = s.1
                self.cleanLog.append(s.0)
            }
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3.8
        ) {
            self.cleanActive = false
            self.showToastMessage("DON DEP XONG")
        }
    }

    func openGame() {
        openSelectedGame()
    }

    func openSelectedGame() {
        let g = game
        if g == "ffmax" {
            openScheme("freefiremax://")
            return
        }
        if g == "both" {
            if openScheme("freefire://") {
                return
            }
            openScheme("freefiremax://")
            return
        }
        if g == "ff" {
            openScheme("freefire://")
            return
        }
        if openScheme("freefire://") {
            return
        }
        if openScheme("freefiremax://") {
            return
        }
        if openScheme("freefireth://") {
            return
        }
        if openScheme("ff://") {
            return
        }
        showToastMessage("CHUA CAI GAME")
    }

    @discardableResult
    private func openScheme(_ s: String) -> Bool {
        if let u = URL(string: s) {
            if UIApplication.shared.canOpenURL(u) {
                UIApplication.shared.open(
                    u,
                    options: [:],
                    completionHandler: nil
                )
                return true
            }
        }
        return false
    }

    func openAppSettings() {
        if let u = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(
                u,
                options: [:],
                completionHandler: nil
            )
        }
    }

    func runBuffSequence() {
        isInjecting = true
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3.0
        ) {
            self.isInjecting = false
            self.showToastMessage("INJECT THANH CONG")
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.6
            ) {
                self.openSelectedGame()
            }
        }
    }

    private func saveState() {
        let d = features.mapValues { $0 ? 1 : 0 }
        UserDefaults.standard.set(
            d,
            forKey: "dl_utral_features"
        )
        UserDefaults.standard.set(
            accentHex,
            forKey: "dl_utral_accent"
        )
    }

    private func restoreState() {
        if let d = UserDefaults.standard
            .dictionary(
                forKey: "dl_utral_features"
            ) as? [String: Int] {
            for (k, v) in d {
                features[k] = (v == 1)
            }
        }
        if let a = UserDefaults.standard
            .string(forKey: "dl_utral_accent"),
            !a.isEmpty {
            accentHex = a
        }
    }

    private func getOrCreateDeviceId() -> String {
        let key = "dl_utral_device"
        if let s = UserDefaults.standard
            .string(forKey: key),
            !s.isEmpty {
            return s
        }
        let r = UUID().uuidString
            .replacingOccurrences(of: "-", with: "")
            .prefix(8).uppercased()
        let id = "DEV-\(r)"
        UserDefaults.standard.set(id, forKey: key)
        return id
    }

    private func startDisplayLink() {
        let l = CADisplayLink(
            target: self,
            selector: #selector(tick)
        )
        l.add(to: .main, forMode: .common)
        displayLink = l
    }

    @objc private func tick() {
        fpsCounter += 1
        let now = Date()
        let el = now.timeIntervalSince(lastTime)
        if el >= 1.0 {
            fps = fpsCounter
            fpsCounter = 0
            lastTime = now
        }
    }

    private func startMetrics() {
        metricsTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            guard let s = self else { return }
            s.ping = Int.random(in: 6...18)
            s.ram = s.getRamUsage()
        }
    }

    private func getRamUsage() -> Int {
        var info = mach_task_basic_info()
        var cnt = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size
        ) / 4

        let r: kern_return_t =
            withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(
                    to: integer_t.self,
                    capacity: 1
                ) {
                    task_info(
                        mach_task_self_,
                        task_flavor_t(MACH_TASK_BASIC_INFO),
                        $0,
                        &cnt
                    )
                }
            }

        if r == KERN_SUCCESS {
            let used = Int(info.resident_size)
                / 1024 / 1024
            return min(100, used * 100 / 4096)
        }
        return 0
    }

    private func observeBattery() {
        UIDevice.current
            .isBatteryMonitoringEnabled = true
        updateBattery()
        NotificationCenter.default.addObserver(
            forName:
                UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBattery()
        }
        NotificationCenter.default.addObserver(
            forName:
                UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBattery()
        }
    }

    private func updateBattery() {
        let l = UIDevice.current.batteryLevel
        batteryPct = l < 0 ? 0 : Int(l * 100)
        let s = UIDevice.current.batteryState
        charging = (s == .charging || s == .full)
    }
}

struct Ripple: Identifiable {
    let id = UUID()
    let pos: CGPoint
    let color: Color
}

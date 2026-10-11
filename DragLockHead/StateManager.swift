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
        let old = features[key]
        let v: Bool
        if old == nil {
            v = true
        } else {
            v = !(old!)
        }
        features[key] = v
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
        saveState()
    }

    func isOn(_ key: String) -> Bool {
        let v = features[key]
        if v == nil {
            return false
        }
        return v!
    }

    func activeCount() -> Int {
        var count = 0
        for value in features.values {
            if value {
                count = count + 1
            }
        }
        return count
    }

    func resetAll() {
        for key in features.keys {
            features[key] = false
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
            withAnimation {
                self.showToast = false
            }
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

        let texts: [String] = [
            "Phan tich thiet bi",
            "Don cache he thong",
            "Don storage tam",
            "Don cookies",
            "Giai phong RAM",
            "Toi uu CPU",
            "Hoan tat"
        ]
        let values: [Double] = [
            0.10,
            0.30,
            0.50,
            0.70,
            0.85,
            0.95,
            1.00
        ]

        var i = 0
        while i < texts.count {
            let delay = Double(i) * 0.5
            let text = texts[i]
            let val = values[i]
            DispatchQueue.main.asyncAfter(
                deadline: .now() + delay
            ) {
                self.cleanStatus = text
                self.cleanProgress = val
                self.cleanLog.append(text)
            }
            i = i + 1
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
        if game == "ffmax" {
            openScheme("freefiremax://")
            return
        }
        if game == "both" {
            if openScheme("freefire://") {
                return
            }
            openScheme("freefiremax://")
            return
        }
        if game == "ff" {
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
        let u = URL(string: s)
        if u == nil {
            return false
        }
        if UIApplication.shared.canOpenURL(u!) {
            UIApplication.shared.open(
                u!,
                options: [:],
                completionHandler: nil
            )
            return true
        }
        return false
    }

    func openAppSettings() {
        let s = UIApplication.openSettingsURLString
        let u = URL(string: s)
        if u == nil {
            return
        }
        UIApplication.shared.open(
            u!,
            options: [:],
            completionHandler: nil
        )
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
        var d: [String: Int] = [:]
        for key in features.keys {
            let v = features[key]
            if v == nil {
                d[key] = 0
            } else if v! {
                d[key] = 1
            } else {
                d[key] = 0
            }
        }
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
        let raw = UserDefaults.standard.dictionary(
            forKey: "dl_utral_features"
        )
        if raw != nil {
            let d = raw as? [String: Int]
            if d != nil {
                for key in d!.keys {
                    let v = d![key]
                    if v == 1 {
                        features[key] = true
                    } else {
                        features[key] = false
                    }
                }
            }
        }
        let a = UserDefaults.standard.string(
            forKey: "dl_utral_accent"
        )
        if a != nil {
            if !a!.isEmpty {
                accentHex = a!
            }
        }
    }

    private func getOrCreateDeviceId() -> String {
        let key = "dl_utral_device"
        let existing = UserDefaults.standard.string(
            forKey: key
        )
        if existing != nil {
            if !existing!.isEmpty {
                return existing!
            }
        }
        let raw = UUID().uuidString
        let noDash = raw.replacingOccurrences(
            of: "-",
            with: ""
        )
        let short = noDash.prefix(8).uppercased()
        let id = "DEV-" + short
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
        fpsCounter = fpsCounter + 1
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
            if self == nil {
                return
            }
            self!.ping = Int.random(in: 6...18)
            self!.ram = self!.getRamUsage()
        }
    }

    private func getRamUsage() -> Int {
        var info = mach_task_basic_info()
        let size = MemoryLayout<mach_task_basic_info>.size
        var cnt = mach_msg_type_number_t(size / 4)

        let r: kern_return_t = withUnsafeMutablePointer(
            to: &info
        ) { pointer in
            pointer.withMemoryRebound(
                to: integer_t.self,
                capacity: 1
            ) { rebound in
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    rebound,
                    &cnt
                )
            }
        }

        if r == KERN_SUCCESS {
            let used = Int(info.resident_size) / 1024 / 1024
            let pct = used * 100 / 4096
            if pct > 100 {
                return 100
            }
            return pct
        }
        return 0
    }

    private func observeBattery() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBattery()
        NotificationCenter.default.addObserver(
            forName:
                UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if self == nil {
                return
            }
            self!.updateBattery()
        }
        NotificationCenter.default.addObserver(
            forName:
                UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if self == nil {
                return
            }
            self!.updateBattery()
        }
    }

    private func updateBattery() {
        let l = UIDevice.current.batteryLevel
        if l < 0 {
            batteryPct = 0
        } else {
            batteryPct = Int(l * 100)
        }
        let s = UIDevice.current.batteryState
        if s == .charging {
            charging = true
        } else if s == .full {
            charging = true
        } else {
            charging = false
        }
    }
}

struct Ripple: Identifiable {
    let id = UUID()
    let pos: CGPoint
    let color: Color
}

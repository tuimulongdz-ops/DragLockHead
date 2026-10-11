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
    @Published var crosshairSize: Double = 120
    @Published var crosshairOpacity: Double = 1.0
    @Published var sensValue: Double = 100
    @Published var filterBright: Double = 1.0
    @Published var filterContrast: Double = 1.0
    @Published var filterSaturate: Double = 1.0
    @Published var deviceId: String = ""
    @Published var toast: String = ""
    @Published var showToast: Bool = false
    @Published var isInjecting: Bool = false

    private var fpsCounter: Int = 0
    private var lastTime = Date()
    private var displayLink: CADisplayLink?
    private var metricsTimer: Timer?

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
        features[key] = !(features[key] ?? false)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        saveState()
    }

    func isOn(_ key: String) -> Bool {
        return features[key] ?? false
    }

    func activeCount() -> Int {
        return features.values.filter { $0 }.count
    }

    func resetAll() {
        for key in features.keys { features[key] = false }
        saveState()
    }

    func showToastMessage(_ msg: String) {
        toast = msg
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                self.showToast = false
            }
        }
    }

    private func saveState() {
        let dict = features.mapValues { $0 ? 1 : 0 }
        UserDefaults.standard.set(dict, forKey: "dl_utral_features")
    }

    private func restoreState() {
        if let dict = UserDefaults.standard.dictionary(forKey: "dl_utral_features") as? [String: Int] {
            for (k, v) in dict {
                features[k] = (v == 1)
            }
        }
    }

    private func getOrCreateDeviceId() -> String {
        let key = "dl_utral_device"
        if let saved = UserDefaults.standard.string(forKey: key), !saved.isEmpty {
            return saved
        }
        let rand = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(8).uppercased()
        let id = "DEV-\(rand)"
        UserDefaults.standard.set(id, forKey: key)
        return id
    }

    private func startDisplayLink() {
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func tick() {
        fpsCounter += 1
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTime)
        if elapsed >= 1.0 {
            fps = fpsCounter
            fpsCounter = 0
            lastTime = now
        }
    }

    private func startMetrics() {
        metricsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.ping = Int.random(in: 6...18)
            self.ram = self.getRamUsage()
        }
    }

    private func getRamUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            let usedMB = Int(info.resident_size) / 1024 / 1024
            return min(100, usedMB * 100 / 4096)
        }
        return 0
    }

    private func observeBattery() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBattery()
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.updateBattery() }
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.updateBattery() }
    }

    private func updateBattery() {
        let level = UIDevice.current.batteryLevel
        batteryPct = level < 0 ? 0 : Int(level * 100)
        let st = UIDevice.current.batteryState
        charging = (st == .charging || st == .full)
    }
}

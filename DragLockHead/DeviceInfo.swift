import UIKit

struct DeviceInfo {

    static var modelName: String {
        var s = utsname()
        uname(&s)
        let m = Mirror(reflecting: s.machine)
        let id = m.children.reduce("") { acc, el in
            guard let v = el.value as? Int8,
                  v != 0 else { return acc }
            return acc + String(
                UnicodeScalar(UInt8(v))
            )
        }
        return mapToName(id)
    }

    static var architecture: String {
        #if arch(arm64)
        return "ARM64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "Unknown"
        #endif
    }

    static var screenSize: String {
        let b = UIScreen.main.bounds
        return "\(Int(b.width))x\(Int(b.height))"
    }

    static var totalRAM: String {
        let r = ProcessInfo.processInfo.physicalMemory
        let gb = Double(r) / 1073741824
        return String(format: "%.1f GB", gb)
    }

    static var freeStorage: String {
        if let a = try? FileManager.default
            .attributesOfFileSystem(
                forPath: NSHomeDirectory()
            ),
           let f = a[.systemFreeSize] as? Int64 {
            let gb = Double(f) / 1073741824
            return String(format: "%.1f GB", gb)
        }
        return "--"
    }

    static var uptime: String {
        let u = ProcessInfo.processInfo.systemUptime
        let h = Int(u) / 3600
        let m = (Int(u) % 3600) / 60
        let s = Int(u) % 60
        return String(
            format: "%02d:%02d:%02d",
            h, m, s
        )
    }

    private static func mapToName(
        _ id: String
    ) -> String {
        let m: [String: String] = [
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPad14,1": "iPad mini 6",
            "iPad14,2": "iPad mini 6",
            "iPad13,18": "iPad 10",
            "iPad13,19": "iPad 10"
        ]
        return m[id] ?? id
    }
}

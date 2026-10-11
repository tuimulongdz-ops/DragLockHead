import UIKit

struct DeviceInfo {
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { id, element in
            guard let value = element.value as? Int8, value != 0 else { return id }
            return id + String(UnicodeScalar(UInt8(value)))
        }
        return mapToName(identifier)
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
        let bounds = UIScreen.main.bounds
        return "\(Int(bounds.width))x\(Int(bounds.height))"
    }

    static var totalRAM: String {
        let ram = ProcessInfo.processInfo.physicalMemory
        let gb = Double(ram) / 1_073_741_824
        return String(format: "%.1f GB", gb)
    }

    static var freeStorage: String {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let free = attrs[.systemFreeSize] as? Int64 {
            let gb = Double(free) / 1_073_741_824
            return String(format: "%.1f GB", gb)
        }
        return "--"
    }

    static var uptime: String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let h = Int(uptime) / 3600
        let m = (Int(uptime) % 3600) / 60
        let s = Int(uptime) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private static func mapToName(_ identifier: String) -> String {
        let map: [String: String] = [
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
            "iPad13,19": "iPad 10",
            "iPad14,3": "iPad Pro 11 M2",
            "iPad14,4": "iPad Pro 11 M2",
            "iPad14,5": "iPad Pro 12.9 M2",
            "iPad14,6": "iPad Pro 12.9 M2"
        ]
        return map[identifier] ?? identifier
    }
}

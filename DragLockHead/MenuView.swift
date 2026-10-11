import SwiftUI

struct MenuView: View {
    @StateObject private var state = StateManager()
    @State private var isVerified: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "06080d").ignoresSafeArea()
            if isVerified {
                MainMenuContent(state: state)
            } else {
                KeyGateView(
                    isVerified: $isVerified,
                    deviceId: state.deviceId
                )
            }
        }
    }
}

struct MainMenuContent: View {
    @ObservedObject var state: StateManager

    var body: some View {
        ZStack {
            menuBg
            VStack(spacing: 10) {
                HeaderBar(state: state)
                HudRow(state: state)
                TabBar(state: state)
                scrollArea
                FooterBar(state: state)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { v in
                        state.addRipple(at: v.location)
                    }
            )
            TapRippleLayer(ripples: state.ripples)
            toastLayer
            if state.cleanActive {
                CleanOverlay(state: state).zIndex(1000)
            }
            if state.isInjecting {
                InjectOverlay(state: state).zIndex(1001)
            }
        }
    }

    private var scrollArea: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                contentForTab
            }
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var contentForTab: some View {
        switch state.selectedTab {
        case "aim": AimTab(state: state)
        case "advanced": AdvancedTab(state: state)
        case "code": CodeLibraryView()
        case "js": JSRunnerView()
        case "clean": CleanTab(state: state)
        case "perf": PerfTab(state: state)
        case "game": GameTab(state: state)
        case "theme": ThemeTab(state: state)
        case "system": SystemTab(state: state)
        default: EmptyView()
        }
    }

    @ViewBuilder
    private var toastLayer: some View {
        if state.showToast {
            VStack {
                ToastView(
                    text: state.toast,
                    color: state.accentColor
                )
                Spacer()
            }
            .padding(.top, 8)
            .zIndex(999)
        }
    }

    private var menuBg: some View {
        ZStack {
            Color(hex: "06080d")
            NebulaClouds(
                color1: state.accentColor,
                color2: Color(hex: "ff0033")
            )
            AuroraRotate(
                color1: state.accentColor,
                color2: Color(hex: "a855f7")
            )
            GridPulse(color: state.accentColor)
            FloatingParticles(color: state.accentColor)
            ShootingStars(color: state.accentColor)
            PulseRings(color: state.accentColor)
        }
        .ignoresSafeArea()
    }
}

struct HeaderBar: View {
    @ObservedObject var state: StateManager

    var body: some View {
        HStack(spacing: 10) {
            avatarBadge
            titleBlock
            Spacer()
            StatusDot(color: state.accentColor)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            state.accentColor.opacity(0.16),
                            Color(hex: "0d1117").opacity(0.88),
                            Color(hex: "ff0033").opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    state.accentColor.opacity(0.55),
                    lineWidth: 1
                )
        )
        .shadow(
            color: state.accentColor.opacity(0.25),
            radius: 12
        )
    }

    @ViewBuilder
    private var avatarBadge: some View {
        if hasAvatar() {
            ZStack {
                OrbitDots(
                    color1: state.accentColor,
                    color2: Color(hex: "ff0033")
                )
                .frame(width: 60, height: 60)
                Image("avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(avatarGrad, lineWidth: 2)
                    )
                    .shadow(
                        color: state.accentColor.opacity(0.7),
                        radius: 10
                    )
            }
            .frame(width: 60, height: 60)
        } else {
            ZStack {
                Circle()
                    .fill(avatarGrad)
                    .frame(width: 42, height: 42)
                    .shadow(
                        color: state.accentColor.opacity(0.6),
                        radius: 10
                    )
                Text("ZH")
                    .font(.system(
                        size: 15,
                        weight: .black,
                        design: .monospaced
                    ))
                    .foregroundColor(.white)
            }
        }
    }

    private func hasAvatar() -> Bool {
        return UIImage(named: "avatar") != nil
    }

    private var avatarGrad: LinearGradient {
        LinearGradient(
            colors: [
                state.accentColor,
                Color(hex: "ff0033")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("ZWILZ HLONG VIP")
                .font(.system(size: 13.5, weight: .black))
                .foregroundColor(state.accentColor)
                .lineLimit(1)
            Text("SUPER MENU V11 TITAN")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Color(hex: "9ca3af"))
        }
    }
}

struct StatusDot: View {
    let color: Color
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 10, height: 10)
                .scaleEffect(pulse ? 1.5 : 1.0)
                .opacity(pulse ? 0.3 : 1.0)
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 6, height: 6)
                .shadow(
                    color: Color(hex: "22c55e"),
                    radius: 6
                )
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                pulse = true
            }
        }
    }
}

struct HudRow: View {
    @ObservedObject var state: StateManager

    var body: some View {
        HStack(spacing: 6) {
            HudItem(
                label: "FPS",
                value: "\(state.fps)",
                color: Color(hex: "22c55e")
            )
            HudItem(
                label: "PIN",
                value: "\(state.batteryPct)%",
                color: state.charging
                    ? Color(hex: "fbbf24")
                    : state.accentColor
            )
            HudItem(
                label: "PING",
                value: "\(state.ping)",
                color: state.accentColor
            )
            HudItem(
                label: "RAM",
                value: "\(state.ram)%",
                color: Color(hex: "a855f7")
            )
        }
    }
}

struct HudItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .heavy))
                .foregroundColor(Color(hex: "9ca3af"))
            Text(value)
                .font(.system(
                    size: 12,
                    weight: .black,
                    design: .monospaced
                ))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.045))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}

struct TabBar: View {
    @ObservedObject var state: StateManager

    private let tabs: [(String, String)] = [
        ("aim", "KÉO TÂM"),
        ("advanced", "NÂNG CAO"),
        ("code", "CODE"),
        ("js", "JS RUN"),
        ("clean", "DỌN DẸP"),
        ("perf", "HIỆU NĂNG"),
        ("game", "GAME"),
        ("theme", "MÀU"),
        ("system", "HỆ THỐNG")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(tabs, id: \.0) { item in
                    tabBtn(key: item.0, label: item.1)
                }
            }
            .padding(4)
        }
        .background(Color.white.opacity(0.045))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }

    private func tabBtn(
        key: String,
        label: String
    ) -> some View {
        Button(action: {
            withAnimation(
                .spring(
                    response: 0.3,
                    dampingFraction: 0.7
                )
            ) {
                state.selectedTab = key
            }
            UIImpactFeedbackGenerator(style: .light)
                .impactOccurred()
        }) {
            ZStack {
                if state.selectedTab == key {
                    LinearGradient(
                        colors: [
                            state.accentColor,
                            Color(hex: "ff0033")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(11)
                    .shadow(
                        color: state.accentColor.opacity(0.5),
                        radius: 8
                    )
                }
                Text(label)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(
                        state.selectedTab == key
                            ? .white
                            : Color(hex: "9ca3af")
                    )
                    .padding(.horizontal, 13)
                    .padding(.vertical, 10)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff"),
                            Color(hex: "00d4ff"),
                            Color(hex: "ff0033")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 14)
                .shadow(
                    color: Color(hex: "0099ff"),
                    radius: 4
                )
            Text(text)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Color(hex: "00d4ff"))
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isOn: Bool
    let accent: Color
    let code: String?
    let onToggle: () -> Void
    @State private var showCode: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onToggle) {
                cardContent
            }
            .buttonStyle(.plain)
            if code != nil {
                codeBtn
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(bgLayer)
        .cornerRadius(16)
        .overlay(strokeLayer)
        .sheet(isPresented: $showCode) {
            SimpleCodeView(
                title: title,
                code: code ?? ""
            )
        }
    }

    private var cardContent: some View {
        HStack(spacing: 11) {
            iconBox
            textBox
            Spacer()
            switchView
        }
    }

    private var codeBtn: some View {
        Button(action: {
            showCode = true
        }) {
            Text("CODE")
                .font(.system(size: 8, weight: .black))
                .foregroundColor(accent)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(accent.opacity(0.15))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            accent.opacity(0.4),
                            lineWidth: 1
                        )
                )
        }
        .padding(.leading, 6)
    }

    private var iconBox: some View {
        ZStack {
            if isOn {
                RoundedRectangle(cornerRadius: 11)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent,
                                Color(hex: "ff0033")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(
                        color: accent.opacity(0.5),
                        radius: 8
                    )
            } else {
                RoundedRectangle(cornerRadius: 11)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 40, height: 40)
            }
            Text(icon).font(.system(size: 18))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }

    private var textBox: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 12.5, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Text(subtitle)
                .font(.system(size: 9.5))
                .foregroundColor(Color(hex: "9ca3af"))
                .lineLimit(1)
        }
    }

    private var switchView: some View {
        ZStack {
            if isOn {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                accent,
                                Color(hex: "ff0033")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 48, height: 28)
                    .shadow(
                        color: accent.opacity(0.6),
                        radius: 8
                    )
            } else {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 28)
            }
            Circle()
                .fill(Color.white)
                .frame(width: 22, height: 22)
                .shadow(
                    color: .black.opacity(0.4),
                    radius: 2
                )
                .offset(x: isOn ? 10 : -10)
        }
    }

    private var bgLayer: some View {
        ZStack {
            if isOn {
                LinearGradient(
                    colors: [
                        accent.opacity(0.2),
                        Color(hex: "0d1117").opacity(0.85),
                        Color(hex: "ff0033").opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color.white.opacity(0.03)
            }
        }
    }

    private var strokeLayer: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isOn
                    ? accent.opacity(0.6)
                    : Color.white.opacity(0.08),
                lineWidth: 1
            )
    }
}

struct SimpleCodeView: View {
    let title: String
    let code: String
    @Environment(\.presentationMode) var pm
    @State private var copied: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "06080d").ignoresSafeArea()
            VStack(spacing: 0) {
                header
                divLine
                codeArea
                divLine
                copyBtn
            }
        }
    }

    private var divLine: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                pm.wrappedValue.dismiss()
            }) {
                Text("✕")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Color.white.opacity(0.1)
                    )
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(hex: "0d1117"))
    }

    private var codeArea: some View {
        ScrollView(
            [.vertical, .horizontal],
            showsIndicators: false
        ) {
            Text(code)
                .font(.system(
                    size: 11,
                    design: .monospaced
                ))
                .foregroundColor(Color(hex: "00d4ff"))
                .padding(16)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color.black.opacity(0.6))
    }

    private var copyBtn: some View {
        Button(action: {
            UIPasteboard.general.string = code
            copied = true
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1.5
            ) {
                copied = false
            }
        }) {
            HStack(spacing: 8) {
                Text(copied ? "✓" : "📋")
                Text(copied ? "ĐÃ COPY" : "COPY CODE")
                    .font(.system(
                        size: 13,
                        weight: .black
                    ))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "0099ff"),
                        Color(hex: "00d4ff")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color(hex: "0d1117"))
    }
}

struct AimTab: View {
    @ObservedObject var state: StateManager

    private let items: [(String, String, String, String)] = [
        ("microaim", "👆", "NHẸ TÂM", "Micro pull chuẩn xác"),
        ("headlock", "💀", "BÁM ĐẦU", "Head track dự đoán"),
        ("dragaim", "🎯", "DRAG AIM", "Kéo aim theo ngón tay"),
        ("aimassist", "🌀", "AIM ASSIST", "Kéo mượt + dự đoán"),
        ("aimlock", "🔒", "AIM LOCK", "Khóa mục tiêu"),
        ("smooth", "🌊", "SMOOTH TARGET", "Chuyển mục tiêu mượt")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "HỖ TRỢ KÉO TÂM")
            ForEach(items, id: \.0) { i in
                FeatureCard(
                    icon: i.1,
                    title: i.2,
                    subtitle: i.3,
                    isOn: state.isOn(i.0),
                    accent: state.accentColor,
                    code: findCode(i.0)
                ) {
                    state.toggle(i.0)
                }
            }
        }
    }

    private func findCode(_ k: String) -> String? {
        let map: [String: String] = [
            "microaim": "MICRO PULL JS",
            "headlock": "HEAD TRACK C#",
            "dragaim": "AIMLOCK C++",
            "aimassist": "AIM ASSIST C++",
            "aimlock": "AIMLOCK C++",
            "smooth": "PREDICTION"
        ]
        guard let n = map[k] else { return nil }
        return CodeLibrary.snippets
            .first { $0.name == n }?.code
    }
}

struct AdvancedTab: View {
    @ObservedObject var state: StateManager

    private let items: [(String, String, String, String)] = [
        ("predict", "🔮", "PREDICTION", "Dự đoán di chuyển"),
        ("trigger", "⚡", "TRIGGER BOT", "Tự bắn khi có target"),
        ("recoil", "🎚️", "RECOIL FIX", "Giảm giật súng"),
        ("nospread", "🎯", "NO SPREAD", "Không tản mác"),
        ("silent", "🤫", "SILENT AIM", "Ngắm không lộ"),
        ("flick", "💫", "FLICK AIM", "Bật tâm tức thời"),
        ("scope", "🔭", "QUICK SCOPE", "Ngắm nhanh scope"),
        ("burst", "🔥", "BURST LOCK", "Khóa loạt đạn"),
        ("swap", "⚡", "FAST SWAP", "Đổi súng nhanh"),
        ("rung", "🛡️", "FIX RUNG", "Khử rung tâm"),
        ("lo", "🌊", "FIX LỐ SMOOTH", "SmoothDamp"),
        (":nhay", "🎚️ state", "NHẠY.ac TÂM", "HeadLockcentColor,
 Boost"),
        ("nhe5", "✨", "NHẸ TÂM V5", "SmoothAim 90%"),
        ("move", "➡️", "MOVE TOWARD", "Di chuyển cơ bản"),
        ("core", "💾", "AIM DATA CORE", "AimData Structure")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "CHỨC NĂNG NÂNG CAO")
            ForEach(items, id: \.0) { i in
                FeatureCard(
                    icon: i.1,
                    title: i.2,
                    subtitle: i.3,
                    isOn: state.isOn(i.0),
                    accent                    code: findCode(i.0)
                ) {
                    state.toggle(i.0)
                }
            }
        }
    }

    private func findCode(_ k: String) -> String? {
        let map: [String: String] = [
            "predict": "PREDICTION",
            "trigger": "TRIGGER BOT",
            "recoil": "RECOIL FIX",
            "rung": "AIM DATA CORE",
            "lo": "PREDICTION",
            "nhay": "AIM DATA CORE",
            "nhe5": "AIM ASSIST C++",
            "move": "MOVE TOWARDS",
            "core": "AIM DATA CORE"
        ]
        guard let n = map[k] else { return nil }
        return CodeLibrary.snippets
            .first { $0.name == n }?.code
    }
}

struct CleanTab: View {
    @ObservedObject var state: StateManager

    private let items: [(String, String, String, String)] = [
        ("clearcache", "🗑️", "DỌN CACHE", "Xóa cache hệ thống"),
        ("clearls", "💾", "DỌN STORAGE", "Xóa dữ liệu lưu trữ"),
        ("clearidb", "🗄️", "DỌN DATA", "Xóa database"),
        ("clearimagecache", "🖼️", "DỌN ẢNH", "Xóa cache ảnh"),
        ("clearcookies", "🍪", "DỌN COOKIES", "Xóa cookies")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "NHẬN DIỆN THIẾT BỊ")
            InfoCard {
                InfoRow(
                    key: "MODEL",
                    value: DeviceInfo.modelName
                )
                InfoRow(
                    key: "HỆ ĐIỀU HÀNH",
                    value: "iOS \(UIDevice.current.systemVersion)"
                )
                InfoRow(
                    key: "KIẾN TRÚC",
                    value: DeviceInfo.architecture
                )
                InfoRow(
                    key: "CORES",
                    value: "\(ProcessInfo.processInfo.processorCount)"
                )
                InfoRow(
                    key: "RAM",
                    value: DeviceInfo.totalRAM
                )
                InfoRow(
                    key: "STORAGE",
                    value: DeviceInfo.freeStorage
                )
                InfoRow(
                    key: "MÀN HÌNH",
                    value: DeviceInfo.screenSize
                )
                InfoRow(
                    key: "UPTIME",
                    value: DeviceInfo.uptime
                )
            }

            SectionTitle(text: "DỌN DẸP HỆ THỐNG")
            ForEach(items, id: \.0) { i in
                FeatureCard(
                    icon: i.1,
                    title: i.2,
                    subtitle: i.3,
                    isOn: state.isOn(i.0),
                    accent: state.accentColor,
                    code: nil
                ) {
                    state.toggle(i.0)
                }
            }

            SectionTitle(text: "DỌN DẸP NHANH")
            HStack(spacing: 8) {
                cleanBtn("RAM", "🧹", "DỌN RAM")
                cleanBtn("CACHE", "🗑️", "DỌN CACHE")
                cleanBtn("ALL", "⚡", "DỌN TẤT CẢ")
            }
        }
    }

    private func cleanBtn(
        _ title: String,
        _ icon: String,
        _ type: String
    ) -> some View {
        Button(action: {
            state.runClean(type)
            UIImpactFeedbackGenerator(style: .heavy)
                .impactOccurred()
        }) {
            VStack(spacing: 4) {
                Text(icon).font(.system(size: 22))
                Text(title)
                    .font(.system(
                        size: 9,
                        weight: .black
                    ))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        state.accentColor.opacity(0.2),
                        Color(hex: "0d1117").opacity(0.85),
                        Color(hex: "ff0033").opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        state.accentColor.opacity(0.4),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct PerfTab: View {
    @ObservedObject var state: StateManager

    private let items: [(String, String, String, String)] = [
        ("fps", "💥", "BUFF FPS", "Tối ưu khung hình"),
        ("delay", "⚡", "ANTI DELAY", "Khử trễ cảm ứng"),
        ("thermal", "🌡️", "THERMAL GUARD", "Chống nóng máy"),
        ("battery", "🔋", "BATTERY SAVE", "Tiết kiệm pin"),
        ("wake", "💡", "WAKE LOCK", "Màn hình sáng"),
        ("fullscreen", "🖥️", "FULLSCREEN", "Toàn màn hình"),
        ("noparticles", "✨", "TẮT HẠT SÁNG", "Giảm particle"),
        ("nofx", "🎬", "TẮT HIỆU ỨNG", "Tắt effect nặng")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TỐI ƯU HIỆU NĂNG")
            ForEach(items, id: \.0) { i in
                FeatureCard(
                    icon: i.1,
                    title: i.2,
                    subtitle: i.3,
                    isOn: state.isOn(i.0),
                    accent: state.accentColor,
                    code: nil
                ) {
                    state.toggle(i.0)
                }
            }

            SectionTitle(text: "ĐO THỜI GIAN THỰC")
            InfoCard {
                InfoRow(
                    key: "FPS",
                    value: "\(state.fps)"
                )
                InfoRow(
                    key: "PING",
                    value: "\(state.ping)ms"
                )
                InfoRow(
                    key: "RAM",
                    value: "\(state.ram)%"
                )
                InfoRow(
                    key: "PIN",
                    value: "\(state.batteryPct)%"
                )
            }
        }
    }
}

struct GameTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "CHỌN GAME")
            GameCard(
                icon: "🔥",
                name: "FREE FIRE",
                id: "com.dts.freefireth",
                selected: state.game == "ff",
                accent: state.accentColor
            ) {
                state.game = state.game == "ff" ? nil : "ff"
            }
            GameCard(
                icon: "💥",
                name: "FREE FIRE MAX",
                id: "com.dts.freefiremax",
                selected: state.game == "ffmax",
                accent: state.accentColor
            ) {
                state.game = state.game == "ffmax"
                    ? nil
                    : "ffmax"
            }
            GameCard(
                icon: "⚡",
                name: "CẢ HAI GAME",
                id: "FREE FIRE + MAX",
                selected: state.game == "both",
                accent: state.accentColor
            ) {
                state.game = state.game == "both"
                    ? nil
                    : "both"
            }

            SectionTitle(text: "THÔNG TIN")
            InfoCard {
                InfoRow(
                    key: "GAME",
                    value: gameName()
                )
                InfoRow(
                    key: "CHỨC NĂNG BẬT",
                    value: "\(state.activeCount())"
                )
                InfoRow(
                    key: "PHIÊN BẢN",
                    value: "11.0"
                )
            }
        }
    }

    private func gameName() -> String {
        switch state.game {
        case "ff": return "FREE FIRE"
        case "ffmax": return "FREE FIRE MAX"
        case "both": return "CẢ HAI"
        default: return "CHƯA CHỌN"
        }
    }
}

struct GameCard: View {
    let icon: String
    let name: String
    let id: String
    let selected: Bool
    let accent: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
            UIImpactFeedbackGenerator(style: .light)
                .impactOccurred()
        }) {
            HStack(spacing: 10) {
                ZStack {
                    if selected {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accent,
                                        Color(hex: "ff0033")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                    } else {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 40, height: 40)
                    }
                    Text(icon).font(.system(size: 18))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(
                            Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(name)
                        .font(.system(
                            size: 12.5,
                            weight: .bold
                        ))
                        .foregroundColor(.white)
                    Text(id)
                        .font(.system(size: 9.5))
                        .foregroundColor(
                            Color(hex: "9ca3af")
                        )
                }
                Spacer()
                Text(selected ? "ON" : "OFF")
                    .font(.system(
                        size: 11,
                        weight: .black
                    ))
                    .foregroundColor(
                        selected
                            ? accent
                            : Color(hex: "9ca3af")
                    )
                    .frame(width: 42, height: 26)
                    .background(
                        selected
                            ? accent.opacity(0.2)
                            : Color.white.opacity(0.05)
                    )
                    .cornerRadius(8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(bg)
            .cornerRadius(16)
            .overlay(stroke)
        }
        .buttonStyle(.plain)
    }

    private var bg: some View {
        ZStack {
            if selected {
                LinearGradient(
                    colors: [
                        accent.opacity(0.2),
                        Color(hex: "0d1117").opacity(0.85),
                        Color(hex: "ff0033").opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color.white.opacity(0.03)
            }
        }
    }

    private var stroke: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                selected
                    ? accent.opacity(0.6)
                    : Color.white.opacity(0.08),
                lineWidth: 1
            )
    }
}

struct ThemeTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "MÀU CHỦ ĐỀ")
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ForEach(Theme.accents, id: \.0) { a in
                    ThemeSwatch(
                        name: a.0,
                        hex: a.1,
                        selected: state.accentHex == a.1
                    ) {
                        state.setAccent(a.1)
                    }
                }
            }

            SectionTitle(text: "HIỆU ỨNG NỀN")
            effectRow("particles", "✨", "HẠT BAY")
            effectRow("grid", "🔲", "LƯỚI")
            effectRow("aurora", "🌈", "CỰC QUANG")
            effectRow("nebula", "🌌", "TINH VÂN")
            effectRow("stars", "⭐", "SAO BĂNG")
            effectRow("rings", "◎", "VÒNG XUNG")
            effectRow("orbit", "🪐", "QUỸ ĐẠO")

            SectionTitle(text: "XEM TRƯỚC")
            InfoCard {
                InfoRow(
                    key: "MÀU HIỆN TẠI",
                    value: "#\(state.accentHex.uppercased())"
                )
                InfoRow(
                    key: "SỐ MÀU",
                    value: "\(Theme.accents.count)"
                )
            }
        }
    }

    private func effectRow(
        _ key: String,
        _ icon: String,
        _ title: String
    ) -> some View {
        FeatureCard(
            icon: icon,
            title: title,
            subtitle: "Hiệu ứng nền",
            isOn: state.isOn(key),
            accent: state.accentColor,
            code: nil
        ) {
            state.toggle(key)
        }
    }
}

struct ThemeSwatch: View {
    let name: String
    let hex: String
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: hex))
                        .frame(height: 42)
                        .shadow(
                            color: Color(hex: hex)
                                .opacity(0.6),
                            radius: selected ? 12 : 4
                        )
                    if selected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.white,
                                lineWidth: 2
                            )
                            .frame(height: 42)
                        Text("✓")
                            .font(.system(
                                size: 18,
                                weight: .black
                            ))
                            .foregroundColor(.white)
                            .shadow(
                                color: .black,
                                radius: 2
                            )
                    }
                }
                Text(name)
                    .font(.system(
                        size: 9,
                        weight: .heavy
                    ))
                    .foregroundColor(
                        selected
                            ? Color(hex: hex)
                            : Color(hex: "9ca3af")
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

struct SystemTab: View {
    @ObservedObject var state: StateManager

    private let items: [(String, String, String, String)] = [
        ("autosave", "💾", "TỰ ĐỘNG LƯU", "Lưu cài đặt"),
        ("haptic", "📳", "RUNG PHẢN HỒI", "Haptic feedback"),
        ("sound", "🔊", "ÂM THANH", "Sound effect"),
        ("debug", "🐛", "CHẾ ĐỘ DEBUG", "Debug info"),
        ("safe", "🛡️", "CHẾ ĐỘ AN TOÀN", "Safe mode"),
        ("killswitch", "⛔", "KILL SWITCH", "Tắt toàn bộ")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "THÔNG TIN HỆ THỐNG")
            InfoCard {
                InfoRow(
                    key: "PHIÊN BẢN",
                    value: "V11 TITAN"
                )
                InfoRow(
                    key: "BUILD",
                    value: "20251011"
                )
                InfoRow(
                    key: "DEVICE ID",
                    value: state.deviceId
                )
                InfoRow(
                    key: "TIER",
                    value: tier()
                )
                InfoRow(
                    key: "KEY",
                    value: maskKey()
                )
            }

            SectionTitle(text: "CÀI ĐẶT")
            ForEach(items, id: \.0) { i in
                FeatureCard(
                    icon: i.1,
                    title: i.2,
                    subtitle: i.3,
                    isOn: state.isOn(i.0),
                    accent: state.accentColor,
                    code: nil
                ) {
                    state.toggle(i.0)
                }
            }

            SectionTitle(text: "HÀNH ĐỘNG")
            HStack(spacing: 8) {
                actionBtn(
                    "RESET",
                    "↺",
                    Color(hex: "fbbf24")
                ) {
                    state.resetAll()
                    state.showToastMessage("ĐÃ RESET TẤT CẢ")
                }
                actionBtn(
                    "LOGOUT",
                    "🚪",
                    Color(hex: "ff0033")
                ) {
                    UserDefaults.standard.removeObject(
                        forKey: "dl_utral_auth"
                    )
                    UserDefaults.standard.removeObject(
                        forKey: "dl_utral_tier"
                    )
                    exit(0)
                }
            }
        }
    }

    private func tier() -> String {
        return UserDefaults.standard.string(
            forKey: "dl_utral_tier"
        ) ?? "VIP"
    }

    private func maskKey() -> String {
        guard let k = UserDefaults.standard.string(
            forKey: "dl_utral_auth"
        ), k.count > 8 else {
            return "------"
        }
        let pre = k.prefix(4)
        let suf = k.suffix(4)
        return "\(pre)-****-\(suf)"
    }

    private func actionBtn(
        _ title: String,
        _ icon: String,
        _ color: Color,
        _ action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            action()
            UIImpactFeedbackGenerator(style: .heavy)
                .impactOccurred()
        }) {
            HStack(spacing: 6) {
                Text(icon)
                Text(title)
                    .font(.system(
                        size: 12,
                        weight: .black
                    ))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        color.opacity(0.6),
                        color.opacity(0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        color.opacity(0.6),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct InfoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

struct InfoRow: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(Color(hex: "9ca3af"))
            Spacer()
            Text(value)
                .font(.system(
                    size: 11,
                    weight: .black,
                    design: .monospaced
                ))
                .foregroundColor(Color(hex: "00d4ff"))
                .lineLimit(1)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct ToastView: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color, radius: 6)
            Text(text)
                .font(.system(size: 12, weight: .black))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.4), radius: 12)
        .transition(
            .move(edge: .top)
                .combined(with: .opacity)
        )
    }
}

struct InjectOverlay: View {
    @ObservedObject var state: StateManager
    @State private var dots: Int = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: state.accentColor
                        )
                    )
                    .scaleEffect(1.6)
                Text("ĐANG INJECT")
                    .font(.system(
                        size: 14,
                        weight: .black
                    ))
                    .foregroundColor(state.accentColor)
                Text(String(
                    repeating: ".",
                    count: dots % 4
                ))
                .font(.system(
                    size: 18,
                    weight: .black
                ))
                .foregroundColor(state.accentColor)
            }
        }
        .onAppear {
            Timer.scheduledTimer(
                withTimeInterval: 0.3,
                repeats: true
            ) { _ in
                dots += 1
            }
        }
    }
}

struct FooterBar: View {
    @ObservedObject var state: StateManager

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 6, height: 6)
                .shadow(
                    color: Color(hex: "22c55e"),
                    radius: 4
                )
            Text("HOẠT ĐỘNG")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(Color(hex: "22c55e"))
            Text("•")
                .foregroundColor(Color(hex: "6b7280"))
            Text("\(state.activeCount()) CHỨC NĂNG")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(Color(hex: "9ca3af"))
            Spacer()
            Text("ZWILZ HLONG V11")
                .font(.system(size: 8, weight: .heavy))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.white.opacity(0.06),
                    lineWidth: 1
                )
        )
    }
}

import SwiftUI

struct MenuView: View {
    @StateObject private var state =
        StateManager()
    @State private var isVerified: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "06080d")
                .ignoresSafeArea()

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
                        state.addRipple(
                            at: v.location
                        )
                    }
            )

            TapRippleLayer(ripples: state.ripples)

            toastLayer

            if state.cleanActive {
                CleanOverlay(state: state)
                    .zIndex(1000)
            }

            if state.isInjecting {
                InjectOverlay(state: state)
                    .zIndex(1001)
            }
        }
    }

    private var scrollArea: some View {
        ScrollView(
            .vertical,
            showsIndicators: false
        ) {
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
        case "advanced":
            AdvancedTab(state: state)
        case "code": CodeLibraryView()
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
            FloatingParticles(
                color: state.accentColor
            )
            ShootingStars(
                color: state.accentColor
            )
            PulseRings(color: state.accentColor)
        }
        .ignoresSafeArea()
    }
}

// MARK: - HEADER
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
                            state.accentColor
                                .opacity(0.16),
                            Color(hex: "0d1117")
                                .opacity(0.88),
                            Color(hex: "ff0033")
                                .opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    state.accentColor
                        .opacity(0.55),
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
                    .aspectRatio(
                        contentMode: .fill
                    )
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                avatarGrad,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: state.accentColor
                            .opacity(0.7),
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
                        color: state.accentColor
                            .opacity(0.6),
                        radius: 10
                    )
                Text("ZH")
                    .font(
                        .system(
                            size: 15,
                            weight: .black,
                            design: .monospaced
                        )
                    )
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
        VStack(
            alignment: .leading,
            spacing: 2
        ) {
            Text("ZWILZ HLONG AIM VIP")
                .font(
                    .system(
                        size: 13.5,
                        weight: .black
                    )
                )
                .foregroundColor(state.accentColor)
                .lineLimit(1)
            Text("DRAGLOCK INJECT - v10")
                .font(
                    .system(size: 8, weight: .bold)
                )
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
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
                    .repeatForever(
                        autoreverses: true
                    )
            ) {
                pulse = true
            }
        }
    }
}

// MARK: - HUD
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
                .font(
                    .system(
                        size: 8,
                        weight: .heavy
                    )
                )
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
            Text(value)
                .font(
                    .system(
                        size: 12,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            Color.white.opacity(0.045)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    color.opacity(0.25),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - TAB BAR
struct TabBar: View {
    @ObservedObject var state: StateManager

    private let tabs: [(String, String)] = [
        ("aim", "KÉO TÂM"),
        ("advanced", "NÂNG CAO"),
        ("code", "CODE"),
        ("clean", "DỌN DẸP"),
        ("perf", "HIỆU NĂNG"),
        ("game", "GAME"),
        ("theme", "MÀU"),
        ("system", "HỆ THỐNG")
    ]

    var body: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack(spacing: 5) {
                ForEach(tabs, id: \.0) { item in
                    tabButton(
                        key: item.0,
                        label: item.1
                    )
                }
            }
            .padding(4)
        }
        .background(
            Color.white.opacity(0.045)
        )
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }

    private func tabButton(
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
            UIImpactFeedbackGenerator(
                style: .light
            ).impactOccurred()
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
                        color: state.accentColor
                            .opacity(0.5),
                        radius: 8
                    )
                }
                Text(label)
                    .font(
                        .system(
                            size: 10,
                            weight: .heavy
                        )
                    )
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

// MARK: - SECTION TITLE
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
                .font(
                    .system(
                        size: 10,
                        weight: .black
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
    }
}

// MARK: - FEATURE CARD
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
                codeButton
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

    private var codeButton: some View {
        Button(action: {
            showCode = true
        }) {
            Text("CODE")
                .font(
                    .system(
                        size: 8,
                        weight: .black
                    )
                )
                .foregroundColor(accent)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    accent.opacity(0.15)
                )
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
                    .fill(
                        Color.white.opacity(0.05)
                    )
                    .frame(width: 40, height: 40)
            }
            Text(icon)
                .font(.system(size: 18))
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
        VStack(
            alignment: .leading,
            spacing: 3
        ) {
            Text(title)
                .font(
                    .system(
                        size: 12.5,
                        weight: .bold
                    )
                )
                .foregroundColor(.white)
                .lineLimit(1)
            Text(subtitle)
                .font(.system(size: 9.5))
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
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
                    .fill(
                        Color.white.opacity(0.1)
                    )
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
                        Color(hex: "0d1117")
                            .opacity(0.85),
                        Color(hex: "ff0033")
                            .opacity(0.15)
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

// MARK: - SIMPLE CODE VIEW
struct SimpleCodeView: View {
    let title: String
    let code: String
    @Environment(\.presentationMode)
    var presentationMode
    @State private var copied: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "06080d")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                codeArea
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                copyBtn
            }
        }
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: .black
                    )
                )
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                presentationMode.wrappedValue
                    .dismiss()
            }) {
                Text("✕")
                    .font(
                        .system(
                            size: 16,
                            weight: .bold
                        )
                    )
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
                .font(
                    .system(
                        size: 11,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
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
                Text(
                    copied
                        ? "ĐÃ COPY"
                        : "COPY CODE"
                )
                .font(
                    .system(
                        size: 13,
                        weight: .black
                    )
                )
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
}// MARK: - AIM TAB
struct AimTab: View {
    @ObservedObject var state: StateManager

    private let items: [
        (String, String, String, String)
    ] = [
        ("microaim", "👆", "NHẸ TÂM",
         "Micro pull chuẩn xác"),
        ("headlock", "💀", "BÁM ĐẦU",
         "Head track dự đoán"),
        ("dragaim", "🎯", "DRAG AIM",
         "Kéo aim theo ngón tay"),
        ("aimassist", "🌀", "AIM ASSIST",
         "Kéo mượt + dự đoán"),
        ("aimlock", "🔒", "AIM LOCK",
         "Khóa mục tiêu tự động")
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

    private func findCode(_ key: String) -> String? {
        let map: [String: String] = [
            "microaim": "NHẸ TÂM",
            "headlock": "BÁM ĐẦU",
            "dragaim": "DRAG AIM",
            "aimassist": "AIM ASSIST",
            "aimlock": "AIM LOCK"
        ]
        guard let name = map[key] else {
            return nil
        }
        return CodeLibrary.snippets
            .first { $0.name == name }?
            .code
    }
}

// MARK: - ADVANCED TAB
struct AdvancedTab: View {
    @ObservedObject var state: StateManager

    private let items: [
        (String, String, String, String)
    ] = [
        ("predict", "🔮", "PREDICTION",
         "Dự đoán di chuyển"),
        ("smooth", "🌊", "SMOOTH TARGET",
         "Chuyển mục tiêu mượt"),
        ("trigger", "⚡", "TRIGGER BOT",
         "Tự bắn khi có target"),
        ("recoil", "🎚️", "RECOIL FIX",
         "Giảm giật súng"),
        ("nospread", "🎯", "NO SPREAD",
         "Không tản mác đạn"),
        ("silent", "🤫", "SILENT AIM",
         "Ngắm không lộ"),
        ("flick", "💫", "FLICK AIM",
         "Bật tâm tức thời"),
        ("scope", "🔭", "QUICK SCOPE",
         "Ngắm nhanh scope"),
        ("burst", "🔥", "BURST LOCK",
         "Khóa loạt đạn"),
        ("swap", "⚡", "FAST SWAP",
         "Đổi súng nhanh")
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
                    accent: state.accentColor,
                    code: findCode(i.0)
                ) {
                    state.toggle(i.0)
                }
            }
        }
    }

    private func findCode(_ key: String) -> String? {
        let map: [String: String] = [
            "predict": "PREDICTION",
            "smooth": "SMOOTH TARGET",
            "trigger": "TRIGGER BOT",
            "recoil": "RECOIL FIX",
            "nospread": "NO SPREAD",
            "silent": "SILENT AIM",
            "flick": "FLICK AIM",
            "scope": "QUICK SCOPE",
            "burst": "BURST LOCK",
            "swap": "FAST SWAP"
        ]
        guard let name = map[key] else {
            return nil
        }
        return CodeLibrary.snippets
            .first { $0.name == name }?
            .code
    }
}

// MARK: - CLEAN TAB
struct CleanTab: View {
    @ObservedObject var state: StateManager

    private let items: [
        (String, String, String, String)
    ] = [
        ("clearcache", "🗑️", "DỌN CACHE",
         "Xóa bộ nhớ cache hệ thống"),
        ("clearls", "💾", "DỌN STORAGE",
         "Xóa dữ liệu lưu trữ"),
        ("clearidb", "🗄️", "DỌN DATA",
         "Xóa database ứng dụng"),
        ("clearimagecache", "🖼️", "DỌN ẢNH",
         "Xóa cache hình ảnh"),
        ("clearcookies", "🍪", "DỌN COOKIES",
         "Xóa cookies trình duyệt")
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
            cleanButtons
        }
    }

    private var cleanButtons: some View {
        HStack(spacing: 8) {
            cleanButton(
                title: "DỌN RAM",
                icon: "🧹",
                type: "DỌN RAM"
            )
            cleanButton(
                title: "DỌN CACHE",
                icon: "🗑️",
                type: "DỌN CACHE"
            )
            cleanButton(
                title: "DỌN TẤT CẢ",
                icon: "⚡",
                type: "DỌN TẤT CẢ"
            )
        }
    }

    private func cleanButton(
        title: String,
        icon: String,
        type: String
    ) -> some View {
        Button(action: {
            state.runClean(type)
            UIImpactFeedbackGenerator(
                style: .heavy
            ).impactOccurred()
        }) {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(
                        .system(
                            size: 9,
                            weight: .black
                        )
                    )
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        state.accentColor
                            .opacity(0.2),
                        Color(hex: "0d1117")
                            .opacity(0.85),
                        Color(hex: "ff0033")
                            .opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        state.accentColor
                            .opacity(0.4),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PERF TAB
struct PerfTab: View {
    @ObservedObject var state: StateManager

    private let items: [
        (String, String, String, String)
    ] = [
        ("fps", "💥", "BUFF FPS",
         "Tối ưu khung hình"),
        ("delay", "⚡", "ANTI DELAY",
         "Khử trễ cảm ứng"),
        ("thermal", "🌡️", "THERMAL GUARD",
         "Chống nóng máy"),
        ("battery", "🔋", "BATTERY SAVE",
         "Tiết kiệm pin"),
        ("wake", "💡", "WAKE LOCK",
         "Giữ màn hình sáng"),
        ("fullscreen", "🖥️", "FULLSCREEN",
         "Toàn màn hình"),
        ("noparticles", "✨", "TẮT HẠT SÁNG",
         "Giảm particle"),
        ("nofx", "🎬", "TẮT HIỆU ỨNG",
         "Tắt hiệu ứng nặng")
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

            SectionTitle(text: "ĐO LƯỜNG THỜI GIAN THỰC")
            InfoCard {
                InfoRow(
                    key: "FPS HIỆN TẠI",
                    value: "\(state.fps)"
                )
                InfoRow(
                    key: "PING",
                    value: "\(state.ping)ms"
                )
                InfoRow(
                    key: "RAM USAGE",
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

// MARK: - GAME TAB
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
                state.game = state.game == "ff"
                    ? nil
                    : "ff"
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
                    key: "GAME ĐÃ CHỌN",
                    value: gameName()
                )
                InfoRow(
                    key: "CHỨC NĂNG BẬT",
                    value: "\(state.activeCount())"
                )
                InfoRow(
                    key: "PHIÊN BẢN",
                    value: "10.0"
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
            UIImpactFeedbackGenerator(
                style: .light
            ).impactOccurred()
        }) {
            HStack(spacing: 10) {
                ZStack {
                    if selected {
                        RoundedRectangle(
                            cornerRadius: 11
                        )
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
                        RoundedRectangle(
                            cornerRadius: 11
                        )
                        .fill(
                            Color.white.opacity(0.05)
                        )
                        .frame(width: 40, height: 40)
                    }
                    Text(icon)
                        .font(.system(size: 18))
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
                        .font(
                            .system(
                                size: 12.5,
                                weight: .bold
                            )
                        )
                        .foregroundColor(.white)
                    Text(id)
                        .font(.system(size: 9.5))
                        .foregroundColor(
                            Color(hex: "9ca3af")
                        )
                }

                Spacer()

                Text(selected ? "ON" : "OFF")
                    .font(
                        .system(
                            size: 11,
                            weight: .black
                        )
                    )
                    .foregroundColor(
                        selected
                            ? accent
                            : Color(hex: "9ca3af")
                    )
                    .frame(width: 42, height: 26)
                    .background(
                        selected
                            ? accent.opacity(0.2)
                            : Color.white
                                .opacity(0.05)
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
                        Color(hex: "0d1117")
                            .opacity(0.85),
                        Color(hex: "ff0033")
                            .opacity(0.15)
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

// MARK: - THEME TAB
struct ThemeTab: View {
    @ObservedObject var state: StateManager

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "CHỌN MÀU CHỦ ĐẠO")
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(
                    Theme.accentOptions,
                    id: \.0
                ) { opt in
                    themeBtn(
                        name: opt.0,
                        hex: opt.1
                    )
                }
            }

            SectionTitle(text: "PREVIEW")
            InfoCard {
                InfoRow(
                    key: "MÀU HIỆN TẠI",
                    value: state.accentHex
                )
                InfoRow(
                    key: "SỐ LỰA CHỌN",
                    value:
                        "\(Theme.accentOptions.count)"
                )
            }
        }
    }

    private func themeBtn(
        name: String,
        hex: String
    ) -> some View {
        Button(action: {
            state.setAccent(hex)
            state.showToastMessage(
                "ĐÃ ĐỔI MÀU: \(name)"
            )
        }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 40, height: 40)
                        .shadow(
                            color: Color(hex: hex)
                                .opacity(0.7),
                            radius: 10
                        )
                    if state.accentHex == hex {
                        Text("✓")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .black
                                )
                            )
                            .foregroundColor(.white)
                    }
                }
                Text(name)
                    .font(
                        .system(
                            size: 9,
                            weight: .heavy
                        )
                    )
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Color.white.opacity(0.03)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        state.accentHex == hex
                            ? Color(hex: hex)
                            : Color.white
                                .opacity(0.08),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SYSTEM TAB
struct SystemTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            profileHeader

            SectionTitle(text: "TÀI KHOẢN")
            InfoCard {
                InfoRow(
                    key: "KEY",
                    value: keyValue
                )
                InfoRow(
                    key: "TIER",
                    value: tierValue
                )
                InfoRow(
                    key: "HẾT HẠN",
                    value: "Vô hạn"
                )
            }

            SectionTitle(text: "NHẬN DIỆN THIẾT BỊ")
            deviceCard

            SectionTitle(text: "TRẠNG THÁI")
            liveCard

            SectionTitle(text: "GIỚI THIỆU")
            aboutCard
        }
    }

    @ViewBuilder
    private var profileHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                if hasAvatar() {
                    OrbitDots(
                        color1: state.accentColor,
                        color2: Color(hex: "ff0033")
                    )
                    .frame(width: 110, height: 110)

                    Image("avatar")
                        .resizable()
                        .aspectRatio(
                            contentMode: .fill
                        )
                        .frame(
                            width: 90,
                            height: 90
                        )
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    avatarGrad,
                                    lineWidth: 3
                                )
                        )
                        .shadow(
                            color: state.accentColor
                                .opacity(0.7),
                            radius: 20
                        )
                } else {
                    Circle()
                        .fill(avatarGrad)
                        .frame(
                            width: 90,
                            height: 90
                        )
                        .shadow(
                            color: state.accentColor
                                .opacity(0.5),
                            radius: 20
                        )
                    Text("ZH")
                        .font(
                            .system(
                                size: 32,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)
                }
            }
            .frame(width: 110, height: 110)

            Text("ZWILZ HLONG")
                .font(
                    .system(
                        size: 16,
                        weight: .black
                    )
                )
                .foregroundColor(state.accentColor)

            Text("ADMIN - PREMIUM")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [
                    state.accentColor.opacity(0.15),
                    Color(hex: "0d1117")
                        .opacity(0.85),
                    Color(hex: "ff0033")
                        .opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    state.accentColor.opacity(0.5),
                    lineWidth: 1
                )
        )
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

    private var keyValue: String {
        UserDefaults.standard
            .string(forKey: "dl_utral_auth")
            ?? "--"
    }

    private var tierValue: String {
        UserDefaults.standard
            .string(forKey: "dl_utral_tier")
            ?? "VIP"
    }

    private var deviceCard: some View {
        InfoCard {
            InfoRow(
                key: "MÃ THIẾT BỊ",
                value: String(
                    state.deviceId.suffix(12)
                )
            )
            InfoRow(
                key: "MODEL",
                value: DeviceInfo.modelName
            )
            InfoRow(
                key: "HỆ ĐIỀU HÀNH",
                value:
                    "iOS \(UIDevice.current.systemVersion)"
            )
            InfoRow(
                key: "KIẾN TRÚC",
                value: DeviceInfo.architecture
            )
            InfoRow(
                key: "CORES",
                value:
                    "\(ProcessInfo.processInfo.processorCount)"
            )
            InfoRow(
                key: "RAM",
                value: DeviceInfo.totalRAM
            )
            InfoRow(
                key: "STORAGE",
                value: DeviceInfo.freeStorage
            )
        }
    }

    private var liveCard: some View {
        InfoCard {
            InfoRow(
                key: "PIN",
                value: "\(state.batteryPct)%"
            )
            InfoRow(
                key: "SẠC",
                value: state.charging
                    ? "ĐANG SẠC"
                    : "KHÔNG SẠC"
            )
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
        }
    }

    private var aboutCard: some View {
        InfoCard {
            InfoRow(
                key: "PHIÊN BẢN",
                value: "10.0 INJECT"
            )
            InfoRow(
                key: "BUILD",
                value: "20251011"
            )
            InfoRow(
                key: "ADMIN",
                value: "ZWILZ HLONG"
            )
            InfoRow(
                key: "ENGINE",
                value: "SWIFTUI NATIVE"
            )
            InfoRow(
                key: "SECURITY",
                value: "FIRESTORE REST"
            )
        }
    }
}

// MARK: - INFO CARD
struct InfoCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "0099ff")
                            .opacity(0.1),
                        Color(hex: "0d1117")
                            .opacity(0.88),
                        Color(hex: "ff0033")
                            .opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color(hex: "00d4ff")
                            .opacity(0.25),
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
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
            Spacer()
            Text(value)
                .font(
                    .system(
                        size: 11,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
                .lineLimit(1)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - FOOTER
struct FooterBar: View {
    @ObservedObject var state: StateManager

    var body: some View {
        HStack(spacing: 8) {
            resetBtn
            injectBtn
        }
    }

    private var resetBtn: some View {
        Button(action: {
            state.resetAll()
            state.showToastMessage("ĐÃ ĐẶT LẠI")
        }) {
            Text("ĐẶT LẠI")
                .font(
                    .system(
                        size: 12,
                        weight: .black
                    )
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color.white.opacity(0.06)
                )
                .foregroundColor(.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private var injectBtn: some View {
        Button(action: handleInject) {
            HStack(spacing: 6) {
                if state.isInjecting {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: .white
                            )
                        )
                        .scaleEffect(0.7)
                } else {
                    Text("💉")
                }
                Text(
                    state.isInjecting
                        ? "ĐANG INJECT..."
                        : "INJECT"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .black
                    )
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: state.isInjecting
                        ? [
                            Color(hex: "6b7280"),
                            Color(hex: "9ca3af")
                          ]
                        : [
                            state.accentColor,
                            Color(hex: "ff0033")
                          ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(
                color: state.accentColor
                    .opacity(0.5),
                radius: 12
            )
        }
        .buttonStyle(.plain)
        .disabled(state.isInjecting)
    }

    private func handleInject() {
        if state.game == nil {
            state.showToastMessage(
                "CHỌN GAME TRƯỚC"
            )
            return
        }
        if state.activeCount() == 0 {
            state.showToastMessage(
                "BẬT ÍT NHẤT 1 CHỨC NĂNG"
            )
            return
        }

        UIImpactFeedbackGenerator(
            style: .heavy
        ).impactOccurred()

        withAnimation {
            state.isInjecting = true
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.8
        ) {
            withAnimation {
                state.isInjecting = false
            }
            openFF(game: state.game) { ok in
                if ok {
                    state.showToastMessage(
                        "ĐANG MỞ GAME..."
                    )
                } else {
                    state.showToastMessage(
                        "KHÔNG TÌM THẤY GAME"
                    )
                }
            }
        }
    }

    private func openFF(
        game: String?,
        completion: @escaping (Bool) -> Void
    ) {
        var schemes: [String] = []
        if game == "ffmax" {
            schemes = [
                "freefiremax://",
                "com.dts.freefiremax://"
            ]
        } else if game == "both" {
            schemes = [
                "freefire://",
                "com.dts.freefireth://",
                "freefiremax://"
            ]
        } else {
            schemes = [
                "freefire://",
                "com.dts.freefireth://"
            ]
        }
        tryNext(
            schemes: schemes,
            index: 0,
            completion: completion
        )
    }

    private func tryNext(
        schemes: [String],
        index: Int,
        completion: @escaping (Bool) -> Void
    ) {
        guard index < schemes.count else {
            completion(false)
            return
        }
        guard let u = URL(
            string: schemes[index]
        ) else {
            tryNext(
                schemes: schemes,
                index: index + 1,
                completion: completion
            )
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(
                u,
                options: [:]
            ) { ok in
                if ok {
                    completion(true)
                } else {
                    self.tryNext(
                        schemes: schemes,
                        index: index + 1,
                        completion: completion
                    )
                }
            }
        }
    }
}

// MARK: - TOAST
struct ToastView: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .font(
                    .system(
                        size: 12,
                        weight: .heavy
                    )
                )
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(Color.black.opacity(0.92))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color, lineWidth: 1)
        )
        .shadow(
            color: color.opacity(0.5),
            radius: 14
        )
    }
}

// MARK: - INJECT OVERLAY
struct InjectOverlay: View {
    @ObservedObject var state: StateManager
    @State private var progress: Double = 0
    @State private var message: String =
        "ĐANG KHOI TAO"

    private let messages = [
        "KIỂM TRA CẤU HÌNH",
        "XÁC THỰC THIẾT BỊ",
        "ÁP DỤNG CHỨC NĂNG",
        "INJECT VÀO GAME",
        "TỐI ƯU HIỆU NĂNG",
        "HOÀN TẤT!"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                ringView
                Text(message)
                    .font(
                        .system(
                            size: 13,
                            weight: .black
                        )
                    )
                    .foregroundColor(.white)
                Text("ZWILZ HLONG INJECT ENGINE")
                    .font(
                        .system(
                            size: 9,
                            weight: .heavy
                        )
                    )
                    .foregroundColor(
                        Color(hex: "9ca3af")
                    )
            }
        }
        .onAppear(perform: animate)
    }

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(
                    state.accentColor.opacity(0.2),
                    lineWidth: 6
                )
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            state.accentColor,
                            Color(hex: "ff0033")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(
                    .system(
                        size: 22,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(state.accentColor)
        }
        .shadow(
            color: state.accentColor.opacity(0.6),
            radius: 20
        )
    }

    private func animate() {
        for (i, m) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(
                deadline:
                    .now() + Double(i) * 0.28
            ) {
                withAnimation(
                    .easeInOut(duration: 0.2)
                ) {
                    message = m
                    progress = Double(i + 1)
                        / Double(messages.count)
                }
            }
        }
    }
}

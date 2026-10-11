import SwiftUI

struct MenuEntry {
    let key: String
    let icon: String
    let title: String
    let sub: String
    let codeName: String?

    init(
        _ key: String,
        _ icon: String,
        _ title: String,
        _ sub: String,
        _ codeName: String? = nil
    ) {
        self.key = key
        self.icon = icon
        self.title = title
        self.sub = sub
        self.codeName = codeName
    }
}

func findSnippet(_ name: String?) -> String? {
    if name == nil {
        return nil
    }
    let n = name!
    var i = 0
    let arr = CodeLibrary.snippets
    while i < arr.count {
        if arr[i].name == n {
            return arr[i].code
        }
        i = i + 1
    }
    return nil
}

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
        case "aim":
            AimTab(state: state)
        case "advanced":
            AdvancedTab(state: state)
        case "code":
            CodeLibraryView()
        case "js":
            JSRunnerView()
        case "clean":
            CleanTab(state: state)
        case "perf":
            PerfTab(state: state)
        case "game":
            GameTab(state: state)
        case "theme":
            ThemeTab(state: state)
        case "access":
            AccessTab(state: state)
        case "system":
            SystemTab(state: state)
        default:
            EmptyView()
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
    @State private var shimmer: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            avatarBadge
            titleBlock
            Spacer()
            StatusDot(color: state.accentColor)
        }
        .padding(12)
        .background(
            ZStack {
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
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(shimmerValue),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 18)
                    )
            }
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
        .onAppear {
            withAnimation(
                .linear(duration: 2.5)
                    .repeatForever(autoreverses: false)
            ) {
                shimmer = true
            }
        }
    }

    private var shimmerValue: Double {
        if shimmer {
            return 0.12
        }
        return 0.0
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
            Text("SUPER MENU V14")
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
                .frame(width: 12, height: 12)
                .scaleEffect(pulseScale1)
                .opacity(pulseOpacity1)
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 8, height: 8)
                .scaleEffect(pulseScale2)
                .opacity(pulseOpacity2)
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 5, height: 5)
                .shadow(
                    color: Color(hex: "22c55e"),
                    radius: 8
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

    private var pulseScale1: CGFloat {
        if pulse {
            return 1.8
        }
        return 1.0
    }

    private var pulseOpacity1: Double {
        if pulse {
            return 0.15
        }
        return 1.0
    }

    private var pulseScale2: CGFloat {
        if pulse {
            return 1.2
        }
        return 1.0
    }

    private var pulseOpacity2: Double {
        if pulse {
            return 0.4
        }
        return 1.0
    }
}

struct HudRow: View {
    @ObservedObject var state: StateManager

    var body: some View {
        HStack(spacing: 6) {
            HudItem(
                label: "FPS",
                value: "\(state.fps)",
                icon: "speedometer",
                color: Color(hex: "22c55e")
            )
            HudItem(
                label: "PIN",
                value: "\(state.batteryPct)%",
                icon: batteryIcon,
                color: batteryColor
            )
            HudItem(
                label: "PING",
                value: "\(state.ping)",
                icon: "wifi",
                color: state.accentColor
            )
            HudItem(
                label: "RAM",
                value: "\(state.ram)%",
                icon: "memorychip",
                color: Color(hex: "a855f7")
            )
        }
    }

    private var batteryIcon: String {
        if state.charging {
            return "bolt.fill"
        }
        return "battery.100"
    }

    private var batteryColor: Color {
        if state.charging {
            return Color(hex: "fbbf24")
        }
        return state.accentColor
    }
}

struct HudItem: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 7.5, weight: .heavy))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
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

    private let keys: [String] = [
        "aim",
        "advanced",
        "code",
        "js",
        "clean",
        "perf",
        "game",
        "theme",
        "access",
        "system"
    ]

    private let labels: [String] = [
        "KÉO TÂM",
        "NÂNG CAO",
        "CODE",
        "JS RUN",
        "DỌN DẸP",
        "HIỆU NĂNG",
        "GAME",
        "MÀU",
        "TRỢ NĂNG",
        "HỆ THỐNG"
    ]

    private let icons: [String] = [
        "target",
        "sparkles",
        "chevron.left.forwardslash.chevron.right",
        "terminal",
        "trash.fill",
        "speedometer",
        "gamecontroller.fill",
        "paintpalette.fill",
        "accessibility",
        "gearshape.fill"
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(0..<keys.count, id: \.self) { i in
                    tabBtn(
                        key: keys[i],
                        label: labels[i],
                        icon: icons[i]
                    )
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
        label: String,
        icon: String
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
                HStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(label)
                        .font(.system(size: 10, weight: .heavy))
                }
                .foregroundColor(tabColor(key))
                .padding(.horizontal, 11)
                .padding(.vertical, 10)
            }
        }
        .buttonStyle(.plain)
    }

    private func tabColor(_ key: String) -> Color {
        if state.selectedTab == key {
            return Color.white
        }
        return Color(hex: "9ca3af")
    }
}

struct SectionTitle: View {
    let text: String
    let icon: String

    init(text: String, icon: String = "circle.fill") {
        self.text = text
        self.icon = icon
    }

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
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(hex: "00d4ff"))
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
    @State private var glow: Bool = false

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
        .shadow(
            color: shadowColor,
            radius: shadowRadius
        )
        .sheet(isPresented: $showCode) {
            SimpleCodeView(
                title: title,
                code: code ?? ""
            )
        }
        .onAppear {
            if isOn {
                withAnimation(
                    .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    glow = true
                }
            }
        }
        .onChange(of: isOn) { newValue in
            if newValue {
                withAnimation(
                    .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    glow = true
                }
            } else {
                glow = false
            }
        }
    }

    private var shadowColor: Color {
        if isOn {
            return accent.opacity(0.3)
        }
        return Color.clear
    }

    private var shadowRadius: CGFloat {
        if glow {
            return 14
        }
        return 4
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
            HStack(spacing: 4) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 8, weight: .black))
                Text("CODE")
                    .font(.system(size: 8, weight: .black))
            }
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
                        color: accent.opacity(0.6),
                        radius: 10
                    )
            } else {
                RoundedRectangle(cornerRadius: 11)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 40, height: 40)
            }
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(iconColor)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }

    private var iconColor: Color {
        if isOn {
            return Color.white
        }
        return accent
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
                        color: accent.opacity(0.7),
                        radius: 10
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
                .offset(x: knobOffset)
        }
        .animation(
            .spring(
                response: 0.3,
                dampingFraction: 0.6
            ),
            value: isOn
        )
    }

    private var knobOffset: CGFloat {
        if isOn {
            return 10
        }
        return -10
    }

    private var bgLayer: some View {
        ZStack {
            if isOn {
                LinearGradient(
                    colors: [
                        accent.opacity(0.22),
                        Color(hex: "0d1117").opacity(0.85),
                        Color(hex: "ff0033").opacity(0.16)
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
                strokeColor,
                lineWidth: 1
            )
    }

    private var strokeColor: Color {
        if isOn {
            return accent.opacity(0.65)
        }
        return Color.white.opacity(0.08)
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
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "00d4ff"))
            Text(title)
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                pm.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
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
                Image(systemName: copyIcon)
                    .font(.system(size: 14, weight: .black))
                Text(copyLabel)
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

    private var copyIcon: String {
        if copied {
            return "checkmark.circle.fill"
        }
        return "doc.on.doc.fill"
    }

    private var copyLabel: String {
        if copied {
            return "ĐÃ COPY"
        }
        return "COPY CODE"
    }
}

struct AimTab: View {
    @ObservedObject var state: StateManager

    private let items: [MenuEntry] = [
        MenuEntry("microaim", "hand.point.up.left.fill", "NHẸ TÂM", "Micro pull chuẩn xác", "MICRO PULL JS"),
        MenuEntry("headlock", "scope", "BÁM ĐẦU", "Head track dự đoán", "HEAD TRACK C#"),
        MenuEntry("dragaim", "hand.draw.fill", "DRAG AIM", "Kéo aim theo ngón tay", "AIMLOCK C++"),
        MenuEntry("aimassist", "wand.and.stars", "AIM ASSIST", "Kéo mượt + dự đoán", "AIM ASSIST C++"),
        MenuEntry("aimlock", "target", "AIM LOCK", "Khóa mục tiêu", "AIMLOCK C++"),
        MenuEntry("smooth", "arrow.left.arrow.right", "SMOOTH TARGET", "Chuyển mục tiêu mượt", "PREDICTION"),
        MenuEntry("boneaim", "figure.stand", "BONE AIM", "Ngắm theo xương", "BONE SCANNER"),
        MenuEntry("flickaim", "bolt.horizontal.fill", "FLICK AIM", "Bật tâm siêu nhanh", nil),
        MenuEntry("microadjust", "slider.horizontal.3", "MICRO ADJUST", "Vi chỉnh tâm", nil),
        MenuEntry("stickyaim", "pin.fill", "STICKY AIM", "Dính mục tiêu", nil)
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "HỖ TRỢ KÉO TÂM", icon: "target")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }
        }
    }

    private func buildCard(_ e: MenuEntry) -> some View {
        FeatureCard(
            icon: e.icon,
            title: e.title,
            subtitle: e.sub,
            isOn: state.isOn(e.key),
            accent: state.accentColor,
            code: findSnippet(e.codeName)
        ) {
            state.toggle(e.key)
        }
    }
}

struct AdvancedTab: View {
    @ObservedObject var state: StateManager

    private let items: [MenuEntry] = [
        MenuEntry("predict", "location.fill", "PREDICTION", "Dự đoán di chuyển", "PREDICTION"),
        MenuEntry("trigger", "bolt.fill", "TRIGGER BOT", "Tự bắn khi có target", "TRIGGER BOT"),
        MenuEntry("recoil", "arrow.up.arrow.down", "RECOIL FIX", "Giảm giật súng", "RECOIL FIX"),
        MenuEntry("nospread", "circle.dashed", "NO SPREAD", "Không tản mác", nil),
        MenuEntry("silent", "eye.slash.fill", "SILENT AIM", "Ngắm không lộ", nil),
        MenuEntry("flick", "arrow.up.right", "FLICK AIM", "Bật tâm tức thời", nil),
        MenuEntry("scope", "viewfinder", "QUICK SCOPE", "Ngắm nhanh scope", nil),
        MenuEntry("burst", "flame.fill", "BURST LOCK", "Khóa loạt đạn", nil),
        MenuEntry("swap", "arrow.left.arrow.right.square", "FAST SWAP", "Đổi súng nhanh", nil),
        MenuEntry("rung", "waveform", "FIX RUNG", "Khử rung tâm", "AIM DATA CORE"),
        MenuEntry("lo", "drop.fill", "FIX LỐ SMOOTH", "SmoothDamp", "PREDICTION"),
        MenuEntry("nhay", "arrow.up.circle.fill", "NHẠY TÂM", "HeadLock Boost", "AIM DATA CORE"),
        MenuEntry("nhe5", "sparkles", "NHẸ TÂM V5", "SmoothAim 90%", "AIM ASSIST C++"),
        MenuEntry("move", "arrow.right", "MOVE TOWARD", "Di chuyển cơ bản", "MOVE TOWARDS"),
        MenuEntry("core", "cpu", "AIM DATA CORE", "AimData Structure", "AIM DATA CORE"),
        MenuEntry("wallcheck", "rectangle.on.rectangle.slash", "WALL CHECK", "Kiểm tra vật cản", nil),
        MenuEntry("fovcircle", "circle.circle", "FOV CIRCLE", "Vẽ vòng FOV", nil),
        MenuEntry("hitbox", "square.dashed", "HITBOX VIEW", "Hiện hitbox", nil)
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "CHỨC NĂNG NÂNG CAO", icon: "sparkles")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }
        }
    }

    private func buildCard(_ e: MenuEntry) -> some View {
        FeatureCard(
            icon: e.icon,
            title: e.title,
            subtitle: e.sub,
            isOn: state.isOn(e.key),
            accent: state.accentColor,
            code: findSnippet(e.codeName)
        ) {
            state.toggle(e.key)
        }
    }
}

struct CleanTab: View {
    @ObservedObject var state: StateManager

    private let items: [MenuEntry] = [
        MenuEntry("clearcache", "trash.fill", "DỌN CACHE", "Xóa cache hệ thống"),
        MenuEntry("clearls", "internaldrive", "DỌN STORAGE", "Xóa dữ liệu lưu trữ"),
        MenuEntry("clearidb", "cylinder.fill", "DỌN DATA", "Xóa database"),
        MenuEntry("clearimagecache", "photo.fill", "DỌN ẢNH", "Xóa cache ảnh"),
        MenuEntry("clearcookies", "doc.text.fill", "DỌN COOKIES", "Xóa cookies"),
        MenuEntry("clearlogs", "doc.plaintext.fill", "DỌN LOGS", "Xóa log files"),
        MenuEntry("cleartemp", "folder.fill", "DỌN TEMP", "Xóa file tạm"),
        MenuEntry("clearall", "xmark.bin.fill", "DỌN TẤT CẢ", "Xóa toàn bộ cache")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "NHẬN DIỆN THIẾT BỊ", icon: "iphone")
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

            SectionTitle(text: "DỌN DẸP HỆ THỐNG", icon: "trash.fill")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }

            SectionTitle(text: "DỌN DẸP NHANH", icon: "bolt.fill")
            HStack(spacing: 8) {
                cleanBtn("RAM", "memorychip", "DỌN RAM")
                cleanBtn("CACHE", "trash.fill", "DỌN CACHE")
                cleanBtn("ALL", "bolt.fill", "DỌN TẤT CẢ")
            }
        }
    }

    private func buildCard(_ e: MenuEntry) -> some View {
        FeatureCard(
            icon: e.icon,
            title: e.title,
            subtitle: e.sub,
            isOn: state.isOn(e.key),
            accent: state.accentColor,
            code: nil
        ) {
            state.toggle(e.key)
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
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
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

    private let items: [MenuEntry] = [
        MenuEntry("fps", "speedometer", "BUFF FPS", "Tối ưu khung hình"),
        MenuEntry("delay", "timer", "ANTI DELAY", "Khử trễ cảm ứng"),
        MenuEntry("thermal", "thermometer", "THERMAL GUARD", "Chống nóng máy"),
        MenuEntry("battery", "battery.100", "BATTERY SAVE", "Tiết kiệm pin"),
        MenuEntry("wake", "lightbulb.fill", "WAKE LOCK", "Màn hình sáng"),
        MenuEntry("fullscreen", "arrow.up.left.and.arrow.down.right", "FULLSCREEN", "Toàn màn hình"),
        MenuEntry("noparticles", "sparkles", "TẮT HẠT SÁNG", "Giảm particle"),
        MenuEntry("nofx", "film", "TẮT HIỆU ỨNG", "Tắt effect nặng"),
        MenuEntry("backgroundrefresh", "arrow.clockwise.circle.fill", "TẮT BG REFRESH", "Ngừng refresh nền"),
        MenuEntry("reduce", "minus.circle.fill", "GIẢM CHI TIẾT", "Low quality mode"),
        MenuEntry("priority", "arrow.up.square.fill", "PRIORITY BOOST", "Ưu tiên CPU"),
        MenuEntry("memory", "memorychip.fill", "MEMORY BOOST", "Giải phóng RAM")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TỐI ƯU HIỆU NĂNG", icon: "speedometer")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }

            SectionTitle(text: "ĐO THỜI GIAN THỰC", icon: "chart.bar.fill")
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
                InfoRow(
                    key: "CHARGING",
                    value: chargingText
                )
            }
        }
    }

    private var chargingText: String {
        if state.charging {
            return "CÓ"
        }
        return "KHÔNG"
    }

    private func buildCard(_ e: MenuEntry) -> some View {
        FeatureCard(
            icon: e.icon,
            title: e.title,
            subtitle: e.sub,
            isOn: state.isOn(e.key),
            accent: state.accentColor,
            code: nil
        ) {
            state.toggle(e.key)
        }
    }
}

struct GameTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "CHỌN GAME", icon: "gamecontroller.fill")
            GameCard(
                icon: "flame.fill",
                name: "FREE FIRE",
                id: "com.dts.freefireth",
                selected: state.game == "ff",
                accent: state.accentColor
            ) {
                if state.game == "ff" {
                    state.game = nil
                } else {
                    state.game = "ff"
                }
            }
            GameCard(
                icon: "bolt.fill",
                name: "FREE FIRE MAX",
                id: "com.dts.freefiremax",
                selected: state.game == "ffmax",
                accent: state.accentColor
            ) {
                if state.game == "ffmax" {
                    state.game = nil
                } else {
                    state.game = "ffmax"
                }
            }
            GameCard(
                icon: "square.stack.3d.up.fill",
                name: "CẢ HAI GAME",
                id: "FREE FIRE + MAX",
                selected: state.game == "both",
                accent: state.accentColor
            ) {
                if state.game == "both" {
                    state.game = nil
                } else {
                    state.game = "both"
                }
            }

            SectionTitle(text: "THÔNG TIN", icon: "info.circle.fill")
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
                    value: "14.0"
                )
            }
        }
    }

    private func gameName() -> String {
        switch state.game {
        case "ff":
            return "FREE FIRE"
        case "ffmax":
            return "FREE FIRE MAX"
        case "both":
            return "CẢ HAI"
        default:
            return "CHƯA CHỌN"
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
                        RoundedRectangle(corner:Radius: 11)
                             .fill1(
                                LinearGradient(
                                    colors:),
 [
                                        accent,
                                        Color(hex:            "ff0033")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(
                                color: accent.opacity(0.6),
                                radius: 10
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 40, height: 40)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(iconColor)
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
                Text(onOffText)
                    .font(.system(
                        size: 11,
                        weight: .black
                    ))
                    .foregroundColor(onOffColor)
                    .frame(width: 42, height: 26)
                    .background(onOffBg)
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

    private var iconColor: Color {
        if selected {
            return Color.white
        }
        return accent
    }

    private var onOffText: String {
        if selected {
            return "ON"
        }
        return "OFF"
    }

    private var onOffColor: Color {
        if selected {
            return accent
        }
        return Color(hex: "9ca3af")
    }

    private var onOffBg: Color {
        if selected {
            return accent.opacity(0.2)
        }
        return Color.white.opacity(0.05)
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
            .stroke(strokeColor, lineWidth: 1)
    }

    private var strokeColor: Color {
        if selected {
            return accent.opacity(0.6)
        }
        return Color.white.opacity(0.08)
    }
}

struct ThemeTab: View {
    @ObservedObject var state: StateManager

    private let effectKeys: [String] = [
        "particles",
        "grid",
        "aurora",
        "nebula",
        "stars",
        "rings",
        "orbit"
    ]

    private let effectIcons: [String] = [
        "circle.grid.3x3.fill",
        "grid",
        "wave.3.right",
        "cloud.fill",
        "star.fill",
        "circle.dashed",
        "circle.grid.cross"
    ]

    private let effectTitles: [String] = [
        "HẠT BAY",
        "LƯỚI",
        "CỰC QUANG",
        "TINH VÂN",
        "SAO BĂNG",
        "VÒNG XUNG",
        "QUỸ ĐẠO"
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "MÀU CHỦ ĐỀ", icon: "paintpalette.fill")
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ForEach(0..<Theme.accents.count, id: \.self) { i in
                    ThemeSwatch(
                        name: Theme.accents[i].0,
                        hex: Theme.accents[i].1,
                        selected: state.accentHex == Theme.accents[i].1
                    ) {
                        state.setAccent(Theme.accents[i].1)
                    }
                }
            }

            SectionTitle(text: "HIỆU ỨNG NỀN", icon: "wand.and.stars")
            ForEach(0..<effectKeys.count, id: \.self) { i in
                FeatureCard(
                    icon: effectIcons[i],
                    title: effectTitles[i],
                    subtitle: "Hiệu ứng nền",
                    isOn: state.isOn(effectKeys[i]),
                    accent: state.accentColor,
                    code: nil
                ) {
                    state.toggle(effectKeys[i])
                }
            }

            SectionTitle(text: "XEM TRƯỚC", icon: "eye.fill")
            InfoCard {
                InfoRow(
                    key: "MÀU HIỆN TẠI",
                    value: "#\(state.accentHex.uppercased())"
                )
                InfoRow(
                    key: "SỐ MÀU",
                    value: "\(Theme.accents.count)"
                )
                InfoRow(
                    key: "HIỆU ỨNG BẬT",
                    value: "\(countEffects())"
                )
            }
        }
    }

    private func countEffects() -> Int {
        var c = 0
        var i = 0
        while i < effectKeys.count {
            if state.isOn(effectKeys[i]) {
                c = c + 1
            }
            i = i + 1
        }
        return c
    }
}

struct ThemeSwatch: View {
    let name: String
    let hex: String
    let selected: Bool
    let onTap: () -> Void
    @State private var glow: Bool = false

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
                            color: Color(hex: hex).opacity(swatchOpacity),
                            radius: swatchRadius
                        )
                    if selected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.white,
                                lineWidth: 2
                            )
                            .frame(height: 42)
                        Image(systemName: "checkmark")
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
                    .foregroundColor(labelColor)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            if selected {
                withAnimation(
                    .easeInOut(duration: 1.4)
                        .repeatForever(autoreverses: true)
                ) {
                    glow = true
                }
            }
        }
    }

    private var swatchOpacity: Double {
        if glow {
            return 0.9
        }
        return 0.4
    }

    private var swatchRadius: CGFloat {
        if selected {
            return 14
        }
        return 4
    }

    private var labelColor: Color {
        if selected {
            return Color(hex: hex)
        }
        return Color(hex: "9ca3af")
    }
}

struct AccessTab: View {
    @ObservedObject var state: StateManager

    private let items: [MenuEntry] = [
        MenuEntry("a_pointer", "cursorarrow.motionlines", "CON TRỎ ẢO", "Chuột ảo kéo tâm 1px"),
        MenuEntry("a_touch", "hand.point.up.braille.fill", "TOUCH ỔN ĐỊNH", "Chống rung ngón tay"),
        MenuEntry("a_zoom", "plus.magnifyingglass", "ZOOM NGẮM", "Phóng to vùng tâm"),
        MenuEntry("a_back", "hand.tap.fill", "BACK TAP", "Chạm lưng máy"),
        MenuEntry("a_guided", "lock.shield.fill", "GUIDED ACCESS", "Khóa cảm ứng"),
        MenuEntry("a_switch", "switch.2", "SWITCH CONTROL", "Điều khiển công tắc"),
        MenuEntry("a_head", "face.smiling.fill", "HEAD TRACKING", "Điều khiển bằng đầu"),
        MenuEntry("a_assist", "circle.circle.fill", "ASSISTIVE TOUCH", "Nút ảo trên màn hình")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TRỢ NĂNG iOS", icon: "accessibility")
            InfoCard {
                InfoRow(key: "CÁCH DÙNG", value: "BẬT TRONG SETTINGS")
                InfoRow(key: "MỞ NHANH", value: "NÚT BÊN DƯỚI")
                InfoRow(key: "HIỆU QUẢ", value: "KÉO TÂM 1PX")
            }

            SectionTitle(text: "KÍCH HOẠT NHANH", icon: "bolt.fill")
            HStack(spacing: 8) {
                quickBtn(
                    "SETTINGS",
                    "gearshape.fill",
                    Color(hex: "0099ff")
                ) {
                    state.openAppSettings()
                }
                quickBtn(
                    "MỞ GAME",
                    "play.fill",
                    Color(hex: "22c55e")
                ) {
                    state.openSelectedGame()
                }
            }

            SectionTitle(text: "BẬT / TẮT", icon: "switch.2")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }

            SectionTitle(text: "HƯỚNG DẪN CHI TIẾT", icon: "book.fill")
            guideBox(
                "CON TRỎ ẢO",
                "Settings - Accessibility - Touch - AssistiveTouch - BẬT - Devices - chọn iPhone - Pointer Style. Kết nối chuột Bluetooth để kéo tâm chính xác 1 pixel."
            )
            guideBox(
                "TOUCH ỔN ĐỊNH",
                "Settings - Accessibility - Touch - Touch Accommodations - BẬT - Hold Duration 0.10s - Ignore Repeat 0.10s. Giảm rung ngón tay khi kéo tâm."
            )
            guideBox(
                "ZOOM NGẮM",
                "Settings - Accessibility - Zoom - BẬT - Follow Focus. Chạm 3 ngón 2 lần để phóng to vùng tâm 2x-15x."
            )
            guideBox(
                "BACK TAP",
                "Settings - Accessibility - Touch - Back Tap - Double Tap - chọn Shortcut. Chạm 2 lần lưng máy kích hoạt nhanh."
            )
            guideBox(
                "GUIDED ACCESS",
                "Settings - Accessibility - Guided Access - BẬT - Passcode. Khóa cảm ứng ngoài vùng ngắm, chống tap nhầm."
            )
            guideBox(
                "SWITCH CONTROL",
                "Settings - Accessibility - Switch Control - BẬT - Switches - Add. Điều khiển tâm bằng công tắc Bluetooth."
            )
            guideBox(
                "HEAD TRACKING",
                "Settings - Accessibility - Pointer Control - Head Tracking - BẬT. Dùng chuyển động đầu điều khiển tâm."
            )
            guideBox(
                "ASSISTIVE TOUCH",
                "Settings - Accessibility - Touch - AssistiveTouch - BẬT - Custom Top Level Menu. Tạo nút ảo kéo tâm."
            )

            SectionTitle(text: "GHI CHÚ", icon: "info.circle.fill")
            InfoCard {
                InfoRow(key: "INJECT GAME", value: "KHÔNG HỖ TRỢ")
                InfoRow(key: "LÝ DO", value: "IOS SANDBOX")
                InfoRow(key: "THAY THẾ", value: "TRỢ NĂNG HỆ THỐNG")
            }
        }
    }

    private func buildCard(_ e: MenuEntry) -> some View {
        FeatureCard(
            icon: e.icon,
            title: e.title,
            subtitle: e.sub,
            isOn: state.isOn(e.key),
            accent: state.accentColor,
            code: nil
        ) {
            state.toggle(e.key)
        }
    }

    private func quickBtn(
        _ title: String,
        _ icon: String,
        _ color: Color,
        _ action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            action()
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        color.opacity(0.7),
                        color.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        color.opacity(0.7),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func guideBox(
        _ title: String,
        _ content: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(state.accentColor)
                Text(title)
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(state.accentColor)
                Spacer()
            }
            Text(content)
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "9ca3af"))
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .padding(10)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

struct SystemTab: View {
    @ObservedObject var state: StateManager

    private let items: [MenuEntry] = [
        MenuEntry("autosave", "square.and.arrow.down.fill", "TỰ ĐỘNG LƯU", "Lưu cài đặt"),
        MenuEntry("haptic", "hand.tap.fill", "RUNG PHẢN HỒI", "Haptic feedback"),
        MenuEntry("sound", "speaker.wave.2.fill", "ÂM THANH", "Sound effect"),
        MenuEntry("debug", "ant.fill", "CHẾ ĐỘ DEBUG", "Debug info"),
        MenuEntry("safe", "checkmark.shield.fill", "CHẾ ĐỘ AN TOÀN", "Safe mode"),
        MenuEntry("killswitch", "xmark.octagon.fill", "KILL SWITCH", "Tắt toàn bộ"),
        MenuEntry("notify", "bell.fill", "THÔNG BÁO", "Notification"),
        MenuEntry("logmode", "doc.text.magnifyingglass", "LOG MODE", "Ghi log hoạt động")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "THÔNG TIN HỆ THỐNG", icon: "info.circle.fill")
            InfoCard {
                InfoRow(
                    key: "PHIÊN BẢN",
                    value: "V14 ACCESS"
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
                InfoRow(
                    key: "CHỨC NĂNG",
                    value: "\(state.activeCount())"
                )
            }

            SectionTitle(text: "CÀI ĐẶT", icon: "gearshape.fill")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }

            SectionTitle(text: "KÍCH HOẠT BUFF", icon: "bolt.fill")
            Button(action: {
                state.runBuffSequence()
                UIImpactFeedbackGenerator(style: .heavy)
                    .impactOccurred()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("INJECT + MỞ GAME")
                        .font(.system(size: 12, weight: .black))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: [
                            state.accentColor,
                            Color(hex: "ff0033")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(
                    color: state.accentColor.opacity(0.7),
                    radius: 14
                )
            }
            .buttonStyle(.plain)

            SectionTitle(text: "HÀNH ĐỘNG", icon: "bolt.fill")
            HStack(spacing: 8) {
                actionBtn(
                    "RESET",
                    "arrow.counterclockwise",
                    Color(hex: "fbbf24")
                ) {
                    state.resetAll()
                    state.showToastMessage("ĐÃ RESET TẤT CẢ")
                }
                actionBtn(
                    "LOGOUT",
                    "arrow.right.square.fill",
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
        let v = UserDefaults.standard.string(
            forKey: "dl_utral_tier"
        )
        if v == nil {
            return "VIP"
        }
        return v!
    }

    private func maskKey() -> String {
        let k = UserDefaults.standard.string(
            forKey: "dl_utral_auth"
        )
        if k == nil {
            return "------"
        }
        if k!.count <= 8 {
            return "------"
        }
        let pre = k!.prefix(4)
        let suf = k!.suffix(4)
        return "\(pre)-****-\(suf)"
    }

    private func buildCard(_ e: MenuEntry) -> some View {
        FeatureCard(
            icon: e.icon,
            title: e.title,
            subtitle: e.sub,
            isOn: state.isOn(e.key),
            accent: state.accentColor,
            code: nil
        ) {
            state.toggle(e.key)
        }
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
                Image(systemName: icon)
                    .font(.system(
                        size: 14,
                        weight: .bold
                    ))
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
                .frame(height alignment: .bottom
        )
    }
}

struct ToastView: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(color)
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
    @State private var rotate: Bool = false
    @State private var progress: Double = 0.0
    @State private var dotCount: Int = 0
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    state.accentColor.opacity(0.25),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 320
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()

                ringView

                VStack(spacing: 8) {
                    Text("HỆ THỐNG ĐANG INJECT VÀO GAME")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text("VUI LÒNG CHỜ" + dots)
                        .font(.system(
                            size: 11,
                            weight: .heavy,
                            design: .monospaced
                        ))
                        .foregroundColor(state.accentColor)
                }

                barView

                stepBox

                Spacer()

                footerNote
            }
            .padding(20)
        }
        .onAppear(perform: start)
    }

    private var dots: String {
        var s = ""
        var i = 0
        while i < (dotCount % 4) {
            s = s + "."
            i = i + 1
        }
        return s
    }

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(
                    state.accentColor.opacity(0.15),
                    lineWidth: 4
                )
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: 0.3)
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
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(rotationValue))

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            state.accentColor.opacity(0.3),
                            Color(hex: "ff0033").opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 90)

            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(.white)
                .shadow(
                    color: state.accentColor.opacity(0.9),
                    radius: 12
                )
                .scaleEffect(pulse ? 1.08 : 1.0)
        }
    }

    private var rotationValue: Double {
        if rotate {
            return 360
        }
        return 0
    }

    private var barView: some View {
        VStack(spacing: 6) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    state.accentColor,
                                    Color(hex: "ff0033")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: g.size.width
                                * CGFloat(progress)
                        )
                        .shadow(
                            color: state.accentColor.opacity(0.7),
                            radius: 8
                        )
                }
            }
            .frame(height: 6)

            HStack {
                Text("TIẾN ĐỘ")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(Color(hex: "9ca3af"))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(
                        size: 10,
                        weight: .black,
                        design: .monospaced
                    ))
                    .foregroundColor(state.accentColor)
            }
        }
        .padding(.horizontal, 40)
    }

    private var stepBox: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(state.accentColor)
                .frame(width: 6, height: 6)
                .shadow(
                    color: state.accentColor,
                    radius: 6
                )
            Text(stepText)
                .font(.system(
                    size: 10,
                    weight: .heavy
                ))
                .foregroundColor(Color(hex: "9ca3af"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }

    private var stepText: String {
        if progress < 0.25 {
            return "ĐANG PHÂN TÍCH"
        }
        if progress < 0.50 {
            return "ĐANG NẠP MODULE"
        }
        if progress < 0.75 {
            return "ĐANG KÍCH HOẠT BUFF"
        }
        if progress < 0.95 {
            return "ĐANG MỞ GAME"
        }
        return "HOÀN TẤT"
    }

    private var footerNote: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 9))
                .foregroundColor(Color(hex: "6b7280"))
            Text("KHÔNG THOÁT ỨNG DỤNG")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(Color(hex: "6b7280"))
        }
    }

    private func start() {
        withAnimation(
            .linear(duration: 1.0)
                .repeatForever(autoreverses: false)
        ) {
            rotate = true
        }
        withAnimation(
            .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
        ) {
            pulse = true
        }
        withAnimation(.linear(duration: 2.8)) {
            progress = 1.0
        }
        Timer.scheduledTimer(
            withTimeInterval: 0.35,
            repeats: true
        ) { t in
            dotCount = dotCount + 1
            if dotCount > 40 {
                t.invalidate()
            }
        }
    }
}

struct FooterBar: View {
    @ObservedObject var state: StateManager
    @State private var pulse: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 6, height: 6)
                .scaleEffect(pulseScale)
                .shadow(
                    color: Color(hex: "22c55e"),
                    radius: pulseRadius
                )
            Text("HOẠT ĐỘNG")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(Color(hex: "22c55e"))
            Text("|")
                .foregroundColor(Color(hex: "6b7280"))
            Text("\(state.activeCount()) CHỨC NĂNG")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(Color(hex: "9ca3af"))
            Spacer()
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 8))
                .foregroundColor(Color.white.opacity(0.3))
            Text("ZWILZ HLONG V14")
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
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                pulse = true
            }
        }
    }

    private var pulseScale: CGFloat {
        if pulse {
            return 1.4
        }
        return 1.0
    }

    private var pulseRadius: CGFloat {
        if pulse {
            return 8
        }
        return 4
    }
}

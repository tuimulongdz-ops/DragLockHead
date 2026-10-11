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
        GeometryReader { geo in
            ZStack {
                menuBg
                VStack(spacing: 6) {
                    HeaderBar(state: state)
                    HudRow(state: state)
                    TabBar(state: state)
                    scrollArea
                    FooterBar(state: state)
                }
                .frame(width: geo.size.width - 16)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 8)
                .padding(.top, 2)
                .padding(.bottom, 2)
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
    }

    private var scrollArea: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                contentForTab
            }
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
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

    var body: some View {
        HStack(spacing: 8) {
            avatarBadge
            titleBlock
            Spacer(minLength: 4)
            StatusDot()
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
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
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    state.accentColor.opacity(0.55),
                    lineWidth: 1
                )
        )
        .shadow(
            color: state.accentColor.opacity(0.25),
            radius: 10
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
                .frame(width: 46, height: 46)
                Image("avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(avatarGrad, lineWidth: 2)
                    )
                    .shadow(
                        color: state.accentColor.opacity(0.7),
                        radius: 8
                    )
            }
            .frame(width: 46, height: 46)
        } else {
            ZStack {
                Circle()
                    .fill(avatarGrad)
                    .frame(width: 34, height: 34)
                    .shadow(
                        color: state.accentColor.opacity(0.6),
                        radius: 8
                    )
                Text("ZH")
                    .font(.system(
                        size: 12,
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
        VStack(alignment: .leading, spacing: 1) {
            Text("ZWILZ HLONG VIP")
                .font(.system(size: 11.5, weight: .black))
                .foregroundColor(state.accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("SUPER MENU V15")
                .font(.system(size: 7.5, weight: .bold))
                .foregroundColor(Color(hex: "9ca3af"))
                .lineLimit(1)
        }
        .layoutPriority(1)
    }
}

struct StatusDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 10, height: 10)
                .scaleEffect(pulse ? 1.8 : 1.0)
                .opacity(pulse ? 0.15 : 1.0)
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 7, height: 7)
                .scaleEffect(pulse ? 1.2 : 1.0)
                .opacity(pulse ? 0.4 : 1.0)
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 4, height: 4)
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
        HStack(spacing: 4) {
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
        .frame(maxWidth: .infinity)
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
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 6.5, weight: .bold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 7, weight: .heavy))
                    .foregroundColor(Color(hex: "9ca3af"))
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(
                    size: 10.5,
                    weight: .black,
                    design: .monospaced
                ))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.045))
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
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

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<keys.count, id: \.self) { i in
                tabBtn(
                    key: keys[i],
                    label: labels[i],
                    icon: icons[i]
                )
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.045))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
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
                    .cornerRadius(7)
                    .shadow(
                        color: state.accentColor.opacity(0.5),
                        radius: 5
                    )
                }
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .bold))
                    Text(label)
                        .font(.system(size: 7.5, weight: .heavy))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .foregroundColor(tabColor(key))
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
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
        HStack(spacing: 6) {
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
                .frame(width: 3, height: 12)
                .shadow(
                    color: Color(hex: "0099ff"),
                    radius: 3
                )
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Color(hex: "00d4ff"))
            Text(text)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(Color(hex: "00d4ff"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 2)
        .padding(.top, 4)
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
        HStack(spacing: 6) {
            Button(action: onToggle) {
                cardContent
            }
            .buttonStyle(.plain)
            if code != nil {
                codeBtn
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(bgLayer)
        .cornerRadius(12)
        .overlay(strokeLayer)
        .shadow(
            color: shadowColor,
            radius: isOn ? 12 : 3
        )
        .sheet(isPresented: $showCode) {
            SimpleCodeView(
                title: title,
                code: code ?? ""
            )
        }
    }

    private var shadowColor: Color {
        if isOn {
            return accent.opacity(0.3)
        }
        return Color.clear
    }

    private var cardContent: some View {
        HStack(spacing: 9) {
            iconBox
            textBox
            Spacer(minLength: 4)
            switchView
        }
    }

    private var codeBtn: some View {
        Button(action: {
            showCode = true
        }) {
            HStack(spacing: 3) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 7, weight: .black))
                Text("CODE")
                    .font(.system(size: 7, weight: .black))
            }
            .foregroundColor(accent)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(accent.opacity(0.15))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        accent.opacity(0.4),
                        lineWidth: 1
                    )
            )
        }
        .layoutPriority(2)
    }

    private var iconBox: some View {
        ZStack {
            if isOn {
                RoundedRectangle(cornerRadius: 9)
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
                    .frame(width: 32, height: 32)
                    .shadow(
                        color: accent.opacity(0.7),
                        radius: 8
                    )
            } else {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 32, height: 32)
            }
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(iconColor)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
        .layoutPriority(2)
    }

    private var iconColor: Color {
        if isOn {
            return Color.white
        }
        return accent
    }

    private var textBox: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(subtitle)
                .font(.system(size: 8.5))
                .foregroundColor(Color(hex: "9ca3af"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .layoutPriority(1)
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
                    .frame(width: 40, height: 22)
                    .shadow(
                        color: accent.opacity(0.7),
                        radius: 8
                    )
            } else {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 22)
            }
            Circle()
                .fill(Color.white)
                .frame(width: 18, height: 18)
                .shadow(
                    color: .black.opacity(0.4),
                    radius: 2
                )
                .offset(x: isOn ? 9 : -9)
        }
        .frame(width: 40, height: 22)
        .layoutPriority(3)
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
        RoundedRectangle(cornerRadius: 12)
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
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 4)
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
        MenuEntry("aimassist", "wand.and.stars", "AIM ASSIST", "Kéo mượt và dự đoán", "AIM ASSIST C++"),
        MenuEntry("aimlock", "target", "AIM LOCK", "Khóa mục tiêu", "AIMLOCK C++"),
        MenuEntry("smooth", "arrow.left.arrow.right", "SMOOTH TARGET", "Chuyển mục tiêu mượt", "PREDICTION"),
        MenuEntry("boneaim", "figure.stand", "BONE AIM", "Ngắm theo xương", "BONE SCANNER"),
        MenuEntry("flickaim", "bolt.horizontal.fill", "FLICK AIM", "Bật tâm siêu nhanh", nil),
        MenuEntry("microadjust", "slider.horizontal.3", "MICRO ADJUST", "Vi chỉnh tâm", nil),
        MenuEntry("stickyaim", "pin.fill", "STICKY AIM", "Dính mục tiêu", nil)
    ]

    var body: some View {
        VStack(spacing: 8) {
            SectionTitle(text: "HỖ TRỢ KÉO TÂM", icon: "target")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }
        }
        .frame(maxWidth: .infinity)
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
        VStack(spacing: 8) {
            SectionTitle(text: "CHỨC NĂNG NÂNG CAO", icon: "sparkles")
            ForEach(0..<items.count, id: \.self) { i in
                buildCard(items[i])
            }
        }
        .frame(maxWidth: .infinity)
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
        VStack(spacing: 8) {
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
            HStack(spacing: 6) {
                cleanBtn("RAM", "memorychip", "DỌN RAM")
                cleanBtn("CACHE", "trash.fill", "DỌN CACHE")
                cleanBtn("ALL", "bolt.fill", "DỌN TẤT CẢ")
            }
        }
        .frame(maxWidth: .infinity)
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
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(
                        size: 8.5,
                        weight: .black
                    ))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
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
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
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
        VStack(spacing: 8) {
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
                    key: "ĐANG SẠC",
                    value: chargingText
                )
            }
        }
        .frame(maxWidth: .infinity)
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
        VStack(spacing: 8) {
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
                    value: "15.0"
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func gameName() -> String {
        if state.game == "ff" {
            return "FREE FIRE"
        }
        if state.game == "ffmax" {
            return "FREE FIRE MAX"
        }
        if state.game == "both" {
            return "CẢ HAI"
        }
        return "CHƯA CHỌN"
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
            HStack(spacing: 9) {
                ZStack {
                    if selected {
                        RoundedRectangle(cornerRadius: 9)
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
                            .frame(width: 32, height: 32)
                            .shadow(
                                color: accent.opacity(0.6),
                                radius: 8
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 32, height: 32)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(iconColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(
                            Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
                .layoutPriority(2)

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    Text(name)
                        .font(.system(
                            size: 11,
                            weight: .bold
                        ))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(id)
                        .font(.system(size: 8.5))
                        .foregroundColor(
                            Color(hex: "9ca3af")
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .layoutPriority(1)

                Spacer(minLength: 4)

                Text(onOffText)
                    .font(.system(
                        size: 10,
                        weight: .black
                    ))
                    .foregroundColor(onOffColor)
                    .frame(width: 38, height: 22)
                    .background(onOffBg)
                    .cornerRadius(7)
                    .layoutPriority(3)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(bg)
            .cornerRadius(12)
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
        RoundedRectangle(cornerRadius: 12)
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
        VStack(spacing: 8) {
            SectionTitle(text: "MÀU CHỦ ĐỀ", icon: "paintpalette.fill")
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6)
                ],
                spacing: 8
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
            .frame(maxWidth: .infinity)

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
                    value: "#" + state.accentHex.uppercased()
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
        .frame(maxWidth: .infinity)
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

    var body: some View {
        Button(action: {
            onTap()
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        }) {
            VStack(spacing: 3) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: hex))
                        .frame(height: 30)
                        .shadow(
                            color: Color(hex: hex).opacity(0.5),
                            radius: 4
                        )
                    if selected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color.white,
                                lineWidth: 2
                            )
                            .frame(height: 30)
                        Image(systemName: "checkmark")
                            .font(.system(
                                size: 12,
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
                        size: 7,
                        weight: .heavy
                    ))
                    .foregroundColor(labelColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .buttonStyle(.plain)
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
        VStack(spacing: 8) {
            SectionTitle(text: "TRỢ NĂNG iOS", icon: "accessibility")
            InfoCard {
                InfoRow(key: "CÁCH DÙNG", value: "BẬT TRONG SETTINGS")
                InfoRow(key: "MỞ NHANH", value: "NÚT BÊN DƯỚI")
                InfoRow(key: "HIỆU QUẢ", value: "KÉO TÂM 1PX")
            }

            SectionTitle(text: "KÍCH HOẠT NHANH", icon: "bolt.fill")
            HStack(spacing: 6) {
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
                "Settings - Accessibility - Touch - AssistiveTouch - BẬT - Devices - chọn iPhone - Pointer Style."
            )
            guideBox(
                "TOUCH ỔN ĐỊNH",
                "Settings - Accessibility - Touch - Touch Accommodations - BẬT - Hold Duration 0.10s."
            )
            guideBox(
                "ZOOM NGẮM",
                "Settings - Accessibility - Zoom - BẬT - Follow Focus. Chạm 3 ngón 2 lần."
            )
            guideBox(
                "BACK TAP",
                "Settings - Accessibility - Touch - Back Tap - Double Tap - chọn Shortcut."
            )
            guideBox(
                "GUIDED ACCESS",
                "Settings - Accessibility - Guided Access - BẬT - Passcode."
            )
            guideBox(
                "SWITCH CONTROL",
                "Settings - Accessibility - Switch Control - BẬT - Switches - Add."
            )
            guideBox(
                "HEAD TRACKING",
                "Settings - Accessibility - Pointer Control - Head Tracking - BẬT."
            )
            guideBox(
                "ASSISTIVE TOUCH",
                "Settings - Accessibility - Touch - AssistiveTouch - BẬT - Custom Top Level Menu."
            )

            SectionTitle(text: "GHI CHÚ", icon: "info.circle.fill")
            InfoCard {
                InfoRow(key: "INJECT GAME", value: "KHÔNG HỖ TRỢ")
                InfoRow(key: "LÝ DO", value: "IOS SANDBOX")
                InfoRow(key: "THAY THẾ", value: "TRỢ NĂNG HỆ THỐNG")
            }
        }
        .frame(maxWidth: .infinity)
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
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
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
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
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
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(state.accentColor)
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(state.accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
            }
            Text(content)
                .font(.system(size: 9))
                .foregroundColor(Color(hex: "9ca3af"))
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .padding(8)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
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
        VStack(spacing: 8) {
            SectionTitle(text: "THÔNG TIN HỆ THỐNG", icon: "info.circle.fill")
            InfoCard {
                InfoRow(
                    key: "PHIÊN BẢN",
                    value: "V15 ACCESS"
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

            SectionTitle(text: "INJECT VÀ MỞ GAME", icon: "bolt.fill")
            Button(action: {
                state.runBuffSequence()
                UIImpactFeedbackGenerator(style: .heavy)
                    .impactOccurred()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("INJECT + MỞ GAME")
                        .font(.system(size: 11.5, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
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
                .cornerRadius(10)
                .shadow(
                    color: state.accentColor.opacity(0.7),
                    radius: 12
                )
            }
            .buttonStyle(.plain)

            SectionTitle(text: "HÀNH ĐỘNG", icon: "bolt.fill")
            HStack(spacing: 6) {
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
        .frame(maxWidth: .infinity)
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
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(
                        size: 13,
                        weight: .bold
                    ))
                Text(title)
                    .font(.system(
                        size: 11,
                        weight: .black
                    ))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
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
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
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
        .padding(9)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
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
        HStack(spacing: 4) {
            Text(key)
                .font(.system(size: 9.5, weight: .heavy))
                .foregroundColor(Color(hex: "9ca3af"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .layoutPriority(1)
            Spacer(minLength: 4)
            Text(value)
                .font(.system(
                    size: 10,
                    weight: .black,
                    design: .monospaced
                ))
                .foregroundColor(Color(hex: "00d4ff"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .layoutPriority(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .padding(.horizontal, 3)
    }
}

struct ToastView: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.4), radius: 10)
    }
}

struct InjectOverlay: View {
    @ObservedObject var state: StateManager
    @State private var rotate: Bool = false
    @State private var progress: Double = 0.0
    @State private var dotCount: Int = 0
    @State private var pulse: Bool = false

    private let dotTimer = Timer.publish(
        every: 0.3,
        on: .main,
        in: .common
    ).autoconnect()

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

            VStack(spacing: 20) {
                Spacer()

                ringView

                VStack(spacing: 6) {
                    Text("HỆ THỐNG ĐANG INJECT VÀO GAME")
                        .font(.system(size: 12.5, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

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
        .onReceive(dotTimer) { _ in
            dotCount = dotCount + 1
        }
    }

    private var dots: String {
        var s = ""
        var i = 0
        let count = dotCount % 4
        while i < count {
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
                .rotationEffect(.degrees(rotate ? 360 : 0))

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

    private var barView: some View {
        VStack(spacing: 5) {
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
        .frame(maxWidth: .infinity)
    }

    private var stepBox: some View {
        HStack(spacing: 7) {
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
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.04))
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
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
        HStack(spacing: 5) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 9))
                .foregroundColor(Color(hex: "6b7280"))
            Text("KHÔNG THOÁT ỨNG DỤNG")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(Color(hex: "6b7280"))
                .lineLimit(1)
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
    }
}

struct FooterBar: View {
    @ObservedObject var state: StateManager
    @State private var pulse: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 5, height: 5)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .shadow(
                    color: Color(hex: "22c55e"),
                    radius: pulse ? 7 : 3
                )
            Text("HOẠT ĐỘNG")
                .font(.system(size: 8.5, weight: .heavy))
                .foregroundColor(Color(hex: "22c55e"))
                .lineLimit(1)
            Text("|")
                .foregroundColor(Color(hex: "6b7280"))
            Text("\(state.activeCount()) CHỨC NĂNG")
                .font(.system(size: 8.5, weight: .heavy))
                .foregroundColor(Color(hex: "9ca3af"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 4)
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 7.5))
                .foregroundColor(Color.white.opacity(0.3))
            Text("ZWILZ HLONG V15")
                .font(.system(size: 7.5, weight: .heavy))
                .foregroundColor(Color.white.opacity(0.3))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
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
}

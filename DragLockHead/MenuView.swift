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
                HeaderBar()
                HudRow(state: state)
                TabBar(state: state)
                scrollArea
                FooterBar(state: state)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 4)

            toastLayer
            injectLayer
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
        case "advanced": AdvancedTab(state: state)
        case "code": CodeLibraryView()
        case "clean": CleanTab(state: state)
        case "perf": PerfTab(state: state)
        case "visual": VisualTab(state: state)
        case "game": GameTab(state: state)
        case "system": SystemTab(state: state)
        default: EmptyView()
        }
    }

    @ViewBuilder
    private var toastLayer: some View {
        if state.showToast {
            VStack {
                ToastView(text: state.toast)
                Spacer()
            }
            .padding(.top, 8)
            .zIndex(999)
        }
    }

    @ViewBuilder
    private var injectLayer: some View {
        if state.isInjecting {
            InjectOverlay()
                .zIndex(1000)
        }
    }

    private var menuBg: some View {
        ZStack {
            Color(hex: "06080d")

            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0099ff")
                        .opacity(0.32),
                    .clear
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff0033")
                        .opacity(0.24),
                    .clear
                ]),
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 400
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "a855f7")
                        .opacity(0.18),
                    .clear
                ]),
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - HEADER
struct HeaderBar: View {
    var body: some View {
        HStack(spacing: 10) {
            logoBadge
            titleBlock
            Spacer()
            StatusDot()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff")
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
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff")
                                .opacity(0.6),
                            Color(hex: "00d4ff")
                                .opacity(0.25),
                            Color(hex: "ff0033")
                                .opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color(hex: "0099ff")
                .opacity(0.25),
            radius: 12
        )
    }

    private var logoBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff"),
                            Color(hex: "00d4ff")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 42, height: 42)
                .shadow(
                    color: Color(hex: "0099ff")
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

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("ZWILZ HLONG AIM VIP")
                .font(
                    .system(
                        size: 13.5,
                        weight: .black
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
                .lineLimit(1)
            Text("DRAGLOCK UTRAL - v9.0")
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
    @State private var pulse: Bool = false

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
                    : Color(hex: "00d4ff")
            )
            HudItem(
                label: "PING",
                value: "\(state.ping)",
                color: Color(hex: "00d4ff")
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
        ("aim", "KEO TAM"),
        ("advanced", "NANG CAO"),
        ("code", "CODE"),
        ("clean", "DON DEP"),
        ("perf", "HIEU NANG"),
        ("visual", "HIEN THI"),
        ("game", "GAME"),
        ("system", "HE THONG")
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
                            Color(hex: "0099ff"),
                            Color(hex: "00d4ff"),
                            Color(hex: "ff0033")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(11)
                    .shadow(
                        color: Color(hex: "00d4ff")
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
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 11) {
                iconBox
                textBox
                Spacer()
                switchView
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(bgLayer)
            .cornerRadius(16)
            .overlay(strokeLayer)
        }
        .buttonStyle(.plain)
    }

    private var iconBox: some View {
        ZStack {
            if isOn {
                RoundedRectangle(cornerRadius: 11)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "0099ff"),
                                Color(hex: "00d4ff")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(
                        color: Color(hex: "00d4ff")
                            .opacity(0.5),
                        radius: 8
                    )
            } else {
                RoundedRectangle(cornerRadius: 11)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white
                                    .opacity(0.08),
                                Color.white
                                    .opacity(0.03)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 40, height: 40)
            }
            Text(icon)
                .font(
                    .system(
                        size: 16,
                        weight: .black
                    )
                )
                .foregroundColor(.white)
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
                                Color(hex: "0099ff"),
                                Color(hex: "00d4ff")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 48, height: 28)
                    .shadow(
                        color: Color(hex: "00d4ff")
                            .opacity(0.6),
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
                        Color(hex: "0099ff")
                            .opacity(0.2),
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
                LinearGradient(
                    colors: isOn
                        ? [
                            Color(hex: "00d4ff")
                                .opacity(0.7),
                            Color(hex: "ff0033")
                                .opacity(0.4)
                          ]
                        : [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.08)
                          ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

// MARK: - CUSTOM SLIDER
struct CustomSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let suffix: String

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(
                        .system(
                            size: 11,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.white)
                Spacer()
                Text("\(fmt())\(suffix)")
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Color(hex: "0099ff")
                            .opacity(0.15)
                    )
                    .cornerRadius(6)
            }

            Slider(value: $value, in: range, step: step)
                .accentColor(
                    Color(hex: "00d4ff")
                )
        }
        .padding(14)
        .background(
            Color.white.opacity(0.045)
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }

    private func fmt() -> String {
        if step >= 1 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f", value)
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
                        LinearGradient(
                            colors: [
                                Color(hex: "0099ff")
                                    .opacity(0.35),
                                Color(hex: "00d4ff")
                                    .opacity(0.15),
                                Color(hex: "ff0033")
                                    .opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
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
            assistiveBtn
            injectBtn
        }
    }

    private var resetBtn: some View {
        Button(action: resetAction) {
            VStack(spacing: 2) {
                Image(
                    systemName: "arrow.counterclockwise"
                )
                .font(
                    .system(
                        size: 14,
                        weight: .bold
                    )
                )
                Text("DAT LAI")
                    .font(
                        .system(
                            size: 9,
                            weight: .black
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
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

    private var assistiveBtn: some View {
        Button(action: assistAction) {
            VStack(spacing: 2) {
                Image(
                    systemName: "circle.dashed"
                )
                .font(
                    .system(
                        size: 14,
                        weight: .bold
                    )
                )
                Text("TAM AO")
                    .font(
                        .system(
                            size: 9,
                            weight: .black
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Color.white.opacity(0.06)
            )
            .foregroundColor(.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color(hex: "00d4ff")
                            .opacity(0.35),
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
                    Image(
                        systemName: "bolt.fill"
                    )
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                }
                Text(
                    state.isInjecting
                        ? "DANG INJECT..."
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
            .background(injectGrad)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(
                color: Color(hex: "0099ff")
                    .opacity(0.5),
                radius: 12
            )
        }
        .buttonStyle(.plain)
        .disabled(state.isInjecting)
    }

    private var injectGrad: LinearGradient {
        LinearGradient(
            colors: state.isInjecting
                ? [
                    Color(hex: "6b7280"),
                    Color(hex: "9ca3af")
                  ]
                : [
                    Color(hex: "0099ff"),
                    Color(hex: "00d4ff"),
                    Color(hex: "ff0033")
                  ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func resetAction() {
        state.resetAll()
        state.showToastMessage("DA DAT LAI")
        UIImpactFeedbackGenerator(
            style: .medium
        ).impactOccurred()
    }

    private func assistAction() {
        openAssistive()
        state.showToastMessage("MO TRO NANG - CHAM")
    }

    private func handleInject() {
        if state.game == nil {
            state.showToastMessage("CHON GAME TRUOC")
            UINotificationFeedbackGenerator()
                .notificationOccurred(.warning)
            return
        }

        if state.activeCount() == 0 {
            state.showToastMessage(
                "BAT IT NHAT 1 CHUC NANG"
            )
            UINotificationFeedbackGenerator()
                .notificationOccurred(.warning)
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
                state.showToastMessage(
                    ok
                        ? "DANG MO GAME..."
                        : "KHONG TIM THAY GAME"
                )
            }
        }
    }

    private func openAssistive() {
        let schemes = [
            "App-Prefs:root=ACCESSIBILITY",
            "App-Prefs:root=ACCESSIBILITY"
        ]
        for s in schemes {
            if let u = URL(string: s) {
                if UIApplication.shared
                    .canOpenURL(u) {
                    UIApplication.shared.open(
                        u,
                        options: [:],
                        completionHandler: nil
                    )
                    return
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

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: "00d4ff"))
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
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff"),
                            Color(hex: "00d4ff"),
                            Color(hex: "ff0033")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color(hex: "00d4ff")
                .opacity(0.5),
            radius: 14
        )
    }
}

// MARK: - INJECT OVERLAY
struct InjectOverlay: View {
    @State private var progress: Double = 0
    @State private var message: String = "DANG KHOI TAO"

    private let messages = [
        "KIEM TRA CAU HINH...",
        "XAC THUC THIET BI...",
        "AP DUNG CHUC NANG...",
        "KICH HOAT TAM AO...",
        "TOI UU HIEU NANG...",
        "HOAN TAT!"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                progressRing
                Text(message)
                    .font(
                        .system(
                            size: 13,
                            weight: .black
                        )
                    )
                    .foregroundColor(.white)
                Text("ZWILZ HLONG UTRAL ENGINE")
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

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(hex: "0099ff")
                        .opacity(0.2),
                    lineWidth: 6
                )
                .frame(width: 120, height: 120)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff"),
                            Color(hex: "00d4ff"),
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
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
        }
        .shadow(
            color: Color(hex: "0099ff")
                .opacity(0.6),
            radius: 20
        )
    }

    private func animate() {
        for (i, msg) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(i) * 0.28
            ) {
                withAnimation(
                    .easeInOut(duration: 0.2)
                ) {
                    message = msg
                    progress =
                        Double(i + 1)
                        / Double(messages.count)
                }
            }
        }
    }
}

// MARK: - AIM TAB
struct AimTab: View {
    @ObservedObject var state: StateManager

    private let cross: [
        (String, String, String, String)
    ] = [
        ("virtualcross", "1",
         "TAM AO PRO",
         "Crosshair de tren man hinh"),
        ("aimoverlay", "2",
         "AIM CROSSHAIR",
         "Tam ngam do don gian"),
        ("aimbg", "3",
         "AIM BACKGROUND",
         "Vong tam ngam nen VIP"),
        ("dotcenter", "4",
         "DOT CENTER",
         "Cham do chinh giua"),
        ("crossline", "5",
         "CROSS LINE",
         "Duong chu thap 400px")
    ]

    private let aim: [
        (String, String, String, String)
    ] = [
        ("microaim", "6", "NHE TAM",
         "Crosshair micro nho"),
        ("headlock", "7", "BAM DAU",
         "Duong guide vi tri dau"),
        ("aimlock", "8", "AIMLOCK VISUAL",
         "Vong lock nhap nhay"),
        ("ghostcross", "9", "GHOST CROSSHAIR",
         "Tam ao theo ngon tay"),
        ("aimtrace", "A", "AIM TRACE",
         "Vet mo theo ngon tay"),
        ("magnetic", "B", "MAGNETIC",
         "Vong hut pulse"),
        ("sensdisplay", "C", "SENS DISPLAY",
         "Hien sensitivity")
    ]

    private let touch: [
        (String, String, String, String)
    ] = [
        ("touchsmooth", "D", "TOUCH SMOOTH",
         "Lam muot cam ung"),
        ("prevscroll", "E", "PREVENT SCROLL",
         "Chan cuon trang"),
        ("prevzoom", "F", "PREVENT ZOOM",
         "Chan pinch zoom"),
        ("prevselect", "G", "PREVENT SELECT",
         "Chan boi den"),
        ("prevcontext", "H", "PREVENT LONG",
         "Chan menu giu lau")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TAM AO & CROSSHAIR")
            ForEach(cross, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }
            SectionTitle(text: "AIM NANG CAO")
            ForEach(aim, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }
            SectionTitle(text: "CHONG DELAY")
            ForEach(touch, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }
            SectionTitle(text: "TUY CHINH")
            CustomSlider(
                label: "KICH THUOC TAM",
                value: $state.crosshairSize,
                range: 60...240,
                step: 10,
                suffix: ""
            )
            CustomSlider(
                label: "DO MO TAM AO",
                value: $state.crosshairOpacity,
                range: 0.3...1.0,
                step: 0.05,
                suffix: ""
            )
            CustomSlider(
                label: "SENS GIA LAP",
                value: $state.sensValue,
                range: 50...200,
                step: 5,
                suffix: ""
            )
        }
    }

    private func card(
        _ k: String,
        _ i: String,
        _ t: String,
        _ s: String
    ) -> some View {
        FeatureCard(
            icon: i,
            title: t,
            subtitle: s,
            isOn: state.isOn(k)
        ) {
            state.toggle(k)
        }
    }
}

// MARK: - ADVANCED TAB
struct AdvancedTab: View {
    @ObservedObject var state: StateManager

    private let visuals: [
        (String, String, String, String)
    ] = [
        ("aimpulse", "1", "AIM PULSE",
         "Tam ao dap nhip tim"),
        ("aimradar", "2", "AIM RADAR",
         "Song radar quanh tam"),
        ("aimbeam", "3", "AIM BEAM",
         "Tia sang tu tam ao"),
        ("aimripple", "4", "AIM RIPPLE",
         "Gon song lan toa"),
        ("aimorbit", "5", "AIM ORBIT",
         "Hat bay quanh tam"),
        ("aimgrid", "6", "AIM GRID",
         "Luoi o vuong"),
        ("aimscope", "7", "AIM SCOPE",
         "Khung scope"),
        ("aimbrackets", "8", "AIM BRACKETS",
         "4 goc ngoac"),
        ("aimticker", "9", "AIM TICKER",
         "Vach chia quanh tam"),
        ("aimdotorbit", "A", "AIM DOT ORBIT",
         "Cham bay quanh tam")
    ]

    private let sounds: [
        (String, String, String, String)
    ] = [
        ("aimsound", "B", "AIM SOUND",
         "Tieng beep khi keo"),
        ("aimvoice", "C", "AIM VOICE",
         "Giong doc LOCK"),
        ("aimhaptic", "D", "AIM HAPTIC",
         "Rung khi co target")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "AIM ASSIST VISUAL")
            ForEach(visuals, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }
            SectionTitle(text: "KEO TAM AM THANH")
            ForEach(sounds, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }
            SectionTitle(text: "CHE DO AIM")
            FeatureCard(
                icon: "E",
                title: "AUTO MODE SWITCH",
                subtitle: "Tu doi crosshair moi 5s",
                isOn: state.isOn("modeswitch")
            ) {
                state.toggle("modeswitch")
            }
        }
    }

    private func card(
        _ k: String,
        _ i: String,
        _ t: String,
        _ s: String
    ) -> some View {
        FeatureCard(
            icon: i,
            title: t,
            subtitle: s,
            isOn: state.isOn(k)
        ) {
            state.toggle(k)
        }
    }
}

// MARK: - CLEAN TAB
struct CleanTab: View {
    @ObservedObject var state: StateManager

    private let features: [
        (String, String, String, String)
    ] = [
        ("clearcache", "1", "DON CACHE",
         "Xoa bo nho cache"),
        ("clearls", "2", "DON LOCALSTORAGE",
         "Xoa du lieu cuc bo"),
        ("clearidb", "3", "DON INDEXEDDB",
         "Xoa database"),
        ("clearimagecache", "4", "DON ANH",
         "Xoa anh cache"),
        ("clearcookies", "5", "DON COOKIES",
         "Xoa cookies")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "NHAN DIEN THIET BI")
            InfoCard {
                InfoRow(
                    key: "MODEL",
                    value: DeviceInfo.modelName
                )
                InfoRow(
                    key: "HE DIEU HANH",
                    value: "iOS \(UIDevice.current.systemVersion)"
                )
                InfoRow(
                    key: "KIEN TRUC",
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
                    key: "MAN HINH",
                    value: DeviceInfo.screenSize
                )
                InfoRow(
                    key: "UPTIME",
                    value: DeviceInfo.uptime
                )
            }

            SectionTitle(text: "DON DEP HE THONG")
            ForEach(features, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }

            SectionTitle(text: "TANG TOC")
            FeatureCard(
                icon: "6",
                title: "BOOST MODE",
                subtitle: "Toi uu hieu nang",
                isOn: state.isOn("boostmode")
            ) {
                state.toggle("boostmode")
            }
            FeatureCard(
                icon: "7",
                title: "MEMORY RELEASE",
                subtitle: "Giai phong bo nho",
                isOn: state.isOn("memrelease")
            ) {
                state.toggle("memrelease")
            }
        }
    }

    private func card(
        _ k: String,
        _ i: String,
        _ t: String,
        _ s: String
    ) -> some View {
        FeatureCard(
            icon: i,
            title: t,
            subtitle: s,
            isOn: state.isOn(k)
        ) {
            state.toggle(k)
        }
    }
}

// MARK: - PERF TAB
struct PerfTab: View {
    @ObservedObject var state: StateManager

    private let features: [
        (String, String, String, String)
    ] = [
        ("fps", "1", "BUFF FPS",
         "Giam animation nang"),
        ("delay", "2", "ANTI DELAY",
         "Khu tre cam ung"),
        ("thermal", "3", "THERMAL GUARD",
         "Giam hieu ung may nong"),
        ("battery", "4", "BATTERY SAVE",
         "Tiet kiem pin"),
        ("wake", "5", "WAKE LOCK",
         "Man hinh luon sang"),
        ("fullscreen", "6", "FULLSCREEN",
         "Toan man hinh"),
        ("noparticles", "7", "TAT HAT SANG",
         "Giam particle"),
        ("nofx", "8", "TAT HIEU UNG",
         "Tat scanline+noise")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TOI UU HIEU NANG")
            ForEach(features, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }
            SectionTitle(text: "DO LUONG THOI GIAN THUC")
            InfoCard {
                InfoRow(
                    key: "FPS HIEN TAI",
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

    private func card(
        _ k: String,
        _ i: String,
        _ t: String,
        _ s: String
    ) -> some View {
        FeatureCard(
            icon: i,
            title: t,
            subtitle: s,
            isOn: state.isOn(k)
        ) {
            state.toggle(k)
        }
    }
}

// MARK: - VISUAL TAB
struct VisualTab: View {
    @ObservedObject var state: StateManager

    private let filters: [
        (String, String, String, String)
    ] = [
        ("filter-sea", "1", "FILTER SEA",
         "Xanh bien"),
        ("filter-red", "2", "FILTER RED",
         "Do noi bat"),
        ("filter-vivid", "3", "FILTER VIVID",
         "Tang tuong phan"),
        ("filter-mono", "4", "FILTER MONO",
         "Den trang"),
        ("filter-invert", "5", "FILTER INVERT",
         "Dao mau"),
        ("filter-night", "6", "FILTER NIGHT",
         "Che do ban dem"),
        ("filter-bright", "7", "FILTER BRIGHT",
         "Tang sang"),
        ("filter-highcontrast", "8",
         "HIGH CONTRAST",
         "Tuong phan cao"),
        ("filter-thermal", "9",
         "FILTER THERMAL",
         "Nhiet anh do"),
        ("filter-sniper", "A", "FILTER SNIPER",
         "Tang net muc tieu")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "BO LOC MAU")
            ForEach(filters, id: \.0) { i in
                card(i.0, i.1, i.2, i.3)
            }
            SectionTitle(text: "HIEU UNG")
            FeatureCard(
                icon: "B",
                title: "SCANLINE CRT",
                subtitle: "Hieu ung TV cu",
                isOn: state.isOn("scanline")
            ) {
                state.toggle("scanline")
            }
            FeatureCard(
                icon: "C",
                title: "NOISE FX",
                subtitle: "Nhieu hat phim",
                isOn: state.isOn("noisefx")
            ) {
                state.toggle("noisefx")
            }
            SectionTitle(text: "TUY CHINH SANG")
            CustomSlider(
                label: "DO SANG",
                value: $state.filterBright,
                range: 0.5...1.5,
                step: 0.05,
                suffix: "x"
            )
            CustomSlider(
                label: "TUONG PHAN",
                value: $state.filterContrast,
                range: 0.5...2.0,
                step: 0.05,
                suffix: "x"
            )
            CustomSlider(
                label: "BAO HOA",
                value: $state.filterSaturate,
                range: 0.0...2.0,
                step: 0.05,
                suffix: "x"
            )
        }
    }

    private func card(
        _ k: String,
        _ i: String,
        _ t: String,
        _ s: String
    ) -> some View {
        FeatureCard(
            icon: i,
            title: t,
            subtitle: s,
            isOn: state.isOn(k)
        ) {
            state.toggle(k)
        }
    }
}

// MARK: - GAME TAB
struct GameTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "CHON GAME")
            GameCard(
                icon: "1",
                name: "FREE FIRE",
                id: "com.dts.freefireth",
                selected: state.game == "ff"
            ) {
                state.game = state.game == "ff"
                    ? nil
                    : "ff"
                UIImpactFeedbackGenerator(
                    style: .light
                ).impactOccurred()
            }
            GameCard(
                icon: "2",
                name: "FREE FIRE MAX",
                id: "com.dts.freefiremax",
                selected: state.game == "ffmax"
            ) {
                state.game = state.game == "ffmax"
                    ? nil
                    : "ffmax"
                UIImpactFeedbackGenerator(
                    style: .light
                ).impactOccurred()
            }
            GameCard(
                icon: "3",
                name: "CA HAI GAME",
                id: "FREE FIRE + MAX",
                selected: state.game == "both"
            ) {
                state.game = state.game == "both"
                    ? nil
                    : "both"
                UIImpactFeedbackGenerator(
                    style: .light
                ).impactOccurred()
            }

            SectionTitle(text: "THONG TIN")
            InfoCard {
                InfoRow(
                    key: "GAME DA CHON",
                    value: gameName()
                )
                InfoRow(
                    key: "CHUC NANG BAT",
                    value: "\(state.activeCount())"
                )
                InfoRow(
                    key: "PHIEN BAN",
                    value: "9.0.0"
                )
            }

            SectionTitle(text: "CHUC NANG DA BAT")
            activeList
        }
    }

    private var activeList: some View {
        InfoCard {
            let active = state.features
                .filter { $0.value }
                .keys
                .sorted()

            if active.isEmpty {
                InfoRow(
                    key: "CHUA CO",
                    value: "--"
                )
            } else {
                ForEach(active, id: \.self) { k in
                    InfoRow(
                        key: k.uppercased(),
                        value: "ON"
                    )
                }
            }
        }
    }

    private func gameName() -> String {
        switch state.game {
        case "ff": return "FREE FIRE"
        case "ffmax": return "FREE FIRE MAX"
        case "both": return "CA HAI"
        default: return "CHUA CHON"
        }
    }
}

struct GameCard: View {
    let icon: String
    let name: String
    let id: String
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                iconBox
                textBox
                Spacer()
                statusTag
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(bg)
            .cornerRadius(16)
            .overlay(stroke)
        }
        .buttonStyle(.plain)
    }

    private var iconBox: some View {
        ZStack {
            if selected {
                RoundedRectangle(cornerRadius: 11)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "0099ff"),
                                Color(hex: "00d4ff")
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
            Text(icon)
                .font(
                    .system(
                        size: 16,
                        weight: .black
                    )
                )
                .foregroundColor(.white)
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
    }

    private var statusTag: some View {
        Text(selected ? "ON" : "OFF")
            .font(
                .system(
                    size: 11,
                    weight: .black
                )
            )
            .foregroundColor(
                selected
                    ? Color(hex: "00d4ff")
                    : Color(hex: "9ca3af")
            )
            .frame(width: 42, height: 26)
            .background(
                selected
                    ? Color(hex: "0099ff")
                        .opacity(0.2)
                    : Color.white.opacity(0.05)
            )
            .cornerRadius(8)
    }

    private var bg: some View {
        ZStack {
            if selected {
                LinearGradient(
                    colors: [
                        Color(hex: "0099ff")
                            .opacity(0.2),
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
                    ? Color(hex: "00d4ff")
                        .opacity(0.6)
                    : Color.white.opacity(0.08),
                lineWidth: 1
            )
    }
}

// MARK: - SYSTEM TAB
struct SystemTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TAI KHOAN")
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
                    key: "HET HAN",
                    value: "Vo han"
                )
            }

            SectionTitle(text: "NHAN DIEN THIET BI")
            deviceCard

            SectionTitle(text: "TRANG THAI THUC")
            liveCard

            SectionTitle(text: "GIOI THIEU")
            aboutCard
        }
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
                key: "MA THIET BI",
                value: String(
                    state.deviceId.suffix(12)
                )
            )
            InfoRow(
                key: "MODEL",
                value: DeviceInfo.modelName
            )
            InfoRow(
                key: "HE DIEU HANH",
                value: "iOS \(UIDevice.current.systemVersion)"
            )
            InfoRow(
                key: "KIEN TRUC",
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
                key: "MAN HINH",
                value: DeviceInfo.screenSize
            )
            InfoRow(
                key: "SCALE",
                value: String(
                    format: "%.1fx",
                    UIScreen.main.scale
                )
            )
            InfoRow(
                key: "TEN",
                value: UIDevice.current.name
            )
            InfoRow(
                key: "NGON NGU",
                value: Locale.current.identifier
            )
            InfoRow(
                key: "UPTIME",
                value: DeviceInfo.uptime
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
                key: "SAC",
                value: state.charging
                    ? "DANG SAC"
                    : "KHONG SAC"
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
                key: "PHIEN BAN",
                value: "9.0.0 TITAN"
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

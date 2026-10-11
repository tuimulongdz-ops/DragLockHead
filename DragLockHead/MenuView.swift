import SwiftUI

// MARK: - Root
struct MenuView: View {
    @StateObject private var state = StateManager()
    @State private var isVerified: Bool = false

    var body: some View {
        ZStack {
            Theme.dark1.ignoresSafeArea()

            if isVerified {
                MainMenuContent(state: state)
                    .transition(.opacity)
            } else {
                KeyGateView(isVerified: $isVerified, deviceId: state.deviceId)
                    .transition(.opacity)
            }
        }
        .onAppear {
            let saved = UserDefaults.standard.string(forKey: "dl_utral_auth")
            if saved != nil, !(saved?.isEmpty ?? true) {
                // User already verified before → skip to menu directly
                isVerified = true
            }
        }
    }
}

// MARK: - Main Content
struct MainMenuContent: View {
    @ObservedObject var state: StateManager

    var body: some View {
        ZStack {
            AnimatedMenuBackground()

            VStack(spacing: 10) {
                HeaderBar()
                HudRow(state: state)
                TabBar(state: state)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        contentForTab
                    }
                    .padding(.vertical, 8)
                }

                FooterBar(state: state)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 4)

            if state.showToast {
                VStack {
                    ToastView(text: state.toast)
                    Spacer()
                }
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(999)
            }

            if state.isInjecting {
                InjectOverlay()
                    .transition(.opacity)
                    .zIndex(1000)
            }
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
}

// MARK: - Animated Background
struct AnimatedMenuBackground: View {
    @State private var phase: Double = 0

    var body: some View {
        ZStack {
            Theme.dark1

            RadialGradient(gradient: Gradient(colors: [Theme.sea1.opacity(0.32), .clear]),
                           center: .topLeading, startRadius: 0, endRadius: 400)
                .offset(x: sin(phase) * 35, y: cos(phase) * 35)

            RadialGradient(gradient: Gradient(colors: [Theme.red1.opacity(0.24), .clear]),
                           center: .bottomTrailing, startRadius: 0, endRadius: 400)
                .offset(x: cos(phase) * 35, y: sin(phase) * 35)

            RadialGradient(gradient: Gradient(colors: [Theme.purple.opacity(0.18), .clear]),
                           center: .bottomLeading, startRadius: 0, endRadius: 300)
                .offset(x: sin(phase * 0.8) * 25, y: cos(phase * 0.8) * 25)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Header
struct HeaderBar: View {
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Theme.sea1, Theme.sea2],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)
                    .shadow(color: Theme.sea1.opacity(0.6), radius: 10)
                Text("ZH")
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("ZWILZ HLONG AIM VIP")
                    .font(.system(size: 13.5, weight: .black))
                    .foregroundColor(Theme.sea2)
                    .lineLimit(1)
                Text("DRAGLOCK UTRAL - v9.0")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundColor(Theme.smoke2)
            }

            Spacer()

            StatusDot()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: [Theme.sea1.opacity(0.16),
                             Theme.dark2.opacity(0.88),
                             Theme.red1.opacity(0.12)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(LinearGradient(
                    colors: [Theme.sea1.opacity(0.6),
                             Theme.sea2.opacity(0.25),
                             Theme.red1.opacity(0.5)],
                    startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1)
        )
        .shadow(color: Theme.sea1.opacity(0.25), radius: 12)
    }
}

struct StatusDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.green)
                .frame(width: 10, height: 10)
                .scaleEffect(pulse ? 1.5 : 1.0)
                .opacity(pulse ? 0.3 : 1.0)
            Circle()
                .fill(Theme.green)
                .frame(width: 6, height: 6)
                .shadow(color: Theme.green, radius: 6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
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
            HudItem(label: "FPS", value: "\(state.fps)", color: Theme.green)
            HudItem(label: "PIN", value: "\(state.batteryPct)%", color: state.charging ? Theme.yellow : Theme.sea2)
            HudItem(label: "PING", value: "\(state.ping)", color: Theme.sea2)
            HudItem(label: "RAM", value: "\(state.ram)%", color: Theme.purple)
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
                .tracking(1.5)
                .foregroundColor(Theme.smoke2)
            Text(value)
                .font(.system(size: 12, weight: .black, design: .monospaced))
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

// MARK: - Tab Bar
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(tabs, id: \.0) { (key, label) in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            state.selectedTab = key
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Text(label)
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(0.6)
                            .foregroundColor(state.selectedTab == key ? .white : Theme.smoke2)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 10)
                            .background(
                                Group {
                                    if state.selectedTab == key {
                                        LinearGradient(
                                            colors: [Theme.sea1, Theme.sea2, Theme.red1],
                                            startPoint: .leading, endPoint: .trailing)
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .cornerRadius(11)
                            .shadow(color: state.selectedTab == key ? Theme.sea2.opacity(0.5) : .clear, radius: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
        }
        .background(Color.white.opacity(0.045))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - Section Title
struct SectionTitle: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(LinearGradient(colors: [Theme.sea1, Theme.sea2, Theme.red1],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 3, height: 14)
                .shadow(color: Theme.sea1, radius: 4)
            Text(text)
                .font(.system(size: 10, weight: .black))
                .tracking(2)
                .foregroundColor(Theme.sea2)
            Spacer()
            RoundedRectangle(cornerRadius: 1)
                .fill(LinearGradient(colors: [Color.white.opacity(0.1), Color.clear],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isOn: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(
                            Group {
                                if isOn {
                                    LinearGradient(
                                        colors: [Theme.sea1, Theme.sea2],
                                        startPoint: .topLeading, endPoint: .bottomTrailing)
                                } else {
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                        startPoint: .top, endPoint: .bottom)
                                }
                            }
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: isOn ? Theme.sea2.opacity(0.5) : .clear, radius: 8)
                    Text(icon)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                }
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.white.opacity(0.1), lineWidth: 1))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 9.5))
                        .foregroundColor(Theme.smoke2)
                        .lineLimit(1)
                }

                Spacer()

                ZStack {
                    Capsule()
                        .fill(
                            Group {
                                if isOn {
                                    LinearGradient(
                                        colors: [Theme.sea1, Theme.sea2],
                                        startPoint: .leading, endPoint: .trailing)
                                } else {
                                    Color.white.opacity(0.1)
                                }
                            }
                        )
                        .frame(width: 48, height: 28)
                        .shadow(color: isOn ? Theme.sea2.opacity(0.6) : .clear, radius: 8)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 22, height: 22)
                        .shadow(color: .black.opacity(0.4), radius: 2)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isOn {
                        LinearGradient(
                            colors: [Theme.sea1.opacity(0.2),
                                     Theme.dark2.opacity(0.85),
                                     Theme.red1.opacity(0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.white.opacity(0.03)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isOn
                            ? LinearGradient(colors: [Theme.sea2.opacity(0.7), Theme.red1.opacity(0.4)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)],
                                             startPoint: .top, endPoint: .bottom),
                            lineWidth: 1)
            )
            .shadow(color: isOn ? Theme.sea2.opacity(0.2) : .clear, radius: 10)
        }
        .buttonStyle(GradientButtonStyle())
    }
}

// MARK: - Custom Slider
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
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(formatValue())\(suffix)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.sea2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.sea1.opacity(0.15))
                    .cornerRadius(6)
            }
            Slider(value: $value, in: range, step: step)
                .accentColor(Theme.sea2)
        }
        .padding(14)
        .background(Color.white.opacity(0.045))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    private func formatValue() -> String {
        if step >= 1 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}

// MARK: - Info Card
struct InfoCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Theme.sea1.opacity(0.1),
                             Theme.dark2.opacity(0.88),
                             Theme.red1.opacity(0.08)],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(
                        colors: [Theme.sea1.opacity(0.35),
                                 Theme.sea2.opacity(0.15),
                                 Theme.red1.opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1)
            )
    }
}

struct InfoRow: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
                .foregroundColor(Theme.smoke2)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.sea2)
                .lineLimit(1)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Footer Bar
struct FooterBar: View {
    @ObservedObject var state: StateManager

    var body: some View {
        HStack(spacing: 8) {
            // RESET button
            Button(action: {
                state.resetAll()
                state.showToastMessage("DA DAT LAI")
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .bold))
                    Text("DAT LAI")
                        .font(.system(size: 9, weight: .black))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.06))
                .foregroundColor(.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(GradientButtonStyle())

            // ASSISTIVE TOUCH button
            Button(action: {
                openAssistiveTouch()
                state.showToastMessage("MO TRO NANG - CHAM")
            }) {
                VStack(spacing: 2) {
                    Image(systemName: "circle.dashed")
                        .font(.system(size: 14, weight: .bold))
                    Text("TAM AO")
                        .font(.system(size: 9, weight: .black))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.06))
                .foregroundColor(.white)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.sea2.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(GradientButtonStyle())

            // INJECT button
            Button(action: handleInject) {
                HStack(spacing: 6) {
                    if state.isInjecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text(state.isInjecting ? "DANG INJECT..." : "INJECT")
                        .font(.system(size: 12, weight: .black))
                        .tracking(1.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: state.isInjecting
                            ? [Theme.smoke, Theme.smoke2]
                            : [Theme.sea1, Theme.sea2, Theme.red1],
                        startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(color: Theme.sea1.opacity(0.5), radius: 12)
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(state.isInjecting)
        }
    }

    private func handleInject() {
        if state.game == nil {
            state.showToastMessage("CHON GAME TRUOC")
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        if state.activeCount() == 0 {
            state.showToastMessage("BAT IT NHAT 1 CHUC NANG")
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        withAnimation {
            state.isInjecting = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                state.isInjecting = false
            }
            openFreeFire(game: state.game) { success in
                if success {
                    state.showToastMessage("DANG MO GAME...")
                } else {
                    state.showToastMessage("KHONG TIM THAY GAME")
                }
            }
        }
    }

    private func openAssistiveTouch() {
        let schemes = [
            "App-Prefs:root=ACCESSIBILITY&path=TOUCH_REACHABILITY_TITLE/AIR_TOUCH_TITLE",
            "App-Prefs:root=ACCESSIBILITY"
        ]
        for s in schemes {
            if let url = URL(string: s), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }
    }

    private func openFreeFire(game: String?, completion: @escaping (Bool) -> Void) {
        var schemes: [String] = []
        if game == "ffmax" {
            schemes = [
                "freefiremax://",
                "com.dts.freefiremax://",
                "ffmax://"
            ]
        } else if game == "both" {
            schemes = [
                "freefire://",
                "com.dts.freefireth://",
                "freefiremax://",
                "com.dts.freefiremax://",
                "ff://"
            ]
        } else {
            schemes = [
                "freefire://",
                "com.dts.freefireth://",
                "ff://"
            ]
        }
        tryNextScheme(schemes: schemes, index: 0, completion: completion)
    }

    private func tryNextScheme(schemes: [String], index: Int, completion: @escaping (Bool) -> Void) {
        guard index < schemes.count else {
            completion(false)
            return
        }
        guard let url = URL(string: schemes[index]) else {
            tryNextScheme(schemes: schemes, index: index + 1, completion: completion)
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    completion(true)
                } else {
                    self.tryNextScheme(schemes: schemes, index: index + 1, completion: completion)
                }
            }
        }
    }
}

// MARK: - Toast
struct ToastView: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Theme.sea2)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 12, weight: .heavy))
                .tracking(1)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(Color.black.opacity(0.92))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(LinearGradient(
                    colors: [Theme.sea1, Theme.sea2, Theme.red1],
                    startPoint: .leading, endPoint: .trailing),
                    lineWidth: 1)
        )
        .shadow(color: Theme.sea2.opacity(0.5), radius: 14)
    }
}

// MARK: - Inject Overlay
struct InjectOverlay: View {
    @State private var progress: Double = 0
    @State private var message: String = "DANG KHOI TAO..."

    private let messages = [
        "KIEM TRA CAU HINH...",
        "XAC THUC THIET BI...",
        "AP DUNG CHUC NANG...",
        "KICH HOAT TAM AO PRO...",
        "TOI UU HIEU NANG...",
        "HOAN TAT!"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .stroke(Theme.sea1.opacity(0.2), lineWidth: 6)
                        .frame(width: 120, height: 120)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(LinearGradient(
                            colors: [Theme.sea1, Theme.sea2, Theme.red1],
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(Theme.sea2)
                }
                .shadow(color: Theme.sea1.opacity(0.6), radius: 20)

                Text(message)
                    .font(.system(size: 13, weight: .black))
                    .tracking(2)
                    .foregroundColor(.white)

                Text("ZWILZ HLONG UTRAL ENGINE")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(3)
                    .foregroundColor(Theme.smoke2)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        for (i, msg) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.28) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    message = msg
                    progress = Double(i + 1) / Double(messages.count)
                }
            }
        }
    }
}

// MARK: - AIM TAB
struct AimTab: View {
    @ObservedObject var state: StateManager

    private let crosshairFeatures: [(String, String, String, String)] = [
        ("virtualcross", "1", "TAM AO PRO", "Crosshair de tren man hinh"),
        ("aimoverlay", "2", "AIM CROSSHAIR", "Tam ngam do don gian"),
        ("aimbg", "3", "AIM BACKGROUND", "Vong tam ngam nen VIP"),
        ("dotcenter", "4", "DOT CENTER", "Cham do chinh giua"),
        ("crossline", "5", "CROSS LINE", "Duong chu thap 400px")
    ]

    private let aimFeatures: [(String, String, String, String)] = [
        ("microaim", "6", "NHE TAM", "Crosshair micro nho"),
        ("headlock", "7", "BAM DAU", "Duong guide vi tri dau"),
        ("aimlock", "8", "AIMLOCK VISUAL", "Vong lock nhap nhay"),
        ("ghostcross", "9", "GHOST CROSSHAIR", "Tam ao theo ngon tay"),
        ("aimtrace", "A", "AIM TRACE", "Vet mo theo ngon tay"),
        ("magnetic", "B", "MAGNETIC VISUAL", "Vong hut pulse"),
        ("sensdisplay", "C", "SENS DISPLAY", "Hien sensitivity")
    ]

    private let touchFeatures: [(String, String, String, String)] = [
        ("touchsmooth", "D", "TOUCH SMOOTH", "Lam muot cam ung"),
        ("prevscroll", "E", "PREVENT SCROLL", "Chan cuon trang"),
        ("prevzoom", "F", "PREVENT ZOOM", "Chan pinch zoom"),
        ("prevselect", "G", "PREVENT SELECT", "Chan boi den"),
        ("prevcontext", "H", "PREVENT LONG-PRESS", "Chan menu giu lau")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TAM AO & CROSSHAIR")
            ForEach(crosshairFeatures, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "AIM NANG CAO")
            ForEach(aimFeatures, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "CHONG DELAY CAM UNG")
            ForEach(touchFeatures, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "TUY CHINH")
            CustomSlider(label: "KICH THUOC TAM AO", value: $state.crosshairSize,
                         range: 60...240, step: 10, suffix: "")
            CustomSlider(label: "DO MO TAM AO", value: $state.crosshairOpacity,
                         range: 0.3...1.0, step: 0.05, suffix: "")
            CustomSlider(label: "SENS GIA LAP", value: $state.sensValue,
                         range: 50...200, step: 5, suffix: "")
        }
    }
}

// MARK: - ADVANCED TAB
struct AdvancedTab: View {
    @ObservedObject var state: StateManager

    private let visualFeatures: [(String, String, String, String)] = [
        ("aimpulse", "1", "AIM PULSE", "Tam ao dap nhip tim"),
        ("aimradar", "2", "AIM RADAR", "Song radar quanh tam"),
        ("aimbeam", "3", "AIM BEAM", "Tia sang tu tam ao"),
        ("aimripple", "4", "AIM RIPPLE", "Gon song lan toa"),
        ("aimorbit", "5", "AIM ORBIT", "Hat bay quanh tam"),
        ("aimgrid", "6", "AIM GRID", "Luoi o vuong"),
        ("aimscope", "7", "AIM SCOPE", "Khung scope"),
        ("aimbrackets", "8", "AIM BRACKETS", "4 goc ngoac"),
        ("aimticker", "9", "AIM TICKER", "Vach chia quanh tam"),
        ("aimdotorbit", "A", "AIM DOT ORBIT", "Cham bay quanh tam")
    ]

    private let soundFeatures: [(String, String, String, String)] = [
        ("aimsound", "B", "AIM SOUND FX", "Tieng beep khi keo"),
        ("aimvoice", "C", "AIM VOICE", "Giong doc LOCK"),
        ("aimhaptic", "D", "AIM HAPTIC", "Rung khi co target")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "AIM ASSIST VISUAL")
            ForEach(visualFeatures, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "KEO TAM AM THANH")
            ForEach(soundFeatures, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "CHE DO AIM")
            FeatureCard(icon: "E", title: "AUTO MODE SWITCH",
                        subtitle: "Tu doi crosshair moi 5s",
                        isOn: state.isOn("modeswitch")) {
                state.toggle("modeswitch")
            }
        }
    }
}

// MARK: - CLEAN TAB
struct CleanTab: View {
    @ObservedObject var state: StateManager

    private let cleanFeatures: [(String, String, String, String)] = [
        ("clearcache", "1", "DON CACHE", "Xoa bo nho cache"),
        ("clearls", "2", "DON LOCALSTORAGE", "Xoa du lieu cuc bo"),
        ("clearidb", "3", "DON INDEXEDDB", "Xoa database"),
        ("clearimagecache", "4", "DON ANH CACHE", "Xoa anh cache"),
        ("clearcookies", "5", "DON COOKIES", "Xoa cookies")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "NHAN DIEN THIET BI")
            InfoCard {
                InfoRow(key: "MODEL", value: DeviceInfo.modelName)
                InfoRow(key: "HE DIEU HANH", value: "iOS \(UIDevice.current.systemVersion)")
                InfoRow(key: "KIEN TRUC", value: DeviceInfo.architecture)
                InfoRow(key: "CORES", value: "\(ProcessInfo.processInfo.processorCount)")
                InfoRow(key: "RAM", value: DeviceInfo.totalRAM)
                InfoRow(key: "STORAGE", value: DeviceInfo.freeStorage)
                InfoRow(key: "MAN HINH", value: DeviceInfo.screenSize)
                InfoRow(key: "UPTIME", value: DeviceInfo.uptime)
            }

            SectionTitle(text: "DON DEP HE THONG")
            ForEach(cleanFeatures, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "TANG TOC THIET BI")
            FeatureCard(icon: "6", title: "BOOST MODE",
                        subtitle: "Tat hieu ung nang, toi uu",
                        isOn: state.isOn("boostmode")) {
                state.toggle("boostmode")
            }
            FeatureCard(icon: "7", title: "MEMORY RELEASE",
                        subtitle: "Giai phong bo nho dinh ky",
                        isOn: state.isOn("memrelease")) {
                state.toggle("memrelease")
            }
        }
    }
}

// MARK: - PERF TAB
struct PerfTab: View {
    @ObservedObject var state: StateManager

    private let perfFeatures: [(String, String, String, String)] = [
        ("fps", "1", "BUFF FPS", "Giam animation nang"),
        ("delay", "2", "ANTI DELAY TOUCH", "Khu tre cam ung"),
        ("thermal", "3", "THERMAL GUARD", "Giam hieu ung may nong"),
        ("battery", "4", "BATTERY SAVE", "Tiet kiem pin"),
        ("wake", "5", "WAKE LOCK", "Man hinh luon sang"),
        ("fullscreen", "6", "FULLSCREEN", "Toan man hinh"),
        ("noparticles", "7", "TAT HAT SANG", "Giam particle"),
        ("nofx", "8", "TAT HIEU UNG", "Tat scanline+noise")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TOI UU HIEU NANG")
            ForEach(perfFeatures, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "DO LUONG THOI GIAN THUC")
            InfoCard {
                InfoRow(key: "FPS HIEN TAI", value: "\(state.fps)")
                InfoRow(key: "PING", value: "\(state.ping)ms")
                InfoRow(key: "RAM USAGE", value: "\(state.ram)%")
                InfoRow(key: "PIN", value: "\(state.batteryPct)%\(state.charging ? " (sac)" : "")")
            }
        }
    }
}

// MARK: - VISUAL TAB
struct VisualTab: View {
    @ObservedObject var state: StateManager

    private let filters: [(String, String, String, String)] = [
        ("filter-sea", "1", "FILTER SEA", "Xanh bien"),
        ("filter-red", "2", "FILTER RED", "Do noi bat"),
        ("filter-vivid", "3", "FILTER VIVID", "Tang tuong phan"),
        ("filter-mono", "4", "FILTER MONO", "Den trang"),
        ("filter-invert", "5", "FILTER INVERT", "Dao mau"),
        ("filter-night", "6", "FILTER NIGHT", "Che do ban dem"),
        ("filter-bright", "7", "FILTER BRIGHT", "Tang sang"),
        ("filter-highcontrast", "8", "HIGH CONTRAST", "Tuong phan cao"),
        ("filter-thermal", "9", "FILTER THERMAL", "Nhiet anh do"),
        ("filter-sniper", "A", "FILTER SNIPER", "Tang net muc tieu xa")
    ]

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "BO LOC MAU")
            ForEach(filters, id: \.0) { (k, i, t, s) in
                FeatureCard(icon: i, title: t, subtitle: s, isOn: state.isOn(k)) {
                    state.toggle(k)
                }
            }

            SectionTitle(text: "HIEU UNG")
            FeatureCard(icon: "B", title: "SCANLINE CRT",
                        subtitle: "Hieu ung TV cu",
                        isOn: state.isOn("scanline")) {
                state.toggle("scanline")
            }
            FeatureCard(icon: "C", title: "NOISE FX",
                        subtitle: "Nhieu hat phim",
                        isOn: state.isOn("noisefx")) {
                state.toggle("noisefx")
            }

            SectionTitle(text: "TUY CHINH SANG / TUONG PHAN")
            CustomSlider(label: "DO SANG", value: $state.filterBright,
                         range: 0.5...1.5, step: 0.05, suffix: "x")
            CustomSlider(label: "TUONG PHAN", value: $state.filterContrast,
                         range: 0.5...2.0, step: 0.05, suffix: "x")
            CustomSlider(label: "BAO HOA", value: $state.filterSaturate,
                         range: 0.0...2.0, step: 0.05, suffix: "x")
        }
    }
}

// MARK: - GAME TAB
struct GameTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "CHON GAME")
            GameCard(icon: "1", name: "FREE FIRE", id: "com.dts.freefireth",
                     selected: state.game == "ff") {
                state.game = state.game == "ff" ? nil : "ff"
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            GameCard(icon: "2", name: "FREE FIRE MAX", id: "com.dts.freefiremax",
                     selected: state.game == "ffmax") {
                state.game = state.game == "ffmax" ? nil : "ffmax"
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            GameCard(icon: "3", name: "CA HAI GAME", id: "FREE FIRE + MAX",
                     selected: state.game == "both") {
                state.game = state.game == "both" ? nil : "both"
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }

            SectionTitle(text: "THONG TIN")
            InfoCard {
                InfoRow(key: "GAME DA CHON", value: gameName())
                InfoRow(key: "CHUC NANG BAT", value: "\(state.activeCount())")
                InfoRow(key: "PHIEN BAN", value: "9.0.0")
            }

            SectionTitle(text: "CHUC NANG DA BAT")
            InfoCard {
                let active = state.features.filter { $0.value }.keys.sorted()
                if active.isEmpty {
                    InfoRow(key: "CHUA CO", value: "--")
                } else {
                    ForEach(active, id: \.self) { key in
                        InfoRow(key: key.uppercased(), value: "ON")
                    }
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
                Text(icon)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Group {
                            if selected {
                                LinearGradient(colors: [Theme.sea1, Theme.sea2],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            } else {
                                LinearGradient(colors: [Color.white.opacity(0.08),
                                                        Color.white.opacity(0.03)],
                                               startPoint: .top, endPoint: .bottom)
                            }
                        }
                    )
                    .cornerRadius(11)
                    .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.white.opacity(0.1), lineWidth: 1))

                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundColor(.white)
                    Text(id)
                        .font(.system(size: 9.5))
                        .foregroundColor(Theme.smoke2)
                }

                Spacer()

                Text(selected ? "ON" : "OFF")
                    .font(.system(size: 11, weight: .black))
                    .tracking(1)
                    .foregroundColor(selected ? Theme.sea2 : Theme.smoke2)
                    .frame(width: 42, height: 26)
                    .background(selected ? Theme.sea1.opacity(0.2) : Color.white.opacity(0.05))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Group {
                    if selected {
                        LinearGradient(colors: [Theme.sea1.opacity(0.2),
                                                Theme.dark2.opacity(0.85),
                                                Theme.red1.opacity(0.15)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.white.opacity(0.03)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? Theme.sea2.opacity(0.6) : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(GradientButtonStyle())
    }
}

// MARK: - SYSTEM TAB
struct SystemTab: View {
    @ObservedObject var state: StateManager

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "TAI KHOAN")
            InfoCard {
                InfoRow(key: "KEY", value: UserDefaults.standard.string(forKey: "dl_utral_auth") ?? "--")
                InfoRow(key: "TIER", value: UserDefaults.standard.string(forKey: "dl_utral_tier") ?? "VIP")
                InfoRow(key: "HET HAN", value: "Vo han")
            }

            SectionTitle(text: "NHAN DIEN THIET BI")
            InfoCard {
                InfoRow(key: "MA THIET BI", value: String(state.deviceId.suffix(12)))
                InfoRow(key: "MODEL", value: DeviceInfo.modelName)
                InfoRow(key: "HE DIEU HANH", value: "iOS \(UIDevice.current.systemVersion)")
                InfoRow(key: "KIEN TRUC", value: DeviceInfo.architecture)
                InfoRow(key: "CORES", value: "\(ProcessInfo.processInfo.processorCount)")
                InfoRow(key: "RAM", value: DeviceInfo.totalRAM)
                InfoRow(key: "STORAGE", value: DeviceInfo.freeStorage)
                InfoRow(key: "MAN HINH", value: DeviceInfo.screenSize)
                InfoRow(key: "SCALE", value: String(format: "%.1fx", UIScreen.main.scale))
                InfoRow(key: "TEN", value: UIDevice.current.name)
                InfoRow(key: "NGON NGU", value: Locale.current.identifier)
                InfoRow(key: "UPTIME", value: DeviceInfo.uptime)
            }

            SectionTitle(text: "TRANG THAI THOI GIAN THUC")
            InfoCard {
                InfoRow(key: "PIN", value: "\(state.batteryPct)%")
                InfoRow(key: "SAC", value: state.charging ? "DANG SAC" : "KHONG SAC")
                InfoRow(key: "FPS", value: "\(state.fps)")
                InfoRow(key: "PING", value: "\(state.ping)ms")
                InfoRow(key: "RAM", value: "\(state.ram)%")
            }

            SectionTitle(text: "GIOI THIEU")
            InfoCard {
                InfoRow(key: "PHIEN BAN", value: "9.0.0 TITAN")
                InfoRow(key: "BUILD", value: "20251011")
                InfoRow(key: "ADMIN", value: "ZWILZ HLONG")
                InfoRow(key: "ENGINE", value: "SWIFTUI NATIVE")
                InfoRow(key: "SECURITY", value: "FIRESTORE REST")
            }
        }
    }
}

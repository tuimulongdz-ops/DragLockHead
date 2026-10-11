import SwiftUI

struct KeyGateView: View {
    @Binding var isVerified: Bool
    @State private var keyInput: String = ""
    @State private var statusText: String = ""
    @State private var statusColor: Color = Theme.sea2
    @State private var isLoading: Bool = false
    @State private var pulse: Bool = false
    @State private var rotation: Double = 0
    @State private var particles: [ParticleData] = []

    private let deviceId: String

    init(isVerified: Binding<Bool>, deviceId: String) {
        self._isVerified = isVerified
        self.deviceId = deviceId
    }

    var body: some View {
        ZStack {
            Theme.dark1.ignoresSafeArea()
            AnimatedBackground()
            ParticleField(particles: particles)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Theme.sea1, Theme.sea2, Theme.red1],
                                    startPoint: .top,
                                    endPoint: .bottom),
                                lineWidth: 2)
                            .frame(width: 130, height: 130)
                            .rotationEffect(.degrees(rotation))

                        Circle()
                            .stroke(Theme.sea2.opacity(0.4), lineWidth: 1)
                            .frame(width: 110, height: 110)
                            .rotationEffect(.degrees(-rotation * 1.5))

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.sea1, Theme.sea2, Theme.red1],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                            )
                            .frame(width: 90, height: 90)
                            .shadow(color: Theme.sea1.opacity(0.8), radius: 24)

                        Text("ZH")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(pulse ? 1.05 : 1.0)

                    VStack(spacing: 8) {
                        Text("ZWILZ HLONG AIM VIP")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(Theme.sea2)
                            .shadow(color: Theme.sea2.opacity(0.5), radius: 8)
                        Text("PREMIUM EDITION - v9.0")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.smoke2)
                    }

                    Spacer().frame(height: 10)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Circle().fill(Theme.sea2).frame(width: 6, height: 6)
                            Text("KEY KICH HOAT")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(Theme.sea2)
                        }

                        TextField("HLONG-XXXX-XXXX-XXXX", text: $keyInput)
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .keyboardType(.asciiCapable)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.sea2.opacity(0.5), lineWidth: 1)
                            )
                            .shadow(color: Theme.sea2.opacity(0.15), radius: 12)

                        Button(action: verify) {
                            HStack(spacing: 10) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.85)
                                }
                                Text(isLoading ? "DANG KIEM TRA..." : "KICH HOAT")
                                    .font(.system(size: 15, weight: .black))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(
                                    colors: isLoading
                                        ? [Theme.smoke, Theme.smoke2]
                                        : [Theme.sea1, Theme.sea2, Theme.red1],
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Theme.sea1.opacity(0.5), radius: 16)
                        }
                        .disabled(isLoading)
                        .buttonStyle(GradientButtonStyle())

                        if !statusText.isEmpty {
                            HStack(spacing: 6) {
                                Circle().fill(statusColor).frame(width: 5, height: 5)
                                Text(statusText)
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundColor(statusColor)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 6)
                            .transition(.opacity)
                        }
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.sea1.opacity(0.15),
                                        Theme.dark2.opacity(0.92),
                                        Theme.red1.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Theme.sea1.opacity(0.5),
                                        Theme.sea2.opacity(0.3),
                                        Theme.red1.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing),
                                lineWidth: 1)
                    )
                    .shadow(color: Theme.sea1.opacity(0.3), radius: 20)
                    .padding(.horizontal, 20)

                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 9))
                        Text("POWERED BY ZWILZ HLONG 2026")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(Color.white.opacity(0.3))

                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            generateParticles()
        }
    }

    private func generateParticles() {
        var arr: [ParticleData] = []
        for _ in 0..<25 {
            arr.append(ParticleData(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                size: Double.random(in: 2...5),
                speed: Double.random(in: 0.3...1.5),
                delay: Double.random(in: 0...2)
            ))
        }
        particles = arr
    }

    private func verify() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
        let trimmed = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            withAnimation {
                statusText = "VUI LONG NHAP KEY!"
                statusColor = Theme.red1
            }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        isLoading = true
        withAnimation {
            statusText = "DANG KIEM TRA..."
            statusColor = Theme.smoke2
        }

        FirestoreService.shared.verify(key: trimmed, device: deviceId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let info):
                    withAnimation {
                        statusText = "KICH HOAT THANH CONG - \(info.tier)"
                        statusColor = Theme.green
                    }
                    UserDefaults.standard.set(trimmed.uppercased(), forKey: "dl_utral_auth")
                    UserDefaults.standard.set(info.tier, forKey: "dl_utral_tier")
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isVerified = true
                        }
                    }
                case .failure(let error):
                    withAnimation {
                        statusText = error.localizedDescription
                        statusColor = Theme.red1
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}

struct ParticleData: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let size: Double
    let speed: Double
    let delay: Double
}

struct ParticleField: View {
    let particles: [ParticleData]
    @State private var animate: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(Theme.sea2)
                        .frame(width: p.size, height: p.size)
                        .shadow(color: Theme.sea2, radius: 4)
                        .position(
                            x: p.x * geo.size.width,
                            y: animate
                                ? (p.y * geo.size.height + 100).truncatingRemainder(dividingBy: geo.size.height)
                                : p.y * geo.size.height
                        )
                        .opacity(animate ? 0.4 : 0.8)
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct AnimatedBackground: View {
    @State private var phase: Double = 0

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Theme.sea1.opacity(0.35), .clear]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 500)
                .offset(x: sin(phase) * 40, y: cos(phase) * 40)

            RadialGradient(
                gradient: Gradient(colors: [Theme.red1.opacity()
(0.28), .clear]),
                center: .bottomTra               iling,
                startRadius: 0 Hud,
                endRadius: Row500)
                .offset(x: cos(phase) * 40, y: sin(phase) * 40)

            RadialGradient(
                gradient: Gradient(colors: [Theme.purple.opacity(0.2), .clear]),
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 400)
                .offset(x: sin(phase * 0.7) * 30, y: cos(phase * 0.7) * 30)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

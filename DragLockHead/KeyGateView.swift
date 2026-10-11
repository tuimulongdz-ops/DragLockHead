import SwiftUI

struct KeyGateView: View {

    @Binding var isVerified: Bool
    @State private var keyInput: String = ""
    @State private var statusText: String = ""
    @State private var statusColor: Color =
        Color(hex: "00d4ff")
    @State private var isLoading: Bool = false
    @State private var pulse: Bool = false
    @State private var rotation: Double = 0

    private let deviceId: String

    init(
        isVerified: Binding<Bool>,
        deviceId: String
    ) {
        self._isVerified = isVerified
        self.deviceId = deviceId
    }

    var body: some View {
        ZStack {
            Color(hex: "06080d")
                .ignoresSafeArea()
            auras
            scrollContent
        }
        .onAppear(perform: appear)
    }

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                logoView
                titleView
                Spacer().frame(height: 10)
                keyCard
                footerText
                Spacer()
            }
        }
    }

    private var logoView: some View {
        ZStack {
            Circle()
                .stroke(logoGrad, lineWidth: 2)
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(rotation))

            Circle()
                .stroke(
                    Color(hex: "00d4ff")
                        .opacity(0.4),
                    lineWidth: 1
                )
                .frame(width: 110, height: 110)

            Circle()
                .fill(logoGrad)
                .frame(width: 90, height: 90)
                .shadow(
                    color: Color(hex: "0099ff")
                        .opacity(0.8),
                    radius: 24
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
        .scaleEffect(pulse ? 1.05 : 1.0)
    }

    private var logoGrad: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "0099ff"),
                Color(hex: "00d4ff"),
                Color(hex: "ff0033")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var titleView: some View {
        VStack(spacing: 8) {
            Text("ZWILZ HLONG AIM VIP")
                .font(
                    .system(size: 22, weight: .black)
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
                .shadow(
                    color: Color(hex: "00d4ff")
                        .opacity(0.5),
                    radius: 8
                )

            Text("PREMIUM EDITION - v9.0")
                .font(
                    .system(size: 10, weight: .bold)
                )
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
        }
    }

    private var keyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            labelRow
            textFieldView
            submitButton
            statusView
        }
        .padding(22)
        .background(cardBg)
        .overlay(cardStroke)
        .shadow(
            color: Color(hex: "0099ff")
                .opacity(0.3),
            radius: 20
        )
        .padding(.horizontal, 20)
    }

    private var labelRow: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: "00d4ff"))
                .frame(width: 6, height: 6)
            Text("KEY KICH HOAT")
                .font(
                    .system(
                        size: 11,
                        weight: .heavy
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
        }
    }

    private var textFieldView: some View {
        TextField(
            "HLONG-XXXX-XXXX-XXXX",
            text: $keyInput
        )
        .font(
            .system(
                size: 15,
                weight: .bold,
                design: .monospaced
            )
        )
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
                .stroke(
                    Color(hex: "00d4ff")
                        .opacity(0.5),
                    lineWidth: 1
                )
        )
    }

    private var submitButton: some View {
        Button(action: verify) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: .white
                            )
                        )
                        .scaleEffect(0.85)
                }

                Text(
                    isLoading
                        ? "DANG KIEM TRA..."
                        : "KICH HOAT"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .black
                    )
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(buttonGrad)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(
                color: Color(hex: "0099ff")
                    .opacity(0.5),
                radius: 16
            )
        }
        .disabled(isLoading)
    }

    private var buttonGrad: LinearGradient {
        LinearGradient(
            colors: isLoading
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

    @ViewBuilder
    private var statusView: some View {
        if !statusText.isEmpty {
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 5, height: 5)
                Text(statusText)
                    .font(
                        .system(
                            size: 12,
                            weight: .heavy
                        )
                    )
                    .foregroundColor(statusColor)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 6)
        }
    }

    private var cardBg: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "0099ff")
                            .opacity(0.15),
                        Color(hex: "0d1117")
                            .opacity(0.92),
                        Color(hex: "ff0033")
                            .opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var cardStroke: some View {
        RoundedRectangle(cornerRadius: 26)
            .stroke(
                LinearGradient(
                    colors: [
                        Color(hex: "0099ff")
                            .opacity(0.5),
                        Color(hex: "00d4ff")
                            .opacity(0.3),
                        Color(hex: "ff0033")
                            .opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    private var footerText: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 9))
            Text("POWERED BY ZWILZ HLONG 2026")
                .font(
                    .system(size: 9, weight: .bold)
                )
        }
        .foregroundColor(
            Color.white.opacity(0.3)
        )
    }

    @ViewBuilder
    private var auras: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0099ff")
                        .opacity(0.35),
                    .clear
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "ff0033")
                        .opacity(0.28),
                    .clear
                ]),
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 500
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "a855f7")
                        .opacity(0.2),
                    .clear
                ]),
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }

    private func appear() {
        withAnimation(
            .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
        ) {
            pulse = true
        }

        withAnimation(
            .linear(duration: 8)
                .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
    }

    private func verify() {
        UIApplication.shared.sendAction(
            #selector(
                UIResponder.resignFirstResponder
            ),
            to: nil,
            from: nil,
            for: nil
        )

        let trimmed = keyInput
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if trimmed.isEmpty {
            statusText = "VUI LONG NHAP KEY!"
            statusColor = Color(hex: "ff0033")
            UINotificationFeedbackGenerator()
                .notificationOccurred(.error)
            return
        }

        isLoading = true
        statusText = "DANG KIEM TRA..."
        statusColor = Color(hex: "9ca3af")

        FirestoreService.shared.verify(
            key: trimmed,
            device: deviceId
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, key: trimmed)
            }
        }
    }

    private func handleResult(
        _ result: Result<KeyInfo, Error>,
        key: String
    ) {
        switch result {

        case .success(let info):
            statusText =
                "KICH HOAT THANH CONG - "
                + info.tier
            statusColor = Color(hex: "22c55e")
            UserDefaults.standard.set(
                key.uppercased(),
                forKey: "dl_utral_auth"
            )
            UserDefaults.standard.set(
                info.tier,
                forKey: "dl_utral_tier"
            )
            UIImpactFeedbackGenerator(
                style: .heavy
            ).impactOccurred()

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.7
            ) {
                withAnimation(
                    .easeInOut(duration: 0.4)
                ) {
                    isVerified = true
                }
            }

        case .failure(let error):
            statusText = error.localizedDescription
            statusColor = Color(hex: "ff0033")
            UINotificationFeedbackGenerator()
                .notificationOccurred(.error)
        }
    }
}

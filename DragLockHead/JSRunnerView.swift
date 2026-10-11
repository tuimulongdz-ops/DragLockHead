import SwiftUI

struct JSRunnerView: View {
    @State private var output: String = ""
    @State private var isRunning: Bool = false
    @State private var customCode: String = ""
    @State private var visual: JSOutput?

    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(text: "JS ENGINE V11")
            infoCard
            visualCanvas
            customArea
            autoRunBtn
            presetsSection
            outputArea
        }
    }

    private var infoCard: some View {
        InfoCard {
            InfoRow(
                key: "ENGINE",
                value: "JSCORE + BRIDGE"
            )
            InfoRow(
                key: "SCRIPTS",
                value: "\(JSScripts.all.count)"
            )
            InfoRow(
                key: "TRẠNG THÁI",
                value: isRunning ? "CHẠY" : "READY"
            )
            InfoRow(
                key: "RENDER",
                value: "SWIFTUI CANVAS"
            )
        }
    }

    @ViewBuilder
    private var visualCanvas: some View {
        if let v = visual {
            SectionTitle(text: "JS → CANVAS")
            ZStack {
                Color.black.opacity(0.6)

                Canvas { context, size in
                    let w = size.width
                    let h = size.height
                    let col = Color(hex: v.color.isEmpty
                        ? "00d4ff" : v.color)

                    if v.path.count > 1 {
                        var p = Path()
                        let first = v.path[0]
                        p.move(to: CGPoint(
                            x: first.x / 100 * w,
                            y: first.y / 100 * h
                        ))
                        for point in v.path.dropFirst() {
                            p.addLine(to: CGPoint(
                                x: point.x / 100 * w,
                                y: point.y / 100 * h
                            ))
                        }
                        context.stroke(
                            p,
                            with: .color(col),
                            lineWidth: 1.5
                        )
                    }

                    for pt in v.particles {
                        let rect = CGRect(
                            x: pt.x / 100 * w - pt.r / 2,
                            y: pt.y / 100 * h - pt.r / 2,
                            width: pt.r,
                            height: pt.r
                        )
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(
                                col.opacity(pt.a))
                        )
                    }
                }
                .frame(height: 220)

                VStack {
                    HStack {
                        Text(v.text)
                            .font(.system(
                                size: 10,
                                weight: .heavy,
                                design: .monospaced))
                            .foregroundColor(
                                Color(hex: v.color.isEmpty
                                    ? "00d4ff" : v.color))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Color.black.opacity(0.7))
                            .cornerRadius(8)
                        Spacer()
                        Text("P:\(v.particles.count) L:\(v.path.count)")
                            .font(.system(
                                size: 9,
                                weight: .heavy,
                                design: .monospaced))
                            .foregroundColor(
                                Color(hex: "9ca3af"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                    .padding(10)
                    Spacer()
                }
            }
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color(hex: v.color.isEmpty
                            ? "00d4ff" : v.color)
                            .opacity(0.5),
                        lineWidth: 1)
            )
        }
    }

    private var customArea: some View {
        VStack(spacing: 8) {
            SectionTitle(text: "CODE TÙY CHỈNH")
            ZStack(alignment: .topLeading) {
                if customCode.isEmpty {
                    Text("Nhập JS tại đây...")
                        .foregroundColor(
                            Color(hex: "6b7280"))
                        .padding(14)
                        .font(.system(
                            size: 12,
                            design: .monospaced))
                }
                TextEditor(text: $customCode)
                    .font(.system(
                        size: 12,
                        design: .monospaced))
                    .foregroundColor(
                        Color(hex: "00d4ff"))
                    .padding(8)
                    .background(Color.clear)
                    .frame(height: 120)
            }
            .background(Color.black.opacity(0.65))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(hex: "00d4ff")
                            .opacity(0.35),
                        lineWidth: 1)
            )

            HStack(spacing: 8) {
                Button(action: {
                    customCode = ""
                    output = ""
                    visual = nil
                }) {
                    Text("XÓA")
                        .font(.system(
                            size: 12,
                            weight: .black))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Color.white.opacity(0.06))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Button(action: runCustom) {
                    HStack(spacing: 6) {
                        if isRunning {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: .white))
                                .scaleEffect(0.7)
                        } else {
                            Text("▶")
                        }
                        Text("CHẠY")
                            .font(.system(
                                size: 12,
                                weight: .black))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "0099ff"),
                                Color(hex: "00d4ff")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(isRunning)
            }
        }
    }

    private var autoRunBtn: some View {
        Button(action: runAllPresets) {
            HStack(spacing: 6) {
                Text("⚡")
                Text("CHẠY TẤT CẢ")
                    .font(.system(
                        size: 12,
                        weight: .black))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "a855f7"),
                        Color(hex: "ff0033")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing)
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var presetsSection: some View {
        VStack(spacing: 10) {
            SectionTitle(
                text: "PRESET - \(JSScripts.all.count)"
            )
            ForEach(JSScripts.all) { s in
                presetCard(s)
            }
        }
    }

    private func presetCard(_ s: JSScript) -> some View {
        Button(action: {
            customCode = s.code
            runScript(s.code)
        }) {
            HStack(spacing: 10) {
                Text(s.icon)
                    .font(.system(size: 20))
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "0099ff")
                                    .opacity(0.6),
                                Color(hex: "00d4ff")
                                    .opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                    )
                    .cornerRadius(11)
                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    Text(s.name)
                        .font(.system(
                            size: 12,
                            weight: .black))
                        .foregroundColor(.white)
                    Text(s.desc)
                        .font(.system(size: 9.5))
                        .foregroundColor(
                            Color(hex: "9ca3af"))
                }
                Spacer()
                Text("▶")
                    .font(.system(
                        size: 14,
                        weight: .black))
                    .foregroundColor(
                        Color(hex: "00d4ff"))
                    .frame(width: 32, height: 32)
                    .background(
                        Color(hex: "0099ff")
                            .opacity(0.2))
                    .cornerRadius(9)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.03))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color.white.opacity(0.08),
                        lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var outputArea: some View {
        if !output.isEmpty {
            VStack(spacing: 8) {
                SectionTitle(text: "OUTPUT")
                ScrollView {
                    Text(output)
                        .font(.system(
                            size: 11,
                            design: .monospaced))
                        .foregroundColor(
                            Color(hex: "22c55e"))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading)
                        .padding(12)
                }
                .frame(maxHeight: 200)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color(hex: "22c55e")
                                .opacity(0.4),
                            lineWidth: 1)
                )
            }
        }
    }

    private func runCustom() {
        guard !customCode.isEmpty else {
            output = "Nhập code trước"
            return
        }
        runScript(customCode)
    }

    private func runScript(_ code: String) {
        isRunning = true
        output = ""

        DispatchQueue.global(
            qos: .userInitiated
        ).async {
            let r = JSEngine.shared.run(code)
            DispatchQueue.main.async {
                visual = r
                output = r.log.joined(
                    separator: "\n")
                if output.isEmpty {
                    output = "P:\(r.particles.count) L:\(r.path.count)"
                }
                isRunning = false
            }
        }
    }

    private func runAllPresets() {
        isRunning = true
        DispatchQueue.global(
            qos: .userInitiated
        ).async {
            var allLogs: [String] = []
            var lastVisual: JSOutput?
            for s in JSScripts.all {
                let r = JSEngine.shared.run(s.code)
                allLogs.append("=== \(s.name) ===")
                allLogs.append(contentsOf: r.log)
                lastVisual = r
            }
            DispatchQueue.main.async {
                visual = lastVisual
                output = allLogs.joined(
                    separator: "\n")
                isRunning = false
            }
        }
    }
}

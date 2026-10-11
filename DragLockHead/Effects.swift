import SwiftUI

struct FloatingParticles: View {
    @State private var items: [FP] = []
    @State private var tick: Double = 0
    let color: Color

    struct FP: Identifiable {
        let id = UUID()
        let x: Double
        let y: Double
        let r: Double
        let delay: Double
        let op: Double
    }

    var body: some View {
        GeometryReader { g in
            ZStack {
                ForEach(items) { p in
                    Circle()
                        .fill(color)
                        .frame(width: p.r, height: p.r)
                        .position(
                            x: p.x * g.size.width
                                + sin(tick + p.delay) * 30,
                            y: p.y * g.size.height
                                + cos(tick + p.delay) * 30
                        )
                        .opacity(p.op)
                }
            }
            .onAppear {
                build()
                withAnimation(
                    .linear(duration: 10)
                        .repeatForever(autoreverses: true)
                ) {
                    tick = .pi * 2
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func build() {
        var a: [FP] = []
        for _ in 0..<50 {
            a.append(FP(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                r: Double.random(in: 2...6),
                delay: Double.random(in: 0...6),
                op: Double.random(in: 0.3...0.7)
            ))
        }
        items = a
    }
}

struct GridPulse: View {
    @State private var op: Double = 0.10
    let color: Color

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                ForEach(0..<30, id: \.self) { _ in
                    Rectangle()
                        .fill(color)
                        .frame(height: 0.5)
                }
            }
            HStack(spacing: 24) {
                ForEach(0..<15, id: \.self) { _ in
                    Rectangle()
                        .fill(color)
                        .frame(width: 0.5)
                }
            }
        }
        .opacity(op)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                op = 0.22
            }
        }
    }
}

struct AuroraRotate: View {
    @State private var angle: Double = 0
    let color1: Color
    let color2: Color

    var body: some View {
        Rectangle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [
                        color1.opacity(0.15),
                        color2.opacity(0.10),
                        color1.opacity(0.05),
                        color2.opacity(0.15),
                        color1.opacity(0.15)
                    ]),
                    center: .center
                )
            )
            .rotationEffect(.degrees(angle))
            .scaleEffect(2)
            .onAppear {
                withAnimation(
                    .linear(duration: 30)
                        .repeatForever(autoreverses: false)
                ) {
                    angle = 360
                }
            }
    }
}

struct NebulaClouds: View {
    @State private var ph: Double = 0
    let color1: Color
    let color2: Color

    var body: some View {
        ZStack {
            cloud(color1, -100, -100)
            cloud(color2, 100, 100)
            cloud(color1, 0, 150)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 18)
                    .repeatForever(autoreverses: true)
            ) {
                ph = .pi * 2
            }
        }
    }

    private func cloud(
        _ c: Color,
        _ x: Double,
        _ y: Double
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        c.opacity(0.25),
                        .clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 250
                )
            )
            .frame(width: 500, height: 500)
            .offset(
                x: x + sin(ph) * 60,
                y: y + cos(ph) * 60
            )
    }
}

struct ShootingStars: View {
    @State private var fly: Bool = false
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                star(i)
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 3)
                    .repeatForever(autoreverses: false)
            ) {
                fly = true
            }
        }
    }

    private func star(_ i: Int) -> some View {
        let sx = Double(i) * 150 - 150
        let sy = Double(i) * 200 - 200
        return Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white,
                        color.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 80, height: 1.5)
            .rotationEffect(.degrees(45))
            .offset(
                x: fly ? 600 + sx : -600 + sx,
                y: fly ? -600 + sy : 600 + sy
            )
            .opacity(fly ? 0 : 0.8)
    }
}

struct PulseRings: View {
    let color: Color

    var body: some View {
        ZStack {
            PulseRing(color: color, delay: 0.0)
            PulseRing(color: color, delay: 0.8)
            PulseRing(color: color, delay: 1.6)
        }
    }
}

struct PulseRing: View {
    let color: Color
    let delay: Double
    @State private var expand: Bool = false

    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        color.opacity(0.6),
                        color.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
            .frame(
                width: expand ? 500 : 80,
                height: expand ? 500 : 80
            )
            .opacity(expand ? 0 : 0.7)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 3)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    expand = true
                }
            }
    }
}

struct OrbitDots: View {
    @State private var angle: Double = 0
    let color1: Color
    let color2: Color

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                dot(i)
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 12)
                    .repeatForever(autoreverses: false)
            ) {
                angle = 360
            }
        }
    }

    private func dot(_ i: Int) -> some View {
        let base = Double(i) * 45
        return Circle()
            .fill(
                LinearGradient(
                    colors: [color1, color2],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 5, height: 5)
            .shadow(color: color1, radius: 6)
            .offset(y: -60)
            .rotationEffect(
                .degrees(base + angle)
            )
    }
}

struct TapRippleLayer: View {
    let ripples: [Ripple]

    var body: some View {
        GeometryReader { _ in
            ZStack {
                ForEach(ripples) { r in
                    RippleCircle(color: r.color)
                        .position(r.pos)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct RippleCircle: View {
    let color: Color
    @State private var scale: CGFloat = 0.2
    @State private var op: Double = 0.9

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 3)
                .frame(width: 60, height: 60)
                .scaleEffect(scale)
                .opacity(op)
            Circle()
                .stroke(color, lineWidth: 1.5)
                .frame(width: 60, height: 60)
                .scaleEffect(scale * 0.6)
                .opacity(op * 0.6)
        }
        .onAppear {
            withAnimation(
                .easeOut(duration: 0.7)
            ) {
                scale = 6
                op = 0
            }
        }
    }
}

struct CleanOverlay: View {
    @ObservedObject var state: StateManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()
            VStack(spacing: 22) {
                ringView
                Text(state.cleanTitle)
                    .font(.system(
                        size: 14,
                        weight: .black))
                    .foregroundColor(.white)
                Text(state.cleanStatus)
                    .font(.system(
                        size: 12,
                        weight: .heavy))
                    .foregroundColor(
                        Color(hex: "9ca3af"))
                progressBar
                logView
            }
            .padding(30)
        }
    }

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(
                    state.accentColor.opacity(0.2),
                    lineWidth: 6)
                .frame(width: 120, height: 120)
            Circle()
                .trim(
                    from: 0,
                    to: state.cleanProgress)
                .stroke(
                    LinearGradient(
                        colors: [
                            state.accentColor,
                            Color(hex: "ff0033")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing),
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
            Text("\(Int(state.cleanProgress * 100))%")
                .font(.system(
                    size: 22,
                    weight: .black,
                    design: .monospaced))
                .foregroundColor(state.accentColor)
        }
        .shadow(
            color: state.accentColor.opacity(0.6),
            radius: 20)
    }

    private var progressBar: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                state.accentColor,
                                Color(hex: "ff0033")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .frame(
                        width: g.size.width
                            * CGFloat(state.cleanProgress)
                    )
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 40)
    }

    private var logView: some View {
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            ForEach(
                Array(state.cleanLog.suffix(5)),
                id: \.self
            ) { line in
                HStack(spacing: 6) {
                    Text(">")
                        .foregroundColor(
                            state.accentColor)
                    Text(line)
                        .foregroundColor(
                            Color(hex: "9ca3af"))
                }
                .font(.system(
                    size: 10,
                    design: .monospaced))
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

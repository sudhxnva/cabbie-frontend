import SwiftUI

struct VoiceOrbView: View {
    enum OrbState {
        case idle
        case connecting
        case listening
        case speaking
    }

    let state: OrbState
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyan.opacity(0.28), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 150
                    )
                )
                .scaleEffect(pulse ? 1.1 : 0.92)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.cyan.opacity(0.9),
                            Color.blue.opacity(0.95),
                            Color.cyan.opacity(0.9),
                            Color.white.opacity(0.7),
                            Color.cyan.opacity(0.9)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round)
                )
                .blur(radius: state == .speaking ? 0.6 : 0)
                .scaleEffect(scaleMultiplier)

            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 64, height: 64)
        }
        .padding(24)
        .onAppear {
            applyAnimation()
        }
        .onChange(of: state) { _, _ in
            applyAnimation()
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var scaleMultiplier: CGFloat {
        switch state {
        case .idle: 0.75
        case .connecting: 0.82
        case .listening: 0.9
        case .speaking: 1.0
        }
    }

    private var accessibilityLabel: String {
        switch state {
        case .idle: "Voice idle"
        case .connecting: "Voice connecting"
        case .listening: "Voice listening"
        case .speaking: "Voice speaking"
        }
    }

    private func applyAnimation() {
        pulse = false
        withAnimation(animationStyle) {
            pulse = state != .idle
        }
    }

    private var animationStyle: Animation {
        switch state {
        case .idle:
            .easeOut(duration: 0.2)
        case .connecting:
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
        case .listening:
            .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        case .speaking:
            .easeInOut(duration: 0.42).repeatForever(autoreverses: true)
        }
    }
}

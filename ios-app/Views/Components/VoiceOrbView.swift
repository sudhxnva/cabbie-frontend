import SwiftUI

struct VoiceOrbView: View {
    enum OrbState {
        case idle
        case listening
        case speaking
    }

    let state: OrbState
    @State private var pulse = false

    private var baseColor: Color {
        switch state {
        case .idle: .gray
        case .listening: .blue
        case .speaking: .green
        }
    }

    private var scaleRange: ClosedRange<CGFloat> {
        switch state {
        case .idle: 1.0...1.0
        case .listening: 0.9...1.15
        case .speaking: 0.95...1.25
        }
    }

    private var animation: Animation {
        switch state {
        case .idle:
            .easeOut(duration: 0.2)
        case .listening:
            .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
        case .speaking:
            .easeInOut(duration: 0.45).repeatForever(autoreverses: true)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(baseColor.opacity(0.2))
                .frame(width: 54, height: 54)
                .scaleEffect(pulse ? scaleRange.upperBound : scaleRange.lowerBound)

            Circle()
                .fill(baseColor)
                .frame(width: 28, height: 28)
        }
        .onAppear { applyAnimation() }
        .onChange(of: state) { _, _ in
            applyAnimation()
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        switch state {
        case .idle: "Voice idle"
        case .listening: "Voice listening"
        case .speaking: "Voice speaking"
        }
    }

    private func applyAnimation() {
        pulse = false
        withAnimation(animation) {
            pulse = state != .idle
        }
    }
}

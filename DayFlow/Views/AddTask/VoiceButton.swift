import SwiftUI

struct VoiceButton: View {
    @Bindable var recognizer: VoiceRecognizer
    let onTranscript: (String) -> Void

    @State private var pulseOpacity = 0.6

    var label: String {
        switch recognizer.state {
        case .idle:       return "Voice input"
        case .listening:  return "Listening…"
        case .processing: return "Processing…"
        }
    }

    var icon: String {
        switch recognizer.state {
        case .idle:       return "🎙️"
        case .listening:  return "🎙️"
        case .processing: return "🤖"
        }
    }

    var isActive: Bool { recognizer.state != .idle }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if recognizer.state == .idle {
                recognizer.startRecording()
            } else {
                recognizer.stopRecording()
            }
        } label: {
            HStack(spacing: 10) {
                Text(icon).font(.system(size: 18))
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isActive ? Color.coral : Color.textSec)
                Spacer()
                if recognizer.state == .listening {
                    Circle()
                        .fill(Color.coral)
                        .frame(width: 8, height: 8)
                        .opacity(pulseOpacity)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.7)
                                .repeatForever(autoreverses: true)
                            ) { pulseOpacity = 0.1 }
                        }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(isActive ? Color.coral.opacity(0.12) : Color.surface1)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isActive ? Color.coral : Color.surface3, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .onChange(of: recognizer.state) { _, new in
            if new == .processing, !recognizer.transcript.isEmpty {
                onTranscript(recognizer.transcript)
            }
        }
    }
}

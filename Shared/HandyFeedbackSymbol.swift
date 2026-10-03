import SwiftUI

struct HandyFeedbackSymbol: View {
    enum Kind { case sounds, haptics }
    let kind: Kind
    let enabled: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        FeedbackOutline(kind: kind, progress: enabled ? 1 : 0)
            .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            .frame(width: 24, height: 24)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: enabled)
            .accessibilityHidden(true)
    }
}

private struct FeedbackOutline: Shape {
    let kind: HandyFeedbackSymbol.Kind
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let on = kind == .sounds ? HandyMorphPaths.soundsOn : HandyMorphPaths.hapticsOn
        let off = kind == .sounds ? HandyMorphPaths.soundsOff : HandyMorphPaths.hapticsOff
        var path = Path()
        for (start, end) in zip(off, on) {
            let points = zip(start, end).map { a, b in
                CGPoint(x: rect.minX + (a.x + (b.x - a.x) * progress) * rect.width,
                        y: rect.minY + (a.y + (b.y - a.y) * progress) * rect.height)
            }
            guard let first = points.first,
                  points.contains(where: { abs($0.x - first.x) + abs($0.y - first.y) > 0.01 }) else { continue }
            path.move(to: first)
            points.dropFirst().forEach { path.addLine(to: $0) }
        }
        return path
    }
}

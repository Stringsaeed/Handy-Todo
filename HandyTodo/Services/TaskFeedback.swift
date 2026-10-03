import UIKit
import AVFoundation

@MainActor
enum TaskFeedback {
    enum Action { case completion, deletion, undo }
    private static var player: AVAudioPlayer?

    static func play(_ action: Action) {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "hapticsEnabled") as? Bool ?? true {
            switch action {
            case .completion: UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .deletion: UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            case .undo: UISelectionFeedbackGenerator().selectionChanged()
            }
        }
        guard action != .undo, defaults.object(forKey: "soundsEnabled") as? Bool ?? true,
              let url = Bundle.main.url(forResource: action == .completion ? "complete" : "delete",
                                        withExtension: "wav") else { return }
        do {
            // Ambient respects the silent switch and mixes with the user's music.
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // Audio feedback is optional; a saved task must still succeed without it.
        }
    }
}

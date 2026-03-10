import Foundation
import AVFoundation

/// Text-to-Speech service for reading product names, counts, and audit results aloud.
@Observable
@MainActor
final class TTSService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = TTSService()

    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool = false

    private var pendingItems: [(name: String, count: Int)] = []
    private var currentIndex: Int = 0

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public API

    /// Speak a single text string
    func speak(_ text: String) {
        guard ttsEnabled else { return }
        stopSpeaking()
        let utterance = makeUtterance(text)
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Speak a single line item: "Product Name: X units"
    func speakLineItem(name: String, count: Int) {
        let unit = count == 1 ? "unit" : "units"
        speak("\(name): \(count) \(unit)")
    }

    /// Speak all results sequentially
    func speakAllResults(items: [(name: String, count: Int)]) {
        guard ttsEnabled, !items.isEmpty else { return }
        stopSpeaking()
        pendingItems = items
        currentIndex = 0
        isSpeaking = true
        speakNext()
    }

    /// Stop all speech immediately
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        pendingItems = []
        currentIndex = 0
        isSpeaking = false
    }

    /// Speak a barcode scan result
    func speakBarcodeScan(productName: String) {
        guard barcodeAutoSpeak else { return }
        speak("Scanned: \(productName)")
    }

    /// Speak unknown barcode
    func speakUnknownBarcode(_ code: String) {
        guard barcodeAutoSpeak else { return }
        let short = code.count > 8 ? String(code.suffix(6)) : code
        speak("Unknown barcode ending \(short)")
    }

    // MARK: - Settings

    private var ttsEnabled: Bool {
        UserDefaults.standard.object(forKey: "ttsReadbackEnabled") as? Bool ?? true
    }

    private var speechRate: Float {
        Float(UserDefaults.standard.object(forKey: "ttsSpeechRate") as? Double ?? 0.48)
    }

    private var barcodeAutoSpeak: Bool {
        UserDefaults.standard.object(forKey: "barcodeAutoSpeak") as? Bool ?? true
    }

    // MARK: - Private

    private func makeUtterance(_ text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speechRate
        utterance.pitchMultiplier = 1.05
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.15
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        return utterance
    }

    private func speakNext() {
        guard currentIndex < pendingItems.count else {
            isSpeaking = false
            pendingItems = []
            return
        }
        let item = pendingItems[currentIndex]
        let unit = item.count == 1 ? "unit" : "units"
        let text = "\(item.name): \(item.count) \(unit)"
        let utterance = makeUtterance(text)
        synthesizer.speak(utterance)
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.currentIndex += 1
            if self.currentIndex < self.pendingItems.count {
                self.speakNext()
            } else {
                self.isSpeaking = false
                self.pendingItems = []
            }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}

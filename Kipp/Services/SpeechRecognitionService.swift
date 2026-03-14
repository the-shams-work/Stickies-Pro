//
//  SpeechRecognitionService.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 14/03/26.
//

import Foundation
import Speech
import AVFoundation

@MainActor
final class SpeechRecognitionService: ObservableObject {

    @Published private(set) var isListening = false
    @Published private(set) var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let recognitionQueue = DispatchQueue(label: "com.kipp.speechrecognition", qos: .userInitiated)

    private var onResult: ((String) -> Void)?
    private var contentBeforeSpeech: String = ""

    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        checkAuthorizationStatus()

        if authorizationStatus == .authorized {
            return await ensureMicrophonePermission()
        }

        if authorizationStatus == .denied {
            errorMessage = String(localized: "addnote.dictation.error.speech.denied")
            return false
        }

        if authorizationStatus == .restricted {
            errorMessage = String(localized: "addnote.dictation.error.speech.restricted")
            return false
        }

        // .notDetermined
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                Task { @MainActor in
                    self?.authorizationStatus = status
                    switch status {
                    case .authorized:
                        continuation.resume()
                    case .denied:
                        self?.errorMessage = String(localized: "addnote.dictation.error.speech.denied")
                        continuation.resume()
                    case .restricted:
                        self?.errorMessage = String(localized: "addnote.dictation.error.speech.restricted")
                        continuation.resume()
                    case .notDetermined:
                        continuation.resume()
                    @unknown default:
                        continuation.resume()
                    }
                }
            }
        }

        guard authorizationStatus == .authorized else { return false }
        return await ensureMicrophonePermission()
    }

    private func ensureMicrophonePermission() async -> Bool {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            return true
        case .denied:
            errorMessage = String(localized: "addnote.dictation.error.microphone.denied")
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                session.requestRecordPermission { [weak self] granted in
                    Task { @MainActor in
                        if !granted {
                            self?.errorMessage = String(localized: "addnote.dictation.error.microphone.denied")
                        }
                        continuation.resume(returning: granted)
                    }
                }
            }
        @unknown default:
            return false
        }
    }

    // MARK: - Control
    func startRecognition(initialContent: String, onUpdate: @escaping (String) -> Void) {
        guard !isListening else { return }
        contentBeforeSpeech = initialContent
        onResult = onUpdate
        errorMessage = nil

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            errorMessage = String(localized: "addnote.dictation.error.unavailable")
            return
        }

        do {
            try startAudioEngineAndRecognition()
            isListening = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopRecognition() {
        guard isListening else { return }
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isListening = false
        onResult = nil
    }

    // MARK: - Private

    private func startAudioEngineAndRecognition() throws {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }

        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            self?.recognitionQueue.async {
                guard let self = self else { return }
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain == "kAFAssistantErrorDomain", nsError.code == 216 {
                        // User stopped / cancelled; ignore
                        return
                    }
                    Task { @MainActor in
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
                guard let result = result else { return }
                let transcribed = result.bestTranscription.formattedString
                let isFinal = result.isFinal
                Task { @MainActor in
                    let prefix = self.contentBeforeSpeech.trimmingCharacters(in: .whitespacesAndNewlines)
                    let separator = prefix.isEmpty ? "" : " "
                    let fullText = prefix + separator + transcribed
                    self.onResult?(fullText)
                    if isFinal {
                        self.contentBeforeSpeech = fullText
                    }
                }
            }
        }
    }
}

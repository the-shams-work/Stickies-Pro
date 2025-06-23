//
//  SpeechRecognizer.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 18/02/25.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false

    override init() {
        super.init()
        speechRecognizer?.delegate = self
        requestPermissions()
    }

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Speech recognition authorized")
            case .denied, .restricted, .notDetermined:
                print("Speech recognition not available")
            @unknown default:
                break
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("Microphone permission denied")
            }
        }
    }

    func startTranscribing(completion: @escaping (String) -> Void) {
        guard !isRecording else { return }
        isRecording = true

        stopTranscribing()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup error: \(error.localizedDescription)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                completion(result.bestTranscription.formattedString)
            } else if let error = error {
                print("Recognition Error: \(error.localizedDescription)")
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
        }
    }

    func stopTranscribing() {
        guard isRecording else { return }
        isRecording = false

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}


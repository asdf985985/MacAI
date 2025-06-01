import Foundation
import AVFoundation
import Speech
import Combine

public class STTManager {
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?
    private var resultPublisher = PassthroughSubject<String, Error>()
    public private(set) var isListening = false
    
    public var publisher: AnyPublisher<String, Error> {
        resultPublisher.eraseToAnyPublisher()
    }
    
    public init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }
    
    public func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            let granted = status == .authorized
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    public func startListening() {
        guard !isListening else { return }
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            resultPublisher.send(completion: .failure(NSError(domain: "STTManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition unavailable"])))
            return
        }
        
        if audioEngine?.isRunning == true {
            audioEngine?.stop()
            recognitionRequest?.endAudio()
            return
        }
        
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine?.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            if let result = result {
                self?.resultPublisher.send(result.bestTranscription.formattedString)
            }
            if error != nil {
                self?.audioEngine?.stop()
                inputNode?.removeTap(onBus: 0)
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine?.prepare()
        do {
            try audioEngine?.start()
        } catch {
            resultPublisher.send(completion: .failure(error))
        }
        isListening = true
    }
    
    public func stopListening() {
        guard isListening else { return }
        audioEngine?.stop()
        recognitionRequest?.endAudio()
        isListening = false
    }
    
    public func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }
} 
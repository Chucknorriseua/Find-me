//
//  AudioRecorderViewModel.swift
//  Find me
//
//  Created by Евгений Полтавец on 20/12/2024.
//

import AVFoundation
import SwiftUI
import FirebaseStorage
import Network


@MainActor
class AudioRecorderViewModel: ObservableObject {
    
    static let shared = AudioRecorderViewModel()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVAudioPlayer?
    
    private var networkMonitor: NWPathMonitor?
    private var isNetworkAvailable = false
    private var shouldRetryUpload = false
    private var isRetrying = false
    private var audioData: Data?
    
    @Published var isRecording = false
    @Published var isShowAlert = false
    @Published var message: String = ""
    @Published var isPlayAudiooo = false
    
    
    @Published var audioFileURL: URL?
    @Published var progress: Float = 0.0
    @Published var currentTime: TimeInterval = 0.0
    @Published var duration: TimeInterval = 0.0
    @Published var selectedRecords: String? = nil
    @Published var recordDurationTimer: Double = 10
    @Published var timer: Timer?
    
    @AppStorage("isButtonPressed", store: UserDefaults(suiteName: "group.findme.com"))
    var isButtonPressed: Bool = false
    
    
    var currentTimeFormatted: String {
        formatTime(currentTime)
    }
    
    var durationFormatted: String {
        formatTime(duration)
    }
    
    init() {
        monitorNetwork()
        Task {
            await requestPermission()
        }
    }
    
    private func monitorNetwork() {
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = { path in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if path.status == .satisfied {
                    self.isNetworkAvailable = true
                    if self.shouldRetryUpload {
                        Task {
                            await self.retryUpload()
                        }
                    }
                } else {
                    self.isNetworkAvailable = false
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitorQueue")
        networkMonitor?.start(queue: queue)
    }
    
    private func retryUpload() async {
        guard let audioData = self.audioData, let fileURL = self.audioFileURL else { return }
        
        guard !isRetrying else { return }
        isRetrying = true
        
        do {
            let friend = FindMeViewModel.shared.myfriend
            for friendId in friend {
                let download = try await FireBaseManager.sherad.sendVoiceRecords(id: friendId.id, records: audioData)
                print("Retried sending \(String(describing: download))")
            }
            try FileManager.default.removeItem(atPath: fileURL.path())
            self.shouldRetryUpload = false
            self.audioData = nil
            self.audioFileURL = nil
        } catch {
            isRetrying = false
            print("Failed to retry upload: \(error.localizedDescription)")
        }
    }
    
    private func requestPermission() async  {
        if #available(iOS 17.0, *) {
            let granted = await AVAudioApplication.requestRecordPermission()
            if !granted {
                print("no access to the microphone")
            }
        } else {
            let granted = await withCheckedContinuation { continuation in
                audioSession.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            if !granted {
                print("no access to the microphone")
            }
        }
    }
    
    func startPlayback() {
        isPlayAudiooo = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.currentTime < self.duration {
                    self.currentTime += 1.0
                    self.progress = Float(self.currentTime / self.duration)
                } else {
                    self.stopAudioPlayer()
                }
            }
        }
    }
    
    func startRecordsLoop() async {
        guard isButtonPressed else { return }
        guard !isRecording else { return }
        await startRecording()
        
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func audioPlayer(url: URL?, record: String) async {
        selectedRecords = record
        guard let audioUrl = url else { return }
        do {
            let data = try await playBackAudioFromUrl(url: audioUrl)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlayAudiooo = true
            if let player = audioPlayer {
                duration = player.duration
            }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.startProgressTimer()
            }
        } catch {
            stopAudioPlayer()
            isShowAlert = true
            message = error.localizedDescription
            await MainActor.run {
                self.stopAudioPlayer()
            }
        }
    }
    
    func playBackAudioFromUrl(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            isShowAlert = true
            message = error.localizedDescription
            throw error
        }
    }
    
    func downloadAudioFromURL(urlString: String) async -> URL? {
        do {
            guard let fileURL = URL(string: urlString) else {
                throw NSError(domain: "Download Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }
            
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentDirectory.appendingPathComponent(fileURL.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                return destinationURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: fileURL)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "Download Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not found or inaccessible"])
            }
            try data.write(to: destinationURL)
            audioFileURL = destinationURL
            return destinationURL
        } catch {
            isShowAlert = true
            message = error.localizedDescription
            return nil
        }
    }
    
    
    func startProgressTimer() {
        Task {
            while audioPlayer?.isPlaying == true {
                await MainActor.run {
                    if let player = self.audioPlayer {
                        self.currentTime = player.currentTime
                        self.progress = Float(player.currentTime / player.duration)
                    }
                }
            }
        }
    }
    
    func stopAudioPlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlayAudiooo = false
        progress = 0.0
        currentTime = 0.0
        duration = 0.0
        timer?.invalidate()
        timer = nil
        selectedRecords = nil
        print("Stop")
    }
    func pauseAudio() {
        audioPlayer?.pause()
        isPlayAudiooo = false
        print("PAUSE")
    }
    func resumeAudio() {
        audioPlayer?.play()
        isPlayAudiooo = true
        startProgressTimer()
        print("RESUME")
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: recordDurationTimer, repeats: false, block: { [weak self] _ in
            guard let self else { return }
            Task {
                await self.stopRecording()
            }
        })
    }
    
    func startRecording() async {
        guard !isRecording else { return }
   
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers, .overrideMutedMicrophoneInterruption])
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Error settings audio \(error.localizedDescription)")
            stopAudioIfError()
            message = error.localizedDescription
            
        }
        
        let fileName = UUID().uuidString + ".m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        print("Save file in, \(fileURL.path)")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
            audioFileURL = fileURL
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.startTimer()
            }
        } catch {
            stopAudioIfError()
            message = error.localizedDescription
            print("Error start record \(error.localizedDescription)")
        }
    }

    func stopRecording() async {
        guard isRecording else { return }
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        audioPlayer = nil
        isRecording = false
       
        do {
            try audioSession.setActive(false)
            if let fileURL = audioFileURL {
                let audioData = try Data(contentsOf: fileURL)
                if audioData.isEmpty {
                    print("EMpty--=-=-=-=-")
                }
                if !isNetworkAvailable {
                    self.shouldRetryUpload = true
                    self.audioData = audioData
                    self.audioFileURL = fileURL
                    print("Network unavailable, will retry upload later.")
                    return
                }
             
                    let friend = FindMeViewModel.shared.myfriend
                    for friendId in friend {
                        let dowload = try await FireBaseManager.sherad.sendVoiceRecords(id: friendId.id, records: audioData)
                        print("Send \(String(describing: dowload))")
                    }
                    try FileManager.default.removeItem(atPath: fileURL.path())
                    self.isRetrying = false
                    self.audioData = nil
                    self.audioFileURL = nil
                
//                if isButtonPressed {
//                   
//                    await resetRecordingAndStartNew()
//                } else {
//                    isRecording = false
//                    timer?.invalidate()
//                    timer = nil
//                }
//                
            }
        } catch {
            stopAudioIfError()
            isShowAlert = true
            message = error.localizedDescription
            print("Ошибка завершения аудиосессии: \(error.localizedDescription)")
        }
    }
    
    func stopAudioIfError() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        audioRecorder = nil
        isShowAlert = true
        isShowAlert = true
    }
    
//    private func resetRecordingAndStartNew() async {
//        await startRecording()
//    }
}

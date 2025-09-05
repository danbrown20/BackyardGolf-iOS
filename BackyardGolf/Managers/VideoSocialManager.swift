//
//  VideoSocialManager.swift
//  BackyardGolf
//
//  Created by Dan on 9/4/25.
//

import AVFoundation
import Photos
import UIKit
import SwiftUI

// MARK: - Video Recording Manager
class VideoRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var lastVideoURL: URL?
    @Published var recordingError: String?
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    
    override init() {
        super.init()
        // Don't request permissions immediately to avoid crash
        // requestPermissions()
    }
    
    // MARK: - Permissions
    private func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("📹 Camera permission granted")
            } else {
                DispatchQueue.main.async {
                    self.recordingError = "Camera access required for video recording"
                }
            }
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                print("📱 Photo library access granted")
            }
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        print("🎬 Starting video recording...")
        
        // Request permissions first
        requestPermissions()
        
        setupCaptureSession { [weak self] success in
            if success {
                self?.beginRecording()
            }
        }
    }
    
    func stopRecording() {
        guard isRecording, let output = videoOutput else { return }
        print("⏹️ Stopping video recording...")
        output.stopRecording()
    }
    
    private func setupCaptureSession(completion: @escaping (Bool) -> Void) {
        captureSession = AVCaptureSession()
        guard let session = captureSession else {
            completion(false)
            return
        }
        
        session.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            session.commitConfiguration()
            completion(false)
            return
        }
        
        session.addInput(videoInput)
        
        // Add video output
        videoOutput = AVCaptureMovieFileOutput()
        guard let output = videoOutput, session.canAddOutput(output) else {
            session.commitConfiguration()
            completion(false)
            return
        }
        
        session.addOutput(output)
        session.commitConfiguration()
        
        completion(true)
    }
    
    private func beginRecording() {
        guard let output = videoOutput else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoURL = documentsPath.appendingPathComponent("trick_shot_\(Date().timeIntervalSince1970).mp4")
        
        output.startRecording(to: videoURL, recordingDelegate: self)
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.recordingError = nil
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            
            if let error = error {
                self.recordingError = "Recording failed: \(error.localizedDescription)"
                print("❌ Recording error: \(error)")
            } else {
                self.lastVideoURL = outputFileURL
                print("✅ Video saved to: \(outputFileURL)")
                
                // Save to photo library
                self.saveVideoToPhotoLibrary(url: outputFileURL)
            }
        }
    }
    
    private func saveVideoToPhotoLibrary(url: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { success, error in
                    if success {
                        print("📱 Video saved to photo library")
                    } else if let error = error {
                        print("❌ Failed to save to photo library: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - Social Media Helper Functions

extension SocialMediaManager {
    func shareVideo(url: URL, message: String, from viewController: UIViewController?) {
        print("📤 Sharing video with message: \(message)")
        
        var activityItems: [Any] = [message]
        if FileManager.default.fileExists(atPath: url.path) {
            activityItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Present the share sheet
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityViewController, animated: true)
            }
        }
    }
    
    func generateTrickShotMessage(playerName: String, points: Int) -> String {
        let messages = [
            "🏌️‍♂️ \(playerName) just nailed a \(points)-point trick shot! #BackyardGolf #TrickShot",
            "🎯 INCREDIBLE \(points)-point trick shot by \(playerName)! #GolfLife #TechGolf",
            "⭐ \(playerName) showing off with a \(points)-pointer! Can you beat this? #BackyardGolfChallenge",
            "🔥 \(playerName) with the \(points)-point magic! Who's next? #BackyardGolf #EpicShot",
            "💥 \(playerName) just schooled everyone with this \(points)-point beauty! #GolfSkills #BackyardGolf"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    func generateAchievementMessage(playerName: String, achievement: String) -> String {
        let messages = [
            "🏆 \(playerName) just unlocked: \(achievement)! #BackyardGolf #Achievement",
            "🎖️ \(playerName) earned the \(achievement) badge! #GolfLife #Progress",
            "⭐ \(playerName) is on fire! Just got: \(achievement) #BackyardGolf #Skills"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    func shareScore(playerName: String, score: Int, gameMode: String) -> String {
        let messages = [
            "🏌️‍♂️ \(playerName) scored \(score) points in \(gameMode)! #BackyardGolf #Score",
            "🎯 \(playerName) just crushed it with \(score) points in \(gameMode)! #GolfLife",
            "🔥 \(playerName) with a solid \(score) in \(gameMode)! Can you beat it? #BackyardGolfChallenge"
        ]
        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - Video Share View
struct VideoShareView: View {
    let videoURL: URL
    let message: String
    @ObservedObject var socialManager: SocialMediaManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Video Preview
                VideoPlayerView(url: videoURL)
                    .frame(height: 200)
                    .cornerRadius(12)
                
                // Share Message
                VStack(alignment: .leading, spacing: 8) {
                    Text("Share Message:")
                        .font(.headline)
                    
                    Text(message)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Share Button
                Button(action: {
                    socialManager.shareVideo(url: videoURL, message: message, from: nil)
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Video")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share Trick Shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
            } else {
                Text("Loading video...")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            player = AVPlayer(url: url)
            player?.play()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

// MARK: - Video Player (Simple Implementation)
struct VideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
}

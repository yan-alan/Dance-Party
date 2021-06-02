//
//  ViewController.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-03-30.
//

import UIKit
import AVFoundation
import Vision
import SwiftUI
import Combine
import MediaPlayer
import CoreMotion

protocol DanceControllerDelegate: class {
    func finishedTrackWithScore(track: Track, score: Int)
    func finishedRecording(track: Track)
}
public class DanceController: UIViewController {
    enum Mode {
        case record(track: Track)
        case play(track: Track)
        case learn(track: Track)
        var speed: Double {
            switch self {
            case .play:
                return 1
            case .learn:
                return 0.5
            case .record:
                return 1
            }
        }
        
        var usesFrontFacing: Bool {
            switch self {
            case .play, .learn:
                return true
            default:
                return true
            }
        }
        
        var track: Track {
            switch self {
            case .learn(let t):
                return t
            case .record(let t):
                return t
            case .play(let t):
                return t
            }
        }
    }
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var audioPlayer: AudioManager!
    private var trackViewModel: TrackViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    private var cachedPoints: [Pose] = []
    private var observationPoints: [Pose] = []
    
    private var timelineVC: TimelineViewController!
    private var overlayView: DanceOverlayView!
    private var tutorialView: DanceTutorialView = DanceTutorialView()
    private var displayLink: CADisplayLink?
    private var alertController: UIAlertController?
    private var mode: Mode
    private var coreMotionManager: CMMotionManager!
    weak var delegate: DanceControllerDelegate?
    
    var isMultiplayer: Bool {
        if trackViewModel.multiPlayerSession != nil {
            return true
        }
        return false
    }
    
    convenience init(mode: Mode, session: SessionViewModel? = nil) {
        self.init()
        self.mode = mode
        self.overlayView = DanceOverlayView(mode: mode)
        self.trackViewModel = TrackViewModel(track: mode.track, session: session)
        self.audioPlayer = AudioManager(mode: mode)
    }
    
    private init() {
        self.mode = .play(track: .standard)
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("DEINITTING DANCE CONTROLLER")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cachedPoints = trackViewModel.cachedObservations
        addCameraInput()
        showCameraFeed()
        getCameraFrames()
        captureSession.startRunning()
        audioPlayer.setup()
        audioPlayer.delegate = self
        setupObservers()
        
        timelineVC = TimelineViewController()
        timelineVC.viewModel = trackViewModel
        
        overlayView.setSuperview(self.view!).addConstraints(padding: 0)
        overlayView.pauseButton.addTarget(self, action: #selector(toggleAudio(button:)), for: .touchUpInside)
        overlayView.cancelButton.addTarget(self, action: #selector(stopPlaying(button:)), for: .touchUpInside)
        tutorialView.cancelButton.addTarget(self, action: #selector(stopPlaying(button:)), for: .touchUpInside)

        overlayView.alpha = 0
        if case .learn = mode {
            overlayView.speedButton.addTarget(self, action: #selector(changeSpeed(button:)), for: .touchUpInside)

        }
        if case .record = mode {
        } else {
            moveStateObservers()
            view.addSubview(timelineVC.view)
            timelineVC.view.translatesAutoresizingMaskIntoConstraints = false
            timelineVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -10).isActive = true
            timelineVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 0).isActive = true
            timelineVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 0).isActive = true
            timelineVC.view.heightAnchor.constraint(equalToConstant: 400).isActive = true
            timelineVC.view.alpha = 0
            addChild(timelineVC)
            timelineVC.didMove(toParent: self)
        }
        
        tutorialView.setSuperview(self.view!).addConstraints(padding: 0)
        
        coreMotionManager = CMMotionManager()
        if coreMotionManager.isAccelerometerAvailable {
            coreMotionManager.accelerometerUpdateInterval = 0.5
            coreMotionManager.startAccelerometerUpdates(to: .main) { [self] (data, error) in
                guard let data = data else { return }
                let angle = (-atan2(data.acceleration.x, data.acceleration.y) + .pi)
                let deg = angle * 180 / .pi
                
                if deg > 225 && deg < 315 {
                    previewLayer.connection?.videoOrientation = .landscapeRight
                    videoDataOutput.connection(with: .video)?.videoOrientation = .landscapeRight
                } else if deg > 45 && deg < 135 {
                    previewLayer.connection?.videoOrientation = .landscapeLeft
                    videoDataOutput.connection(with: .video)?.videoOrientation = .landscapeLeft
                } else if deg > 135 && deg < 225 {
                    previewLayer.connection?.videoOrientation = .portraitUpsideDown
                    videoDataOutput.connection(with: .video)?.videoOrientation = .portraitUpsideDown
                } else {
                    previewLayer.connection?.videoOrientation = .portrait
                    videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
                }
            }
        }
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        createDisplayLink()

    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        destroyDisplayLink()
        audioPlayer.pause()
        coreMotionManager.stopAccelerometerUpdates()
    }
    
    private func moveStateObservers() {
        trackViewModel.multiPlayerSession?.$seekTime.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] val in
            guard let self = self else { return }
            
            self.audioPlayer.setTime(val)
        }).store(in: &cancellables)
        
        trackViewModel.multiPlayerSession?.$opponentPose.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] pose in
            guard let self = self else { return }
            
            self.overlayView.opponentBodyView.observation = pose
        }).store(in: &cancellables)
        trackViewModel.multiPlayerSession?.$opponentScore.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] score in
            guard let self = self else { return }
            self.overlayView.scoreLabel.text = "\(self.trackViewModel.score) : \(score)"
            
        }).store(in: &cancellables)
        
        trackViewModel.$moveState.receive(on: DispatchQueue.main).sink { [weak self] val in
            guard let self = self else { return }
            switch val {
            case .perfect:
                self.overlayView.borderView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                self.overlayView.moveLabel.textColor = UIColor.green
                self.overlayView.moveLabel.text = "PERFECT!"
                self.timelineVC.borderView.layer.borderColor = UIColor.green.cgColor
            case .good:
                self.overlayView.borderView.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
                self.overlayView.moveLabel.textColor = UIColor.yellow
                self.overlayView.moveLabel.text = "GOOD!"
                self.timelineVC.borderView.layer.borderColor = UIColor.yellow.cgColor
            case .missed:
                self.overlayView.borderView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                self.overlayView.moveLabel.textColor = UIColor.red
                self.overlayView.moveLabel.text = "MISSED"
                self.timelineVC.borderView.layer.borderColor = UIColor.red.cgColor
            case .none:
                self.overlayView.borderView.backgroundColor = UIColor.clear
                self.overlayView.moveLabel.text = ""
                self.timelineVC.borderView.layer.borderColor = UIColor.white.cgColor
            }
            
            if self.isMultiplayer {
                self.overlayView.scoreLabel.text! = "\(self.trackViewModel.score) : \(self.trackViewModel.multiPlayerSession!.opponentScore)"
            } else {
                self.overlayView.scoreLabel.text! = "\(self.trackViewModel.score)"
            }
        }.store(in: &cancellables)
    }
    private func setupObservers() {
        trackViewModel.$gameState.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] gameState in
            guard let self = self else { return }
            
            switch gameState {
            case .foundBody:
                if !self.isMultiplayer {
                    self.trackViewModel.gameState = .playing
                } else {
                    self.tutorialView.setWaiting()
                    self.trackViewModel.multiPlayerSession?.mpSession.sendToAllPeers("bodyfound:".data(using: .utf8) ?? .init(), reliably: true)
                    self.trackViewModel.multiPlayerSession?.state = .foundBody
                }
            case .lookingForBody:
                self.tutorialView.reset()
                self.audioPlayer.pause()
                UIView.animate(withDuration: 0.3) {
                    self.timelineVC.view.alpha = 0
                    self.overlayView.alpha = 0
                    self.tutorialView.alpha = 1
                }
            case .noCamera:
                break
            case .paused:
                self.audioPlayer.pause()
                self.overlayView.pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            case .playing:
                self.tutorialView.beginCountdown(count: 3)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    
                    UIView.animate(withDuration: 0.3) {
                        self.tutorialView.alpha = 0
                        self.overlayView.alpha = 1
                        self.timelineVC.view.alpha = 1
                    }
                    self.audioPlayer.play()
                    self.overlayView.pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                }
            case .saving:
                self.alertController = UIAlertController(title: "Saving ...", message: nil, preferredStyle: .alert)
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                activityIndicator.isUserInteractionEnabled = false
                activityIndicator.startAnimating()
                
                self.alertController?.view.addSubview(activityIndicator)
                self.alertController?.view.heightAnchor.constraint(equalToConstant: 95).isActive = true
                
                activityIndicator.centerXAnchor.constraint(equalTo: self.alertController!.view.centerXAnchor, constant: 0).isActive = true
                activityIndicator.bottomAnchor.constraint(equalTo: self.alertController!.view.bottomAnchor, constant: -20).isActive = true
                
                self.present(self.alertController!, animated: true)
            case .finished:
                self.alertController?.dismiss(animated: true, completion: nil)
                if case .record = self.mode {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    
                    let vc = UIHostingController(rootView: FinishView(track: self.mode.track, myScore: self.trackViewModel.myScore, opponentScore: self.trackViewModel.multiPlayerSession?.oppScore, doneAction: { [weak self] in
                        if self?.isMultiplayer ?? false {
                            self?.trackViewModel.multiPlayerSession?.state = .ended
                        } else {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }))
                    vc.view.backgroundColor = .clear
                    vc.view.alpha = 0
                    vc.view.setSuperview(self.view).addConstraints(padding: 0)
                    self.addChild(vc)
                    vc.didMove(toParent: self)
                    
                    UIView.animate(withDuration: 0.3) {
                        vc.view.alpha = 1
                    }
                }
            }
        }).store(in: &cancellables)
        trackViewModel.$absoluteDistance.receive(on: DispatchQueue.main).compactMap({String($0)}).assign(to: \.text, on: overlayView.absDistLabel).store(in: &cancellables)
        trackViewModel.$weightedDistance.receive(on: DispatchQueue.main).compactMap({String($0)}).assign(to: \.text, on: overlayView.distanceLabel).store(in: &cancellables)
        
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: mode.usesFrontFacing ? .front : .back).devices.first else {
            fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
        }
        
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }
    
    
    private func showCameraFeed() {
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.layer.bounds
    }
    
    private func createDisplayLink() {
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(perFrameAction))
        displayLink!.preferredFramesPerSecond = 60
        displayLink!.add(to: .current,
                         forMode: .common)
    }
    
    private func destroyDisplayLink() {
        displayLink?.remove(from: .current, forMode: .common)
        displayLink = nil
    }
    
    @objc func perFrameAction(displaylink: CADisplayLink) {
        if case .record = mode {
            return
        }
        updateTrackViewModel()
    }
    
    @objc private func toggleAudio(button: UIButton) {
        if audioPlayer.isPlaying {
            trackViewModel.gameState = .paused
            if isMultiplayer {
                trackViewModel.multiPlayerSession?.mpSession.sendToAllPeers("pause:\(audioPlayer.currentTime)".data(using: .utf8) ?? .init(), reliably: true)
            }
        } else {
            trackViewModel.gameState = .lookingForBody
            if isMultiplayer {
                trackViewModel.multiPlayerSession?.mpSession.sendToAllPeers("resume:\(audioPlayer.currentTime)".data(using: .utf8) ?? .init(), reliably: true)
            }
        }
    }
    
    @objc private func changeSpeed(button: UIButton) {
        if audioPlayer.speed == 0.5 {
            audioPlayer.speed = 0.75
        } else if audioPlayer.speed == 0.75 {
            audioPlayer.speed = 1
        } else if audioPlayer.speed == 1 {
            audioPlayer.speed = 1.5
        } else if audioPlayer.speed == 1.5 {
            audioPlayer.speed = 2
        } else if audioPlayer.speed == 2 {
            audioPlayer.speed = 0.5
        }
        button.setTitle("\(audioPlayer.speed)x", for: .normal)
    }
    @objc private func stopPlaying(button: UIButton) {
        if isMultiplayer {
            trackViewModel.multiPlayerSession?.state = .ended
        }
        navigationController?.popViewController(animated: true)
    }
    
    var lastPose: Pose?
    private func updateTrackViewModel() {
        trackViewModel.currentTime = audioPlayer.currentTime
        trackViewModel.perFrameUpdate(observation: observationPoints.last)
        
        if audioPlayer.currentTime - (observationPoints.last?.time ?? 0) > 5,  trackViewModel.gameState == .playing, !isMultiplayer {
            trackViewModel.gameState = .lookingForBody
            self.tutorialView.topLabel.text = "Lost Body, Enter The Frame Again."
        }
        while cachedPoints.first?.time ?? .infinity < audioPlayer.currentTime {
            lastPose = cachedPoints.removeFirst()
        }
        guard let nextPose = cachedPoints.first, nextPose.hasFullSkeleton else {
            UIView.animate(withDuration: 0.3) {
                self.overlayView.leaderView.alpha = 0
                self.overlayView.myBodyView.alpha = 0
                self.overlayView.opponentBodyView.alpha = 0
                self.timelineVC.view.alpha = 0
            }
            return
        }
        
        if let lastPose = lastPose {
            let linearPose = lastPose.createLinearInterpolation(nextPose: nextPose, currentTime: audioPlayer.currentTime)
            overlayView.leaderBodyView.observation = linearPose
        } else {
            overlayView.leaderBodyView.observation = nextPose
        }
    }
    
    private func getCameraFrames() {
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        captureSession.addOutput(self.videoDataOutput)
        captureSession.sessionPreset = .hd1920x1080
        guard let connection = videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
    }
}

extension DanceController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        detectPose(in: frame)
    }
    
    private func detectPose(in image: CVPixelBuffer) {
        let bodyRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .up, options: [:])
        let request = VNDetectHumanBodyPoseRequest(completionHandler: { [weak self] (request, error) in
            self?.bodyPoseRequestHandler(request: request, error: error)
        })
        try? bodyRequestHandler.perform([request])
    }
    
    func bodyPoseRequestHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        DispatchQueue.main.async {
            observations.forEach { self.processObservation($0) }
        }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard var recognizedPoints =
                try? observation.recognizedPoints(.all) else { return }
        recognizedPoints = recognizedPoints.filter { $1.confidence > 0.5 }
        
        let imagePoints: [VNHumanBodyPoseObservation.JointName : CGPoint] = recognizedPoints.compactMapValues {
            // Translate the point from normalized-coordinates to image coordinates.
            return VNImagePointForNormalizedPoint($0.location,
                                                  Int(self.view.frame.width > self.view.frame.height ? 1920 : 1080),
                                                  Int(self.view.frame.width > self.view.frame.height ? 1080 : 1920))
        }
        
        draw(points: imagePoints)
    }
    
    func draw(points: [VNHumanBodyPoseObservation.JointName : CGPoint]) {
        var finalMap: [String: CGPoint] = [:]
        points.forEach({ finalMap[$0.rawValue.rawValue] = $1 })
        let observation = Pose(time: audioPlayer.currentTime, storedPoints: finalMap)
        
        if trackViewModel.gameState == .playing || trackViewModel.gameState == .paused {
            guard observation.hasFullSkeleton else { return }
            if trackViewModel.gameState == .playing {
                observationPoints.append(observation)
            }
            if isMultiplayer {
                guard let data = try? JSONEncoder().encode(observation) else { return }
                trackViewModel.multiPlayerSession?.mpSession.sendToAllPeers(data, reliably: true)
            }
            
            overlayView.myBodyView.observation = observation
        } else if trackViewModel.gameState == .lookingForBody {
            tutorialView.update(with: points)
            if observation.hasFullSkeleton {
                if isMultiplayer {
                    if case .foundBody = trackViewModel.multiPlayerSession?.state {
                    } else {
                        trackViewModel.gameState = .foundBody
                    }
                } else {
                    trackViewModel.gameState = .foundBody
                }
            }
        }
    }
}

extension DanceController: AudioManagerDelegate {
    func trackDidFinish() {
        switch mode {
        case .learn:
            trackViewModel.gameState = .finished
        case .play:
            delegate?.finishedTrackWithScore(track: mode.track, score: trackViewModel.score)
            trackViewModel.gameState = .finished
        case .record(let t):
//                        writeToFile(track: t)
            writeToUserDefaults(track: t)
        }
    }
    
    private func writeToFile(track: Track) {
        // Get the url of Persons.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(track.fileName).json")
        
        let trimmedFileURL = documentDirectoryUrl.appendingPathComponent("\(track.fileName)-trimmed.json")
        
        Helper.findKeyPoints(in: observationPoints) { trimmed in
            do {
                let data = try JSONEncoder().encode(self.observationPoints)
                try data.write(to: fileUrl, options: [])
                
                let trimmedData =  try JSONEncoder().encode(trimmed)
                try trimmedData.write(to: trimmedFileURL, options: [])
                let activityViewController = UIActivityViewController(activityItems: [fileUrl, trimmedFileURL], applicationActivities: nil)
                // Show the share-view
                DispatchQueue.main.async {
                    activityViewController.popoverPresentationController?.sourceView = self.overlayView.pauseButton
                    self.present(activityViewController, animated: true, completion: nil)
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func writeToUserDefaults(track: Track) {
        trackViewModel.gameState = .saving
        Helper.findKeyPoints(in: observationPoints) { trimmed in
            do {
                let data = try JSONEncoder().encode(self.observationPoints)
                UserDefaults.standard.setValue(data, forKey: track.userDefaultsKey)
                
                let trimmedData =  try JSONEncoder().encode(trimmed)
                UserDefaults.standard.setValue(trimmedData, forKey: track.userDefaultsKey + "-trimmed")
                self.trackViewModel.gameState = .finished
                self.delegate?.finishedRecording(track: track)
            } catch {
                print(error)
            }
            
        }
    }
}

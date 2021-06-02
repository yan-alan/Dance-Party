//
//  TrackListViewController.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import SwiftUI
import Combine
import MediaPlayer

public class TrackListViewModel: ObservableObject {
    public enum State {
        case play(track: Track)
        case learn(track: Track)
        case record(track: Track)
        case goBack
        case openLibrary
        case none
    }
    @Published var state: State = .none
    @Published var mediaItems: [Track] = Helper.builtInTracks
    var multiPlayer: Bool
    init(multiPlayer: Bool = false) {
        self.multiPlayer = multiPlayer
        self.mediaItems = multiPlayer ? Helper.builtInTracks : Helper.allTracks
    }
}


public class TrackListViewController: UIHostingController<TrackListView> {
    var state: TrackListViewModel = .init()
    var cancellables: Set<AnyCancellable> = []
    
    convenience init() {
        self.init(rootView: TrackListView(viewModel: .init()))
        rootView = TrackListView(viewModel: state)
        state.$state.receive(on: DispatchQueue.main).sink { [weak self] val in
            guard let self = self else { return }
            switch val {
            case .openLibrary:
                self.openLibrary()
            case .goBack:
                self.goBack()
            case .play(let t):
                self.play(track: t)
            case .learn(let t):
                self.learn(track: t)
            case .record(let t):
                self.record(track: t)
            case .none:
                break
            }
        }.store(in: &cancellables)
    }
    
    override private init(rootView: TrackListView) {
        super.init(rootView: rootView)
    }
    deinit {
        print("DESTROYING TRACK LIST VIEW CONTROLLER")
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func openLibrary() {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        picker.prompt = "Choose a song"
        present(picker, animated: true, completion: nil)
    }
    
    func play(track: Track) {
        let danceVC = DanceController(mode: .play(track: track))
        danceVC.delegate = self
        navigationController?.pushViewController(danceVC, animated: true)
    }
    
    func learn(track: Track) {
        let danceVC = DanceController(mode: .learn(track: track))
        danceVC.delegate = self
        navigationController?.pushViewController(danceVC, animated: true)
    }
    
    func record(track: Track) {
        let danceVC = DanceController(mode: .record(track: track))
        danceVC.delegate = self
        navigationController?.pushViewController(danceVC, animated: true)
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension TrackListViewController: MPMediaPickerControllerDelegate {
    public func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)
        mediaItemCollection.items.filter({ item in !state.mediaItems.contains(where: {$0.url == item})}).forEach { item in
            let track: Track = .init(fileName: "", trackName: item.title ?? "", author: item.artist ?? "", url: item, image: item.artwork?.image(at: .init(width: 200, height: 200)))
            state.mediaItems.append(track)
            Helper.addedTracks.append(track)
        }
    }
}

extension TrackListViewController: DanceControllerDelegate {
    func finishedTrackWithScore(track: Track, score: Int) {
        guard let firstIndex = state.mediaItems.firstIndex(where: {track.trackName == $0.trackName}) else { return }
        state.mediaItems[firstIndex].highScores.append(score)
        state.mediaItems[firstIndex].highScores.sort(by: { $0 > $1 })
    }
    func finishedRecording(track: Track) {
        guard let firstIndex = state.mediaItems.firstIndex(where: {track.trackName == $0.trackName}) else { return }
        state.mediaItems[firstIndex].highScores = state.mediaItems[firstIndex].highScores
    }
}

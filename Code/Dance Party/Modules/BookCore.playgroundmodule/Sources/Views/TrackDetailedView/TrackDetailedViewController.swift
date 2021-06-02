//
//  TrackDetailedViewController.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import SwiftUI
import Combine

public class TrackDetailedViewModel: ObservableObject {
    public enum State {
        case play(track: Track)
        case learn(track: Track)
        case record(track: Track)
        case goBack
        case none
    }
    @Published var state: State = .none
}

public class TrackDetailedViewController: UIHostingController<TrackDetailedView> {
    var state: TrackDetailedViewModel = .init()
    var cancellables: Set<AnyCancellable> = []

    convenience init(track: Track) {
        self.init(rootView: TrackDetailedView(track: track))
        rootView = TrackDetailedView(track: track, viewModel: state)
        state.$state.receive(on: DispatchQueue.main).sink { [weak self] val in
            guard let self = self else { return }
            switch val {
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
    
    override private init(rootView: TrackDetailedView) {
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play(track: Track) {
        navigationController?.pushViewController(DanceController(mode: .play(track: track)), animated: true)
    }
    
    func learn(track: Track) {
        navigationController?.pushViewController(DanceController(mode: .learn(track: track)), animated: true)
    }
    
    func record(track: Track) {
        navigationController?.pushViewController(DanceController(mode: .record(track: track)), animated: true)
    }

    func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

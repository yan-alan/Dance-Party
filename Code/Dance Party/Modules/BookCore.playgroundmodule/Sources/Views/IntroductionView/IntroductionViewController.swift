//
//  IntroductionViewController.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import SwiftUI
import Combine

public class IntroductionViewModel: ObservableObject {
    public enum State {
        case singlePlayer
        case hosting
        case joining
        case none
    }
    @Published var state: State = .none
}
public class IntroductionViewController: UIHostingController<IntroductionView> {
    var state: IntroductionViewModel = .init()
    var cancellables: Set<AnyCancellable> = []

    convenience public init() {
        self.init(rootView: IntroductionView())
        rootView = IntroductionView(viewModel: state)
        state.$state.receive(on: DispatchQueue.main).sink { [weak self] val in
            guard let self = self else { return }
            switch val {
            case .singlePlayer:
                self.playSinglePlayer()
            case .hosting:
                self.playMultiPlayer(host: true)
            case .joining:
                self.playMultiPlayer(host: false)
            case .none:
                break
            }
        }.store(in: &cancellables)
    }
    
    override private init(rootView: IntroductionView) {
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playSinglePlayer() {
        navigationController?.pushViewController(TrackListViewController(), animated: true)
    }
    
    func playMultiPlayer(host: Bool) {
        let vc = FindSessionViewController(isHost: host)
        navigationController?.pushViewController(vc, animated: true)

    }
}

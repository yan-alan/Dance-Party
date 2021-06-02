//
//  FindSessionViewController.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-10.
//

import SwiftUI
import Combine
import MultipeerConnectivity

public class SessionViewModel: ObservableObject, MultipeerHelperDelegate {
    enum State {
        case searching
        case hosting
        case pickingSong
        case waitingToPickSong
        
        //sitting in body finding
        case startingAsJoinee(track: Track)
        case startingAsHost
        //kkk
        case paused
        case lookingForBody
        case foundBody
        case playing
        case ended
        var isHost: Bool {
            switch self {
            case .hosting, .pickingSong:
                return true
            default:
                return false
            }
        }
    }
    var isHost: Bool
    @Published var state: State
    @Published var opponentScore: Int = 0
    var opponentPerfects = 0
    var opponentGoods = 0
    var opponentMissed = 0

    @Published var seekTime: TimeInterval = 0
    @Published var opponentPose: Pose?
    
    var oppScore: Score {
        return .init(rawScore: opponentScore, perfects: opponentPerfects, goods: opponentGoods, missed: opponentMissed)
    }
    var trackViewModel: TrackListViewModel!
    
    lazy var mpSession = MultipeerHelper(serviceName: "dance-time", sessionType: state.isHost ? .host : .peer, delegate: self)
    
    init(host: Bool) {
        isHost = host
        state = host ? .hosting : .searching
        
        trackViewModel = .init(multiPlayer: true)
        mpSession.delegate = self
    }
    
    public func peerJoined(_ peer: MCPeerID) {
        DispatchQueue.main.async { [self] in
            
            if case .hosting = state {
                state = .pickingSong
            } else if case .searching = state {
                state = .waitingToPickSong
            }
        }
    }
    
    public func peerLeft(_ peer: MCPeerID) {
        DispatchQueue.main.async {
            self.state = .ended
        }
    }
    
    public func peerLost(_ peer: MCPeerID) {
        DispatchQueue.main.async {
            self.state = .ended
        }
    }
    
    public func receivedData(_ data: Data, _ peer: MCPeerID) {
        if let pose = try? JSONDecoder().decode(Pose.self, from: data) {
            DispatchQueue.main.async {
                self.opponentPose = pose
            }
            
            return
        }
        
        guard let stringValue = String(data: data, encoding: .utf8) else { print("RECEIVED DATA COULDNT DECODE"); return }
        
        print(stringValue)
        let split = stringValue.split(separator: ":")
        let keyCommand = split[0]
        
        if keyCommand == "play" {
            guard let track = Helper.builtInTracks.first(where: {$0.fileName == split[1]}) else { return }
            DispatchQueue.main.async {
                self.state = .startingAsJoinee(track: track)
            }
            
        } else if keyCommand == "bodyfound" {
            DispatchQueue.main.async {
                if case .foundBody = self.state {
                    self.state = .playing
                    self.mpSession.sendToAllPeers("bodyfound:".data(using: .utf8) ?? .init(), reliably: true)
                }
            }
        } else if keyCommand == "pause" {
            DispatchQueue.main.async {
                if self.isHost {
                    self.state = .paused
                } else {
                    self.state = .paused
                }
                self.seekTime = TimeInterval(split[1]) ?? 0
            }
        } else if keyCommand == "resume" {
            DispatchQueue.main.async {
                self.state = .lookingForBody
                self.seekTime = TimeInterval(split[1]) ?? 0
            }
        } else if keyCommand == "score" {
            DispatchQueue.main.async {
                self.opponentScore = Int(split[1])!
            }
        } else if keyCommand == "good" {
            self.opponentGoods += 1
        } else if keyCommand == "perfect" {
            self.opponentPerfects += 1
        } else if keyCommand == "missed" {
            self.opponentMissed += 1
        }
    }
}
public class FindSessionViewController: UIHostingController<FindSessionView> {
    var state: SessionViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    convenience public init(isHost: Bool) {
        self.init(rootView: FindSessionView(viewModel: .init(host: false)))
        state = .init(host: isHost)
        rootView = FindSessionView(viewModel: state)
        
        state.trackViewModel.$state.receive(on: DispatchQueue.main).sink { [weak self] val in
            guard let self = self else { return }
            switch val {
            case .goBack:
                self.navigationController?.popViewController(animated: true)
            case .play(let track):
                let playVC = DanceController(mode: .play(track: track), session: self.state)
                
                self.state.mpSession.sendToAllPeers("play:\(track.fileName)".data(using: .utf8) ?? .init(), reliably: true)
                self.navigationController?.pushViewController(playVC, animated: true)
            case .none:
                break
            default:
                break
            }
        }.store(in: &cancellables)
        
        state.$state.receive(on: DispatchQueue.main).sink { [weak self] val in
            guard let self = self else { return }
            switch val {
            case .startingAsJoinee(let track):
                let playVC = DanceController(mode: .play(track: track), session: self.state)
                self.navigationController?.pushViewController(playVC, animated: true)
            case .ended:
                self.navigationController?.popToRootViewController(animated: true)
            default:
                break
            }
        }.store(in: &cancellables)
    }
    
    override private init(rootView: FindSessionView) {
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

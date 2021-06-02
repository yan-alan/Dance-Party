//
//  TrackViewModel.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-04.
//

import SwiftUI
import Combine

public class TrackViewModel: ObservableObject {
    enum MoveState {
        case none
        case missed
        case good
        case perfect
    }
    
    enum GameState: String {
        case lookingForBody
        case foundBody
        case paused
        case playing
        case saving
        case noCamera
        case finished
    }
    
    @Published var cachedObservations: [Pose] = []
    var trimmedObservations: [Pose] = []
    var trimmedObservationQueue: [Pose] = []
    
    var missed = 0
    var good = 0
    var perfect = 0
    var hasGood = false
    
    @Published var score: Int = 0
    @Published var moveState: MoveState = .none
    @Published var gameState: GameState = .lookingForBody
    
    @Published var currentTime: TimeInterval = 0
    
    @Published var absoluteDistance: Double = 0
    @Published var weightedDistance: Double = 0
    
    var myScore: Score {
        return .init(rawScore: score, perfects: perfect, goods: good, missed: missed)
    }
    private var cancellables: Set<AnyCancellable> = []
    var multiPlayerSession: SessionViewModel?
    
    init(track: Track, session: SessionViewModel?) {
        self.multiPlayerSession = session
        switch track.type {
        case .builtIn:
            cachedObservations = (try? JSONDecoder().decode([Pose].self, from: UserDefaults.standard.data(forKey: track.userDefaultsKey) ?? .init())) ?? []
            trimmedObservations = (try? JSONDecoder().decode([Pose].self, from: UserDefaults.standard.data(forKey: track.userDefaultsKey + "-trimmed") ?? .init())) ?? []
            
            
            if cachedObservations.isEmpty {
                cachedObservations = (try? JSONDecoder().decode([Pose].self, from: readLocalFile(forName: track.fileName) ?? .init())) ?? []
                trimmedObservations = (try? JSONDecoder().decode([Pose].self, from: readLocalFile(forName: "\(track.fileName)-trimmed") ?? .init())) ?? []
            }
        case .musicLibrary:
            cachedObservations = (try? JSONDecoder().decode([Pose].self, from: UserDefaults.standard.data(forKey: track.userDefaultsKey) ?? .init())) ?? []
            trimmedObservations = (try? JSONDecoder().decode([Pose].self, from: UserDefaults.standard.data(forKey: track.userDefaultsKey + "-trimmed") ?? .init())) ?? []
        }
        trimmedObservationQueue = trimmedObservations
        
        session?.$state.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] val in
            guard let self = self else { return }
            switch val {
            case .playing:
                self.gameState = .playing
            case .paused:
                self.gameState = .paused
            case .lookingForBody:
                self.gameState = .lookingForBody
            default:
                break
            }
        })
        .store(in: &cancellables)
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func perFrameUpdate(observation: Pose?) {
        while currentTime - 0.2 > trimmedObservationQueue.first?.time ?? .infinity  {
            trimmedObservationQueue.removeFirst()
            if hasGood {
                good += 1
                score += 3
                multiPlayerSession?.mpSession.sendToAllPeers("score:\(score)".data(using: .utf8) ?? .init(), reliably: true)
                multiPlayerSession?.mpSession.sendToAllPeers("good:".data(using: .utf8) ?? .init(), reliably: true)

                moveState = .good
            } else {
                missed += 1
                moveState = .missed
                multiPlayerSession?.mpSession.sendToAllPeers("missed:".data(using: .utf8) ?? .init(), reliably: true)

            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.moveState = .none
            }
            hasGood = false
        }
        guard let observation = observation, let compareMove = trimmedObservationQueue.first, abs(compareMove.time - observation.time) <= 0.2 else { return }
        let distance = observation.weightedDistance(to: compareMove)
        
        weightedDistance = (distance*100).rounded()/100.0
        absoluteDistance = (observation.absoluteDistance(to: compareMove)*100).rounded()/100.0
        
        if distance < 7 {
            trimmedObservationQueue.removeFirst()
            perfect += 1
            score += 5
            multiPlayerSession?.mpSession.sendToAllPeers("score:\(score)".data(using: .utf8) ?? .init(), reliably: true)
            multiPlayerSession?.mpSession.sendToAllPeers("perfect:".data(using: .utf8) ?? .init(), reliably: true)

            moveState = .perfect
            hasGood = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.moveState = .none
            }
        } else if distance < 13 {
            hasGood = true
        }
    }
}

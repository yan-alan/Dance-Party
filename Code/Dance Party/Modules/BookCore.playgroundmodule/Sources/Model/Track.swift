//
//  Track.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import UIKit
import MediaPlayer

public struct Track: Identifiable, Equatable {
    enum Source {
        case builtIn
        case musicLibrary
    }
    static let standard = Track(fileName: "ymca", trackName: "YMCA", author: "The Best")
    public var id = UUID()
    var userDefaultsKey: String {
        switch type {
        case .builtIn:
            return fileName
        case .musicLibrary:
            return "\(trackName.hash)"
        }
    }
    var fileName: String
    var trackName: String
    var author: String
    var url: MPMediaItem?
    var image: UIImage?
    var type: Source {
        url == nil ? .builtIn : .musicLibrary
    }
    
    var hasRecord: Bool {
        switch type {
        case .builtIn:
            return true
        case .musicLibrary:
            return UserDefaults.standard.data(forKey: "\(trackName.hash)") != nil
        }
    }
    
    lazy var highScores: [Int] = UserDefaults.standard.array(forKey: userDefaultsKey + "-leaderboard") as? [Int] ?? [] {
        didSet {
            UserDefaults.standard.setValue(highScores, forKey: userDefaultsKey + "-leaderboard")
        }
    }
}

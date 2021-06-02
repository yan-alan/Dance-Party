//
//  TrackDetailedView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import SwiftUI

public struct TrackDetailedView: View {
    var track: Track
    weak var viewModel: TrackDetailedViewModel?
    public var body: some View {
        VStack {
            Text(track.trackName)
                .font(.system(size: 30, weight: .bold))
            
            Spacer()
            
            Button("Play") {
                viewModel?.state = .play(track: track)
            }
        }
        .padding()
    }
}

struct TrackDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        TrackDetailedView(track: .standard)
    }
}

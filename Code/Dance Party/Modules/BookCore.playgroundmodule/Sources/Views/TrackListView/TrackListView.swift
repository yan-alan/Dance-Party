//
//  TrackListView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import SwiftUI

public struct TrackListView: View {
    var showsCancel = false
    @ObservedObject var viewModel: TrackListViewModel
    @State var selectedTrack: Track?
    public var body: some View {
        ScrollView(.vertical) {
            HeaderView(showsCancel: showsCancel, title: "Choose Song", action: {
                viewModel.state = .goBack
            })
            .padding(.horizontal)
            .padding(.vertical, 3)
            .padding(.top, 10)
            .padding(.bottom, viewModel.multiPlayer ? 12 : 0)
            LazyVStack(spacing: 10) {
                if !viewModel.multiPlayer {
                    Button("Choose From Library...") {
                        viewModel.state = .openLibrary
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .shadow(radius: 5)
                    .padding(.vertical, 5)
                }
                
                ForEach(viewModel.mediaItems) { track in
                    trackCell(for: track)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(hex: 0xE8E8E8).edgesIgnoringSafeArea(.all))
    }
    
    func trackCell(for track: Track) -> some View {
        var track = track
        return VStack {
            HStack {
                if track.image != nil {
                    Image(uiImage: track.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(radius: 5)
                } else {
                    Image(track.fileName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(radius: 5)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(track.trackName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text(track.author)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                Spacer()
            }
            
            HStack {
                Text("Leaderboard")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 3)
            
            ScrollView(.horizontal) {
                HStack {
                    if track.highScores.isEmpty {
                        Text("No Scores")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundColor(Color.black.opacity(0.3)))
                    }
                    ForEach(track.highScores, id: \.self) { score in
                        Text("\(score)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundColor(Color.black.opacity(0.3)))
                    }
                }
            }
            .frame(height: 60)
            
            HStack {
                if !viewModel.multiPlayer {
                    createButton(with: "Record", with: {
                        viewModel.state = .record(track: track)
                    })
                    createButton(with: "Practice", with: {
                        viewModel.state = .learn(track: track)
                    })
                    .disabled(!track.hasRecord)
                    .opacity(track.hasRecord ? 1 : 0.5)
                }
                
                Spacer()
                createButton(with: "Play", with: {
                    viewModel.state = .play(track: track)
                })
                .disabled(!track.hasRecord)
                .opacity(track.hasRecord ? 1 : 0.5)
            }
            .padding(.top)
        }
        .padding()
        .background(
            (track.image == nil ? Image(track.fileName).resizable().aspectRatio(contentMode: .fill).padding(.horizontal, -40).padding(.vertical, -20).blur(radius: 30) : Image(uiImage: track.image!).resizable().aspectRatio(contentMode: .fill).padding(.horizontal, -40).padding(.vertical, -20).blur(radius: 30))
                .overlay(Color.black.opacity(0.2))
        )
        .contentShape(Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .onTapGesture {
            if selectedTrack == track {
                selectedTrack = nil
            } else {
                selectedTrack = track
            }
        }
        .shadow(color: Color.black.opacity(0.4), radius: 7, x: 0, y: 5)
        .padding(.bottom, selectedTrack == track || track ==  viewModel.mediaItems.last ? 0 : -180)
        .animation(.easeInOut(duration: 0.2))
    }
    func createButton(with title: String, with action: (() -> ())? = nil) -> some View {
        Button(title) {
            action?()
        }
        .font(.system(size: 16, weight: .bold))
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.white, lineWidth: 2)
        )
        .foregroundColor(.black)
    }
}
//
//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView(state: Binding(.goBack))
//    }
//}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

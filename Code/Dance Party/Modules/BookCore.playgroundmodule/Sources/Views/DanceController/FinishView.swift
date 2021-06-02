//
//  FinishView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-11.
//

import SwiftUI

struct Score {
    var rawScore: Int
    
    var perfects: Int
    var goods: Int
    var missed: Int
    
    var total: Int {
        return perfects + goods + missed
    }
}
struct FinishView: View {
    var track: Track
    var myScore: Score
    var opponentScore: Score?
    var doneAction: () -> ()
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            
            VStack {
                HStack {
                    (track.type == .builtIn ? Image(track.fileName) : Image(uiImage: track.image!))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    Text(track.trackName)
                        .font(.system(size: 35, weight: .semibold))
                        .padding()
                }
                
                HStack {
                scoreView(isMine: true)
                scoreView(isMine: false)
                }
                Button("Done") {
                    doneAction()
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 10)
                
            }
            .frame(minWidth: 300)
            .padding(30)
            .padding(.bottom, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
            .padding()
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
    }
    
    func scoreView(isMine: Bool) -> some View {
        if isMine == false && opponentScore == nil { return AnyView(EmptyView()) }
        return AnyView(VStack {
            Text("\(isMine ? "Your" : "Their") Score Is")
                .font(.system(size: 20, weight: .regular))
                .padding()
            
            Text("\((isMine ? myScore : opponentScore)!.rawScore)")
                .font(.system(size: 60, weight: .bold))
            
            VStack(alignment: .leading, spacing: 10) {
                (Text("Perfects: ").bold() + Text("\((isMine ? myScore : opponentScore)!.perfects)"))
                    .font(.system(size: 20))
                
                (Text("Goods: ").bold() + Text("\((isMine ? myScore : opponentScore)!.goods)"))
                    .font(.system(size: 20))
                
                (Text("Missed: ").bold() + Text("\((isMine ? myScore : opponentScore)!.missed)"))
                    .font(.system(size: 20))
            }
            .padding()
        })
    }
}

struct FinishView_Previews: PreviewProvider {
    static var previews: some View {
        FinishView(track: .init(fileName: "ymca", trackName: "YMCA", author: "s"), myScore: .init(rawScore: 230, perfects: 10, goods: 30, missed: 40), opponentScore: .init(rawScore: 300, perfects: 30, goods: 20, missed: 40), doneAction: {})
    }
}

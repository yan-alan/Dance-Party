//
//  FindSessionView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-10.
//

import SwiftUI

public struct FindSessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var scale: CGFloat = 0.8
    @State var dots = ""
    public var body: some View {
        VStack {
                switch viewModel.state {
                case .pickingSong:
                    EmptyView()
                default:
                    HeaderView(showsCancel: true, title: "", action: {
                        viewModel.state = .ended
                    })
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                    .padding(.top, 10)
                    
                    Spacer()
                    AppleView()
                        .scaleEffect(scale)
                        .padding(-170 * (1-scale))
                        .padding(.bottom, 10)
                }
                
                switch viewModel.state {
                case .hosting:
                    Text("Waiting For People To Join\(dots)")
                        .font(.system(size: 30, weight: .bold))

                case .searching:
                    Text("Looking For Host\(dots)")
                        .font(.system(size: 30, weight: .bold))

                case .pickingSong:
                    TrackListView(showsCancel: true, viewModel: viewModel.trackViewModel)
                case .waitingToPickSong:
                    Text("Host Picking Song\(dots)")
                        .font(.system(size: 30, weight: .bold))

                case .ended:
                    Text("Ended")
                        .font(.system(size: 30, weight: .bold))
                default:
                    Text("")
                }
                
            Spacer()


        }
        .background(Color(hex: 0xE8E8E8).edgesIgnoringSafeArea(.all))
        .onReceive(timer) { input in
            if dots == "..." {
                dots = ""
            } else {
                dots += "."
            }
        }
    }
}

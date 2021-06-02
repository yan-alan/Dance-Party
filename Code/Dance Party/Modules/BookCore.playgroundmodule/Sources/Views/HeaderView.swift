//
//  HeaderView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import SwiftUI

struct HeaderView: View {
    var showsCancel: Bool
    var title: String
    var action: (() -> ())?
    var body: some View {
        HStack {
            if showsCancel {
                Text("Cancel")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                    .onTapGesture {
                        action?()
                    }
            } else {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .onTapGesture {
                        action?()
                    }
            }
            Spacer()
            Text(title)
                .font(.system(size: 30, weight: .bold))

            Spacer()
            Rectangle()
                .frame(width: 22, height: 22)
                .foregroundColor(.clear)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(showsCancel: false, title: "Song")
    }
}

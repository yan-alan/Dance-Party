//
//  IntroductionView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import SwiftUI
import Vision

public struct AppleView: View {
    public var body: some View {
        ZStack {
            BodySwiftUIView(pose: .init(time: 0, storedPoints: Helper.topRight), color: UIColor(hex: 0x5EB444))
                .frame(width: 360, height: 500)
                .rotationEffect(.degrees(-93))
                .offset(x: 214, y: -460 + 275)
            
            BodySwiftUIView(pose: .init(time: 0, storedPoints: Helper.topApple), color: UIColor(hex: 0xF3B125))
                .frame(width: 360, height: 500)
                .rotationEffect(.degrees(-180))
                .offset(x: 30, y: -670 + 275)
            
            BodySwiftUIView(pose: .init(time: 0, storedPoints: Helper.topLeft), color: UIColor(hex: 0xEF7D1E))
                .frame(width: 350, height: 500)
                .rotationEffect(.degrees(130))
                .offset(x: -200, y: -640 + 275)
            
            BodySwiftUIView(pose: .init(time: 0, storedPoints: Helper.leftApple), color: UIColor(hex: 0xD9383C))
                .frame(width: 350, height: 500)
                .rotationEffect(.degrees(65))
                .offset(x: -250, y: -360 + 275)
            
            BodySwiftUIView(pose: .init(time: 0, storedPoints: Helper.bottomApple), color: UIColor(hex: 0x913A91))
                .rotationEffect(.degrees(-3))
                .offset(x: -10,y: -185 + 275)
                .frame(width: 360, height: 500)
            
            
            BodySwiftUIView(pose: .init(time: 0, storedPoints: Helper.middleRight), color: UIColor(hex: 0x0197D5))
                .frame(width: 330, height: 500)
                .rotationEffect(.degrees(-45))
                .offset(x: 128, y: -270 + 275)
            
            
            BodySwiftUIView(pose: .init(time: 0, storedPoints: Helper.leaf), color: UIColor(hex: 0xE8E8E8))
                .frame(width: 240, height: 300)
                .rotationEffect(.degrees(-145))
                .offset(x: 130, y: -685 + 275)
            
        }
        .scaleEffect(0.4)
        .padding(.bottom, -120)
        .padding(.top, 20)
        .padding(.horizontal, 30)
    }
}
public struct IntroductionView: View {
    weak var viewModel: IntroductionViewModel?
    @State var scale: CGFloat = 0.6
    public var body: some View {
        VStack {
            Spacer()
            AppleView()
                .scaleEffect(scale)
                .padding(-170 * (1-scale))
            
            
            
            Text("Dance Party").bold()
                .font(.system(size: 35, weight: .bold))
            (Text("WWDC 2021 - ") + Text("Alan Yan"))
                .font(.system(size: 18, design: .rounded))
                .padding(.bottom, 15)
                .padding(.top, 0)
            
            Button("Single Player") {
                viewModel?.state = .singlePlayer
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .bold))
            .padding(.vertical, 12)
            .padding(.horizontal, 13)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(radius: 3, y: 2)
            
            HStack(spacing: 5) {
                Rectangle()
                    .frame(width: 15, height: 3)
                    .cornerRadius(1.5)
                Text("OR")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical, 5)
                Rectangle()
                    .frame(width: 15, height: 3)
                    .cornerRadius(1.5)
            }
            
            HStack(spacing: 10) {
                Button("Join") {
                    viewModel?.state = .joining
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(.vertical, 12)
                .padding(.horizontal, 13)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 3, y: 2)
                
                Button("Host") {
                    viewModel?.state = .hosting
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(.vertical, 12)
                .padding(.horizontal, 13)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 3, y: 2)
                
            }
            Rectangle()
                .frame(width: 15, height: 0)
                .cornerRadius(1.5)
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity )
        .background(Color(hex: 0xE8E8E8).edgesIgnoringSafeArea(.all))
    }
}

public struct IntroductionView_Previews: PreviewProvider {
    public static var previews: some View {
        IntroductionView()
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
}

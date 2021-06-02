//
//  LineView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-01.
//

import SwiftUI
import UIKit
import Vision

public struct BodySwiftUIView: UIViewRepresentable {
    var pose: Pose
    var color: UIColor = .init(hex: 0xE8E8E8)
    public func makeUIView(context: Context) -> CustomBodyView {
        CustomBodyView(observation: pose, color: color)
    }

    public func updateUIView(_ uiView: CustomBodyView, context: Context) {
        uiView.observation = pose
    }
}

public class CustomBodyView: UIView {
    private var thickness: CGFloat = 5
    var color: UIColor = .white
    var observation: Pose? {
        didSet {
            if observation?.hasFullSkeleton ?? false {
                setNeedsDisplay()
            }
        }
    }

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    convenience init(observation: Pose? = nil, color: UIColor) {
        self.init()
        self.observation = observation
        self.color = color
        backgroundColor = .clear
//        setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let observation = observation else { return }
        let scaledPoints = observation.normalizedPoints.mapValues({ s(rect, $0) })
    
        if let context = UIGraphicsGetCurrentContext(), observation.hasFullSkeleton {
            thickness = min(rect.width/18, rect.height/18)
            context.setFillColor(color.cgColor)
            context.setLineWidth(3)
            context.setShadow(offset: CGSize(width: 0, height: 2), blur: thickness*2, color: UIColor.black.withAlphaComponent(0.4).cgColor)
            context.move(to: scaledPoints[.leftShoulder]!)
            context.addLine(to: scaledPoints[.leftHip]!)
            context.addLine(to: scaledPoints[.rightHip]!)
            context.addLine(to: scaledPoints[.rightShoulder]!)
            context.addLine(to: scaledPoints[.leftShoulder]!)
            context.closePath()
            context.fillPath()
            
            context.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)
            createLimb(pointA: scaledPoints[.leftShoulder]!, pointB: scaledPoints[.leftHip]!, context: context)
            createLimb(pointA: scaledPoints[.neck]!, pointB: scaledPoints[.leftShoulder]!, context: context)
            createLimb(pointA: scaledPoints[.neck]!, pointB: scaledPoints[.rightShoulder]!, context: context)
            createLimb(pointA: scaledPoints[.rightShoulder]!, pointB: scaledPoints[.rightHip]!, context: context)
            createLimb(pointA: scaledPoints[.leftShoulder]!, pointB: scaledPoints[.leftHip]!, context: context)
            createLimb(pointA: scaledPoints[.leftHip]!, pointB: scaledPoints[.rightHip]!, context: context)
            
            context.setShadow(offset: CGSize(width: 0, height: 0), blur: 10, color: UIColor.black.withAlphaComponent(0.075).cgColor)
            context.addEllipse(in: CGRect(x: scaledPoints[.nose]!.x - thickness * 2, y: scaledPoints[.nose]!.y - thickness * 4, width: thickness * 4.0, height: thickness * 4.0))
            context.closePath()
            context.fillPath()
            
            context.setShadow(offset: CGSize(width: 0, height: thickness * 0.6), blur: thickness * 0.6, color: UIColor.black.withAlphaComponent(0.1).cgColor)
            createLeftThicker(pointA: scaledPoints[.leftHip]!, pointB: scaledPoints[.leftKnee]!, context: context)
            context.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)

            createLimb(pointA: scaledPoints[.leftKnee]!, pointB: scaledPoints[.leftAnkle]!, context: context)
            context.setShadow(offset: CGSize(width: 0, height: thickness * 0.6), blur: thickness * 0.6, color: UIColor.black.withAlphaComponent(0.1).cgColor)
            createRightThicker(pointA: scaledPoints[.rightHip]!, pointB: scaledPoints[.rightKnee]!, context: context)
            context.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)
            createLimb(pointA: scaledPoints[.rightKnee]!, pointB: scaledPoints[.rightAnkle]!, context: context)
            
            context.setShadow(offset: CGSize(width: -thickness/2, height: 0), blur: thickness * 0.5, color: UIColor.black.withAlphaComponent(0.08).cgColor)
            createLimb(pointA: scaledPoints[.leftShoulder]!, pointB: scaledPoints[.leftElbow]!, context: context)
            context.setShadow(offset: CGSize(width: -thickness/2, height: 3), blur: thickness/2, color: UIColor.black.withAlphaComponent(0.05).cgColor)
            createLimb(pointA: scaledPoints[.leftElbow]!, pointB: scaledPoints[.leftWrist]!, context: context)
            
            context.setShadow(offset: CGSize(width: thickness/2, height: 0), blur: thickness * 0.5, color: UIColor.black.withAlphaComponent(0.08).cgColor)
            createLimb(pointA: scaledPoints[.rightShoulder]!, pointB: scaledPoints[.rightElbow]!, context: context)
            context.setShadow(offset: CGSize(width: thickness/2, height: 3), blur: thickness/2, color: UIColor.black.withAlphaComponent(0.05).cgColor)
            createLimb(pointA: scaledPoints[.rightElbow]!, pointB: scaledPoints[.rightWrist]!, context: context)
        }
    }
    
    private func createLimb(pointA: CGPoint, pointB: CGPoint,context: CGContext, thickerThigh: Bool = false) {
        let slant = pointB - pointA
        let normalizedLine = (pointB - pointA).normalize()
        let tempX = slant.x
        let perpendicularLine = CGPoint(x: -slant.y, y:tempX).normalize().scaled(by: thickness)
        
        let startingPoint = perpendicularLine + pointA
        context.move(to: startingPoint)
        context.addLine(to: perpendicularLine + pointB)
        context.addCurve(to: pointB - perpendicularLine, control1: perpendicularLine + pointB + normalizedLine.scaled(by: thickness * 1.5), control2: pointB - perpendicularLine + normalizedLine.scaled(by: thickness * 1.5))
        context.addLine(to: pointA - perpendicularLine.scaled(by: thickerThigh ? 1.5 : 1))
        context.addCurve(to: perpendicularLine + pointA, control1: pointA - perpendicularLine.scaled(by: thickerThigh ? 1.5 : 1) - normalizedLine.scaled(by: thickness * 1.5), control2: perpendicularLine + pointA - normalizedLine.scaled(by: thickness * 1.5))
        context.closePath()
        context.fillPath()
    }
    
    private func createLeftThicker(pointA: CGPoint, pointB: CGPoint,context: CGContext) {
        let slant = pointB - pointA
        let normalizedLine = (pointB - pointA).normalize()
        let tempX = slant.x
        let newPoint = CGPoint(x: -slant.y, y:tempX).normalize().scaled(by: thickness)
        
        let startingPoint = newPoint + pointA
        context.move(to: startingPoint)
        context.addLine(to: newPoint + pointB)
        context.addCurve(to: pointB - newPoint, control1: newPoint + pointB + normalizedLine.scaled(by: thickness * 1.5), control2: pointB - newPoint + normalizedLine.scaled(by: thickness * 1.5))
        context.addLine(to: pointA - newPoint.scaled(by: 2))
        context.addCurve(to: newPoint + pointA, control1: pointA - newPoint.scaled(by: 2) - normalizedLine.scaled(by: thickness * 1.5), control2: newPoint + pointA - normalizedLine.scaled(by: thickness * 1.5))
        context.closePath()
        context.fillPath()
    }
    
    private func createRightThicker(pointA: CGPoint, pointB: CGPoint,context: CGContext) {
        let slant = pointB - pointA
        let normalizedLine = (pointB - pointA).normalize()
        let tempX = slant.x
        let newPoint = CGPoint(x: -slant.y, y:tempX).normalize().scaled(by: thickness)
        
        let startingPoint = newPoint.scaled(by: 2) + pointA
        context.move(to: startingPoint)
        context.addLine(to: newPoint + pointB)
        context.addCurve(to: pointB - newPoint, control1: newPoint + pointB + normalizedLine.scaled(by: thickness * 1.5), control2: pointB - newPoint + normalizedLine.scaled(by: thickness * 1.5))
        context.addLine(to: pointA - newPoint)
        context.addCurve(to: newPoint.scaled(by: 2) + pointA, control1: pointA - newPoint - normalizedLine.scaled(by: thickness * 1.5), control2: newPoint.scaled(by: 2) + pointA - normalizedLine.scaled(by: thickness * 1.5))
        context.closePath()
        context.fillPath()
    }
    
    private func s(_ rect: CGRect, _ point: CGPoint) -> CGPoint {
        var newPoint = point
        newPoint.x = rect.width * 0.8 - (point.x * rect.width * 0.8) + (rect.width * 0.1)
        newPoint.y = rect.height * 0.7 - (point.y * rect.height * 0.7) + (rect.height * 0.2)
        
        return newPoint
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class BodyView: UIView {
    private var thickness: CGFloat = 5
    var color: UIColor = .white
    var observation: Pose? {
        didSet {
            if observation?.hasFullSkeleton ?? false {
                setNeedsDisplay()
            }
        }
    }

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    convenience init(observation: Pose? = nil, color: UIColor) {
        self.init()
        self.observation = observation
        self.color = color
        backgroundColor = .clear
//        setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let observation = observation else { return }
        var scaledPoints = observation.normalizedPoints.mapValues({ s(rect, $0) })
        let humanLeft: [VNHumanBodyPoseObservation.JointName] = [.leftShoulder, .leftElbow, .leftWrist, .leftHip, .leftKnee, .leftAnkle]
        let humanRight: [VNHumanBodyPoseObservation.JointName] = [.rightShoulder, .rightElbow, .rightWrist, .rightHip, .rightKnee, .rightAnkle]

        for part in humanLeft {
            scaledPoints[part] = scaledPoints[part]! + CGPoint(x: -thickness/2, y: 0)
        }
        for part in humanRight {
            scaledPoints[part] = scaledPoints[part]! + CGPoint(x: thickness/2, y: 0)
        }
        if let context = UIGraphicsGetCurrentContext(), observation.hasFullSkeleton {
            let middleX = ((scaledPoints.values.max(by: {$0.x < $1.x})?.x ?? 0) + (scaledPoints.values.min(by: {$0.x < $1.x})?.x ?? 0))/2
            let transformX = -(middleX - rect.width/2)
            let middleY = ((scaledPoints.values.max(by: {$0.y < $1.y})?.y ?? 0) + (scaledPoints.values.min(by: {$0.y < $1.y})?.y ?? 0))/2
            let transformY = -(middleY - rect.height/2)
            scaledPoints = scaledPoints.mapValues({ CGPoint(x: $0.x + transformX, y: $0.y + transformY + (thickness * 2)) })
            thickness = min(rect.width/18, rect.height/18)
            context.setFillColor(color.cgColor)
            context.setLineWidth(3)
            context.setShadow(offset: CGSize(width: 0, height: 2), blur: thickness*2.5, color: UIColor.black.withAlphaComponent(0.8).cgColor)
            context.move(to: scaledPoints[.leftShoulder]!)
            context.addLine(to: scaledPoints[.leftHip]!)
            context.addLine(to: scaledPoints[.rightHip]!)
            context.addLine(to: scaledPoints[.rightShoulder]!)
            context.addLine(to: scaledPoints[.leftShoulder]!)
            context.closePath()
            context.fillPath()
            
            context.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)
            createLimb(pointA: scaledPoints[.leftShoulder]!, pointB: scaledPoints[.leftHip]!, context: context)
            createLimb(pointA: scaledPoints[.neck]!, pointB: scaledPoints[.leftShoulder]!, context: context)
            createLimb(pointA: scaledPoints[.neck]!, pointB: scaledPoints[.rightShoulder]!, context: context)
            createLimb(pointA: scaledPoints[.rightShoulder]!, pointB: scaledPoints[.rightHip]!, context: context)
            createLimb(pointA: scaledPoints[.leftShoulder]!, pointB: scaledPoints[.leftHip]!, context: context)
            createLimb(pointA: scaledPoints[.leftHip]!, pointB: scaledPoints[.rightHip]!, context: context)
            
            context.setShadow(offset: CGSize(width: 0, height: 2), blur: 10, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            context.addEllipse(in: CGRect(x: scaledPoints[.nose]!.x - thickness * 2.5, y: scaledPoints[.nose]!.y - thickness * 4, width: thickness * 4.5, height: thickness * 4.5))
            context.closePath()
            context.fillPath()
            
            context.setShadow(offset: CGSize(width: 0, height: thickness * 0.6), blur: thickness * 0.6, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            createLeftThicker(pointA: scaledPoints[.leftHip]!, pointB: scaledPoints[.leftKnee]!, context: context)
            createLimb(pointA: scaledPoints[.leftKnee]!, pointB: scaledPoints[.leftAnkle]!, context: context)
            
            createRightThicker(pointA: scaledPoints[.rightHip]!, pointB: scaledPoints[.rightKnee]!, context: context)
            createLimb(pointA: scaledPoints[.rightKnee]!, pointB: scaledPoints[.rightAnkle]!, context: context)
            
            context.setShadow(offset: CGSize(width: -thickness/2, height: 2), blur: thickness * 0.5, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            createLimb(pointA: scaledPoints[.leftShoulder]!, pointB: scaledPoints[.leftElbow]!, context: context)
            createLimb(pointA: scaledPoints[.leftElbow]!, pointB: scaledPoints[.leftWrist]!, context: context)
            
            context.setShadow(offset: CGSize(width: thickness/2, height: 2), blur: thickness * 0.5, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            createLimb(pointA: scaledPoints[.rightShoulder]!, pointB: scaledPoints[.rightElbow]!, context: context)
            createLimb(pointA: scaledPoints[.rightElbow]!, pointB: scaledPoints[.rightWrist]!, context: context)
        }
    }
    
    private func createLimb(pointA: CGPoint, pointB: CGPoint,context: CGContext, thickerThigh: Bool = false) {
        let slant = pointB - pointA
        let normalizedLine = (pointB - pointA).normalize()
        let tempX = slant.x
        let perpendicularLine = CGPoint(x: -slant.y, y:tempX).normalize().scaled(by: thickness)
        
        let startingPoint = perpendicularLine + pointA
        context.move(to: startingPoint)
        context.addLine(to: perpendicularLine + pointB)
        context.addCurve(to: pointB - perpendicularLine, control1: perpendicularLine + pointB + normalizedLine.scaled(by: thickness * 1.5), control2: pointB - perpendicularLine + normalizedLine.scaled(by: thickness * 1.5))
        context.addLine(to: pointA - perpendicularLine.scaled(by: thickerThigh ? 1.5 : 1))
        context.addCurve(to: perpendicularLine + pointA, control1: pointA - perpendicularLine.scaled(by: thickerThigh ? 1.5 : 1) - normalizedLine.scaled(by: thickness * 1.5), control2: perpendicularLine + pointA - normalizedLine.scaled(by: thickness * 1.5))
        context.closePath()
        context.fillPath()
    }
    
    private func createLeftThicker(pointA: CGPoint, pointB: CGPoint,context: CGContext) {
        let slant = pointB - pointA
        let normalizedLine = (pointB - pointA).normalize()
        let tempX = slant.x
        let newPoint = CGPoint(x: -slant.y, y:tempX).normalize().scaled(by: thickness)
        
        let startingPoint = newPoint + pointA
        context.move(to: startingPoint)
        context.addLine(to: newPoint + pointB)
        context.addCurve(to: pointB - newPoint, control1: newPoint + pointB + normalizedLine.scaled(by: thickness * 1.5), control2: pointB - newPoint + normalizedLine.scaled(by: thickness * 1.5))
        context.addLine(to: pointA - newPoint.scaled(by: 2))
        context.addCurve(to: newPoint + pointA, control1: pointA - newPoint.scaled(by: 2) - normalizedLine.scaled(by: thickness * 1.5), control2: newPoint + pointA - normalizedLine.scaled(by: thickness * 1.5))
        context.closePath()
        context.fillPath()
    }
    
    private func createRightThicker(pointA: CGPoint, pointB: CGPoint,context: CGContext) {
        let slant = pointB - pointA
        let normalizedLine = (pointB - pointA).normalize()
        let tempX = slant.x
        let newPoint = CGPoint(x: -slant.y, y:tempX).normalize().scaled(by: thickness)
        
        let startingPoint = newPoint.scaled(by: 2) + pointA
        context.move(to: startingPoint)
        context.addLine(to: newPoint + pointB)
        context.addCurve(to: pointB - newPoint, control1: newPoint + pointB + normalizedLine.scaled(by: thickness * 1.5), control2: pointB - newPoint + normalizedLine.scaled(by: thickness * 1.5))
        context.addLine(to: pointA - newPoint)
        context.addCurve(to: newPoint.scaled(by: 2) + pointA, control1: pointA - newPoint - normalizedLine.scaled(by: thickness * 1.5), control2: newPoint.scaled(by: 2) + pointA - normalizedLine.scaled(by: thickness * 1.5))
        context.closePath()
        context.fillPath()
    }
    
    private func s(_ rect: CGRect, _ point: CGPoint) -> CGPoint {
        var newPoint = point
        newPoint.x = rect.width * 0.8 - (point.x * rect.width * 0.8)
        newPoint.y = rect.height * 0.7 - (point.y * rect.height * 0.7)
        
        return newPoint
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
            return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
            return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
            return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
            return CGPoint(x: rhs.x * lhs, y: rhs.y * lhs)
    }
    func scaled(by amount: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * amount, y: self.y * amount)
    }
    func normalize() -> CGPoint {
        let length = pow(x*x + y*y, 0.5)
        return CGPoint(x: x/length, y: y/length)
    }
}

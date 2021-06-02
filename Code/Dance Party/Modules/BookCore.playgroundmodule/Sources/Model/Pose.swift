//
//  Observation.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-03-31.
//

import Foundation
import Vision

public struct Pose: Codable {
    static let scaleFactor: CGFloat = 10
    enum BodyPart: CaseIterable {
        case head
        case bodyArms
        case legs
        case all
        
        var weight: Double {
            switch self {
            case .all:
                return 1
            case .bodyArms:
                return 1
            case .head:
                return 0.1
            case .legs:
                return 0.5
            }
        }
    }
    
    var time: TimeInterval
    private var storedPoints: [String : CGPoint]
    private var points: [VNHumanBodyPoseObservation.JointName : CGPoint] {
        var points: [VNHumanBodyPoseObservation.JointName : CGPoint] = [:]
        storedPoints.forEach { points[VNHumanBodyPoseObservation.JointName.init(rawValue: .init(rawValue: $0))] = $1}
        return points
    }
    
    var normalizedPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] {
        return normalize(points: points)
    }
    
    var hasFullSkeleton: Bool {
        let partsRequired: [VNHumanBodyPoseObservation.JointName] = [.nose, .neck, .leftShoulder, .leftHip, .rightHip, .rightShoulder, .leftKnee, .rightKnee, .leftAnkle, .rightAnkle, .leftElbow, .rightElbow, .rightWrist, .leftWrist]
        for key in partsRequired {
            if !points.keys.contains(key) { return false }
        }
        return true
    }
    
    init(time: TimeInterval, storedPoints: [String: CGPoint]) {
        self.time = time
        self.storedPoints = storedPoints
    }
    
    func createLinearInterpolation(nextPose: Pose, currentTime: TimeInterval) -> Pose {
        let myPoints = normalizedPoints
        let nextPoints = nextPose.normalizedPoints
        
        var finalPoints: [String: CGPoint] = [:]
        for key in Set(myPoints.keys).intersection(nextPoints.keys) {
            let newPoint = ((nextPoints[key]!) - (myPoints[key]!))
            let finalPoint = newPoint * CGFloat((currentTime - self.time)/(nextPose.time - self.time)) + myPoints[key]!
            finalPoints[key.rawValue.rawValue] = finalPoint
        }
        return Pose(time: time, storedPoints: finalPoints)
    }
    
    func getPoints(for section: BodyPart) -> [VNHumanBodyPoseObservation.JointName: CGPoint] {
        var points: [VNHumanBodyPoseObservation.JointName]
        switch section {
        case .head:
            points = [.leftEye, .rightEye, .nose, .neck, .leftEar, .rightEar]
        case .bodyArms:
            points = [.leftShoulder, .rightShoulder, .leftElbow, .leftWrist, .rightElbow, .rightWrist]
        case .legs:
            points = [.leftKnee, .leftAnkle, .rightKnee, .rightAnkle, .leftHip, .rightHip]
        case .all:
            points = [.leftEye, .rightEye, .nose, .neck, .leftEar, .rightEar, .leftShoulder, .rightShoulder, .leftElbow, .leftWrist, .rightElbow, .rightWrist, .leftKnee, .leftAnkle, .rightKnee, .rightAnkle, .leftHip, .rightHip]
        }
        var subset: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for point in points {
            subset[point] = self.points[point]
        }
        return normalize(points: subset)
    }
    func weightedDistance(to observation: Pose) -> Double {
        var totalDistance: Double = 0
        let bodyParts: [BodyPart] = [.head, .bodyArms, .legs]
        for part in bodyParts {
            let myParts = getPoints(for: part)
            let otherParts = observation.getPoints(for: part)
            let joints = Set(myParts.keys).intersection(otherParts.keys)
            for joint in joints {
                totalDistance += part.weight * Double(pow((myParts[joint]!.x - otherParts[joint]!.x) * Pose.scaleFactor, 2) + pow((myParts[joint]!.y - otherParts[joint]!.y) * Pose.scaleFactor, 2))
            }
        }
        return totalDistance/Double(Pose.scaleFactor)
    }
    
    func absoluteDistance(to observation: Pose) -> Double {
        var totalDistance: Double = 0
        let bodyParts: [BodyPart] = [.head, .bodyArms, .legs]
        for part in bodyParts {
            let myParts = getPoints(for: part)
            let otherParts = observation.getPoints(for: part)
            let joints = Set(myParts.keys).intersection(otherParts.keys)
            for joint in joints {
                totalDistance += Double(abs(myParts[joint]!.x - otherParts[joint]!.x) + abs(myParts[joint]!.y - otherParts[joint]!.y))
            }
        }
        return totalDistance
    }
    
    private func normalize(points: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> [VNHumanBodyPoseObservation.JointName: CGPoint] {
        guard let minX = points.min(by: {$0.value.x < $1.value.x})?.value.x,
              let minY = points.min(by: {$0.value.y < $1.value.y})?.value.y,
              let maxX = points.max(by: {$0.value.x  < $1.value.x})?.value.x,
              let maxY = points.max(by: {$0.value.y  < $1.value.y})?.value.y else {
            return [:]
        }
        
        let maxLength: CGFloat = max((maxX - minX), (maxY - minY))
        var finalDict: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        points.forEach {
            var pointCopy = $1
            pointCopy.x -= minX
            pointCopy.y -= minY
            pointCopy.x /= maxLength
            pointCopy.y /= maxLength
            finalDict[$0] = pointCopy
        }
        return finalDict
    }
}

//
//  DanceTutorial.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-08.
//

import UIKit
import Vision

class DanceTutorialView: UIView {
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Enter Full Body Into Frame"
        return label
    }()
    
    let headLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .medium)
        label.textColor = .white
        label.text = "❌ Head"
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .medium)
        label.textColor = .white
        label.text = "❌ Body"
        return label
    }()
    let legsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .medium)
        label.textColor = .white
        label.text = "❌ Legs"
        return label
    }()
    
    let middleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 120, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "3"
        return label
    }()
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.addArrangedSubview(headLabel)
        stackView.addArrangedSubview(bodyLabel)
        stackView.addArrangedSubview(legsLabel)
        return stackView
    }()
    
    let backgroundView = UIView()
    
    lazy private var cancelView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterialDark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.setSuperview(self).addLeading(anchor: leadingAnchor, constant: 20).addWidth(withConstant: 50).addHeight(withConstant: 50).addCorners(16)
        
        let button = UIButton()
        
        button.tintColor = .red
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        button.setSuperview(effectView.contentView).addConstraints(padding: 0)

        cancelButton = button
        return effectView
    }()
    private(set) var cancelButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundView.setSuperview(self).addConstraints(padding: 0).setColor(UIColor.black.withAlphaComponent(0.3))
        cancelView.addTopSafe(constant: 30)
        topLabel.setSuperview(self).addTopSafe(constant: 25).addLeading(anchor: cancelView.trailingAnchor, constant: 25).addTrailing(constant: -25)
        stackView.setSuperview(self).addCenterX().addCenterY()
        middleLabel.setSuperview(self).addCenterX().addCenterY()

        middleLabel.alpha = 0
    }
    
    func update(with points: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        middleLabel.alpha = 0
        stackView.alpha = 1
        let keySet = points.keys
        
        if keySet.contains(.nose) {
            headLabel.text = "✔️ Head"
        } else {
            headLabel.text = "❌ Head"
        }
        
        if keySet.contains(.neck) && keySet.contains(.leftShoulder) && keySet.contains(.rightShoulder) && keySet.contains(.rightElbow) && keySet.contains(.leftElbow)
            && keySet.contains(.leftWrist) && keySet.contains(.rightWrist) {
            bodyLabel.text = "✔️ Body"
        } else {
            bodyLabel.text = "❌ Body"
        }
        
        if keySet.contains(.leftHip) && keySet.contains(.rightHip) && keySet.contains(.leftKnee) && keySet.contains(.rightKnee) && keySet.contains(.leftAnkle) && keySet.contains(.rightAnkle) {
            legsLabel.text = "✔️ Legs"
        } else {
            legsLabel.text = "❌ Legs"
        }
    }
    
    func beginCountdown(count: Int = 3) {
        
        topLabel.text = "Found Body"
        middleLabel.text = "\(count)"
        middleLabel.alpha = 1
        stackView.alpha = 0
        
        if count == 0 { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { self.beginCountdown(count: count-1) })
    }
    
    func setWaiting() {
        topLabel.text = "Found Body"
        middleLabel.text = "Waiting"
        middleLabel.alpha = 1
        stackView.alpha = 0
    }
    
    func reset() {
        if topLabel.text == "Found Body" {
        topLabel.text = "Enter Full Body Into Frame"
        }
        headLabel.text = "❌ Head"
        bodyLabel.text = "❌ Body"
        legsLabel.text = "❌ Legs"

        middleLabel.alpha = 0
        stackView.alpha = 1
    }
}


//
//  DanceOverlayView.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import UIKit

class DanceOverlayView: UIView {
    private(set) var leaderView = UIView()
    private(set) var myView = UIView()
    private(set) var opponentView = UIView()
    
    var myBodyView: BodyView = BodyView(color: .white)
    var opponentBodyView = BodyView(color: .green)
    var leaderBodyView: BodyView = BodyView(color: .orange)
    
    private(set) var pauseButton: UIButton!
    private(set) var cancelButton: UIButton!
    private(set) var speedButton: UIButton!
    private(set) var scoreLabel: UILabel!
    private(set) var switchView: UISwitch!
    private(set) var borderView = UIView()
    private(set) var moveLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .monospacedSystemFont(ofSize: 100, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private(set) var absDistLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .monospacedSystemFont(ofSize: 100, weight: .bold)
        label.textColor = .cyan
        label.textAlignment = .center
        return label
    }()
    private(set) var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .monospacedSystemFont(ofSize: 100, weight: .bold)
        label.textColor = .cyan
        label.textAlignment = .center
        return label
    }()
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
    
    lazy private var pauseView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterialDark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.setSuperview(self).addLeading(anchor: cancelView.trailingAnchor, constant: 15).addWidth(withConstant: 50).addHeight(withConstant: 50).addCorners(16)
        
        let button = UIButton()
        
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.imageEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        button.setSuperview(effectView.contentView).addConstraints(padding: 0)
        
        pauseButton = button
        return effectView
    }()
    
    lazy private var speedView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterialDark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.setSuperview(self).addLeading(anchor: pauseView.trailingAnchor, constant: 15).addWidth(withConstant: 70).addHeight(withConstant: 50).addCorners(16)
        
        let button = UIButton()
        
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.titleLabel?.textAlignment = .center
        button.setTitle("0.5x", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.imageEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        button.setSuperview(effectView.contentView).addConstraints(padding: 0)
        
        speedButton = button
        return effectView
    }()
    
    lazy var scoreView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterialDark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.setSuperview(self).addCenterX(anchor: centerXAnchor).addCorners(16)
        let label = UILabel()
        label.font = .systemFont(ofSize: 45, weight: .bold)
        label.textColor = .white
        label.text = "0"
        label.setSuperview(effectView.contentView).addLeading(constant: 12).addTrailing(constant: -12).addTop(constant: 8).addBottom(constant: -8)
        
        scoreLabel = label
        return effectView
    }()
    
    lazy var cameraBlurVisualEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterialDark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.setSuperview(self).addTrailing(constant: -20).addCorners(16)
        let switchView = UISwitch()
        switchView.isOn = true
        self.switchView = switchView
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.setSuperview(effectView.contentView).addCenterY().addLeading(constant: 12).addHeight(withConstant: 25).addWidth(withConstant: 30)
        switchView.setSuperview(effectView.contentView).addLeading(anchor: imageView.trailingAnchor, constant: 12).addCenterY().addTrailing(constant: -12).addTop(constant: 10).addBottom(constant: -10)
        return effectView
    }()
    
    var cameraBlur: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private var mode: DanceController.Mode
    override class var requiresConstraintBasedLayout: Bool {
         return true
    }
    
    convenience init(mode: DanceController.Mode) {
        self.init(frame: .zero)
        self.mode = mode
        setupView()
        
    }
    override init(frame: CGRect) {
        self.mode = .play(track: .standard)
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        cameraBlur.setSuperview(self).addConstraints(padding: 0)

        switch mode {
        case .record:
            myView.setSuperview(self).addTopSafe(constant: 20).addLeading().addTrailing().addBottom(constant: -20)
            myBodyView.setSuperview(myView).addCenterX().addTop().addBottom().addLeading().addTrailing()
            myBodyView.widthAnchor.constraint(lessThanOrEqualTo: myBodyView.heightAnchor, multiplier: 0.8).isActive = true
            cameraBlurVisualEffectView.addTopSafe(constant: 30)
            cancelView.addCenterY(anchor: cameraBlurVisualEffectView.centerYAnchor)
            pauseView.addCenterY(anchor: cameraBlurVisualEffectView.centerYAnchor)
        case .play, .learn:
            opponentView.alpha = 0.7
            opponentView.setSuperview(self).addTopSafe(constant: 60).addCenterX(constant: -50).addBottom(constant: -490)
            opponentBodyView.setSuperview(opponentView).addCenterX().addTop().addBottom().addLeading().addTrailing()
            opponentBodyView.userDefinedConstraintDict["leading"]?.priority = .defaultLow
            opponentBodyView.userDefinedConstraintDict["trailing"]?.priority = .defaultLow
            opponentBodyView.widthAnchor.constraint(lessThanOrEqualTo: opponentView.heightAnchor, multiplier: 0.8).isActive = true
            
            leaderView.setSuperview(self).addTopSafe(constant: 20).addTrailing().addLeading(anchor: centerXAnchor).addBottom(constant: -450)
            opponentView.addWidth(anchor: leaderView.widthAnchor)
            leaderBodyView.setSuperview(leaderView).addCenterX().addTop().addBottom().addLeading().addTrailing()
            leaderBodyView.userDefinedConstraintDict["leading"]?.priority = .defaultLow
            leaderBodyView.userDefinedConstraintDict["trailing"]?.priority = .defaultLow
            leaderBodyView.widthAnchor.constraint(lessThanOrEqualTo: leaderBodyView.heightAnchor, multiplier: 0.8).isActive = true
            
            myView.setSuperview(self).addTopSafe(constant: 20).addLeading().addTrailing(anchor: centerXAnchor).addBottom(constant: -450)
            myBodyView.setSuperview(myView).addCenterX().addTop().addBottom().addLeading().addTrailing()
            myBodyView.userDefinedConstraintDict["leading"]?.priority = .defaultLow
            myBodyView.userDefinedConstraintDict["trailing"]?.priority = .defaultLow
            myBodyView.widthAnchor.constraint(lessThanOrEqualTo: myBodyView.heightAnchor, multiplier: 0.8).isActive = true
            borderView.setSuperview(self).addConstraints(padding: 0)
            moveLabel.setSuperview(borderView).addLeading().addTrailing().addCenterX().addCenterY()
            cameraBlurVisualEffectView.addTopSafe(constant: 30)
            cancelView.addCenterY(anchor: cameraBlurVisualEffectView.centerYAnchor)
            pauseView.addCenterY(anchor: cameraBlurVisualEffectView.centerYAnchor)
            scoreView.addCenterY(anchor: cameraBlurVisualEffectView.centerYAnchor)
            
            if case .learn = mode {
                speedView.addCenterY(anchor: cameraBlurVisualEffectView.centerYAnchor)
            }
            
            cameraBlurVisualEffectView.setColor(.clear)
                        
//            absDistLabel.setSuperview(self).addBottom(anchor: centerYAnchor, constant: -10).addCenterX()
//            distanceLabel.setSuperview(self).addTop(anchor: centerYAnchor, constant: 10).addCenterX()
        }
        switchView.addTarget(self, action: #selector(switchClicked), for: .valueChanged)
    }
    
    @objc private func switchClicked(view: UISwitch) {
        cameraBlur.alpha = view.isOn ? 1 : 0
    }
}

//
//  RootController.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import UIKit

public class RootController: UINavigationController {
    
    convenience public init() {
        self.init(rootViewController: IntroductionViewController())
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.isEnabled = false
    }
    
    public override func viewDidLoad() {
        overlayView.backgroundColor = .black
        self.view.addSubview(overlayView)
        let label = UILabel()
        label.text = "Please Fullscreen"
        label.font = .systemFont(ofSize: 55, weight: .bold)
        label.textColor = .white
        label.setSuperview(overlayView).addCenterY().addCenterX()
        
        let button = UIButton()
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Dismiss", for: .normal)
        
        button.setSuperview(overlayView).addBottom(anchor: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).addWidth(withConstant: 180).addHeight(withConstant: 45).addCenterX()
        button.backgroundColor = .systemBlue
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(hideOverlay), for: .touchUpInside)
    }
    override private init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var overlayView = UIView()
    
    public override func viewDidLayoutSubviews() {
        overlayView.frame = self.view.frame
        overlayView.alpha = (self.view.frame.width != UIScreen.main.bounds.width || self.view.frame.height != UIScreen.main.bounds.height) ? 1 : 0
    }
    
    @objc private func hideOverlay() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 0
        } completion: { _ in
            self.overlayView.isHidden = true
        }
    }
}

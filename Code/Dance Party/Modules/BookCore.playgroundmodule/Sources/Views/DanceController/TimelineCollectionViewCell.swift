//
//  TimelineCollectionViewCell.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-04.
//

import UIKit

public class TimelineCollectionViewCell: UICollectionViewCell {
    var observation: Pose? {
        didSet {
            guard let observation = observation else { return }
            subviews.forEach({$0.removeFromSuperview()})
            let body = BodyView(observation: observation, color: .orange)
            body.translatesAutoresizingMaskIntoConstraints = false
            addSubview(body)
            NSLayoutConstraint.activate([
                body.leadingAnchor.constraint(equalTo: leadingAnchor),
                body.topAnchor.constraint(equalTo: topAnchor),
                body.trailingAnchor.constraint(equalTo: trailingAnchor),
                body.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

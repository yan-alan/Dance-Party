//
//  TimelineViewController.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-04.
//

import UIKit
import Combine
public class TimelineViewController: UIViewController {
    weak var viewModel: TrackViewModel!
    private var cancellables: Set<AnyCancellable> = []
    public override var shouldAutorotate: Bool {
        return false
    }
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isUserInteractionEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.allowsSelection = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SpacerCell")
        collection.register(TimelineCollectionViewCell.self, forCellWithReuseIdentifier: "TimelineCollectionViewCell")
        return collection
    }()
    private(set) var borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .clear
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    public override func viewDidLoad() {
        view.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        view.addSubview(borderView)
        borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        borderView.widthAnchor.constraint(equalToConstant: 266).isActive = true
        borderView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        borderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        viewModel.$currentTime.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] val in
            guard let self = self, let firstPose = self.viewModel.trimmedObservations.first else { return }
            let finalTime = max(0, self.viewModel.currentTime - firstPose.time)
            self.collectionView.setContentOffset(CGPoint(x: finalTime/0.2 * 266, y: 0), animated: false)
        }).store(in: &cancellables)
    }
}

extension TimelineViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.trimmedObservations.count * 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item % 2 == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCollectionViewCell", for: indexPath) as! TimelineCollectionViewCell
            cell.observation = viewModel.trimmedObservations[indexPath.item/2]
            cell.backgroundColor = .clear
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpacerCell", for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //each 200 width is 0.2 seconds
        if indexPath.item % 2 == 0 {
            return CGSize(width: 266, height: 400)
        } else {
            let itemIndex = indexPath.item/2
            guard itemIndex < viewModel.trimmedObservations.count - 1 else { return .zero }
            let width = (viewModel.trimmedObservations[itemIndex+1].time - viewModel.trimmedObservations[itemIndex].time - 0.2)/0.2
            return CGSize(width: 266 * width, height: 400)
        }
    }
    
    
}

//
//
//  CardsView
//
//  Created by Serhii Kharauzov on 2/10/19.
//  Copyright © 2019 Serhii Kharauzov. All rights reserved.
//

import Foundation
import UIKit

class CardsViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cardsView: CardsView!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: Properties
    
    var data = [CardCellDisplayable]()
    var displayData = [CardCellDisplayable]()
    lazy var cardImageViewHeight: CGFloat = cardsView.frame.height * 0.45 //  45% is cell.imageView height constraint's multiplier
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setCardsViewLayout()
        if let firstItem = data.first {
            displayData.append(firstItem)
        }
        cardsView.reloadData()
        cardsView.scrollToItemAtIndex(0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleViewControllerPresentation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        handleViewControllerDismiss()
    }
    
    // MARK: Methods
    
    func setCardsViewLayout() {
        view.layoutIfNeeded()
        cardsView.setLayout()
    }
    
    func handleViewControllerPresentation() {
        if displayData.count == data.count { return }
        var indexPaths = [IndexPath]()
        for (index, _) in data.enumerated() {
            if index != 0 {
                indexPaths.append(IndexPath(row: index, section: 0))
                displayData.append(data[index])
            }
        }
        cardsView.insertItems(at: indexPaths)
    }
    
    func handleViewControllerDismiss() {
        let amountOfCells = cardsView.numberOfItems(inSection: 0)
        var indexPathesToDelete = [IndexPath]()
        for index in (1 ..< amountOfCells).reversed() {
            indexPathesToDelete.append(IndexPath(row: index, section: 0))
            displayData.remove(at: index)
        }
        cardsView.deleteItems(at: indexPathesToDelete)
    }
    
    func dismissViewManually() {
    }
    
    func presentViewController(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: StoryboardInitialisable Protocol

extension CardsViewController {
    static func instantiateViewController() -> CardsViewController {
        return Storyboard.main.viewController(CardsViewController.self)
    }
}

// MARK: CollectionView DataSource

extension CardsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.reuseIdentifier, for: indexPath) as! CardCollectionViewCell
        cell.setContent(data: displayData[indexPath.row])
        cell.delegate = self
        cell.actionResponder = self
        return cell
    }
}

extension CardsViewController: SwipingCollectionViewCellDelegate {
    func cellSwipedUp(_ cell: SwipingCollectionViewCell) {
        if let interactiveTransitionableViewController = presentingViewController as? InteractiveTransitionableViewController,
            let interactiveDismissTransition = interactiveTransitionableViewController.interactiveDismissTransition as? MiniToLargeViewInteractiveAnimator {
            interactiveDismissTransition.isEnabled = false
        }
    }
    
    func cellReturnedToInitialState(_ cell: SwipingCollectionViewCell) {
        if let interactiveTransitionableViewController = presentingViewController as? InteractiveTransitionableViewController,
            let interactiveDismissTransition = interactiveTransitionableViewController.interactiveDismissTransition as? MiniToLargeViewInteractiveAnimator {
            interactiveDismissTransition.isEnabled = true
        }
    }
}

extension CardsViewController: CardCollectionViewCellDelegate {
    func frontViewPositionChanged(_ cell: CardCollectionViewCell, on percent: CGFloat) {
        bottomView.alpha = 1 - percent
        bottomView.transform.ty = percent * 50
    }
}

extension CardsViewController: MiniToLargeAnimatable {
    var animatableBackgroundView: UIView {
        return backgroundView
    }
    
    var animatableMainView: UIView {
        return contentView
    }
}
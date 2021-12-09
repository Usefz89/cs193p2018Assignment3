//
//  ViewController.swift
//  SetGame
//
//  Created by Yousef Zuriqi on 04/12/2021.
//

import UIKit

class SetViewController: UIViewController {
    
    var game = SetModel()
    
    //Initiate the grid that will hold the card Views
    // Grid will maintain the aspect Ration of the card frame.
    lazy var grid = Grid(layout: .aspectRatio(5/8), frame: cardsContainerView.bounds.insetBy(dx: DrawingValues.insetValue, dy: DrawingValues.insetValue))
    
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealCardsButton: UIButton!
   
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var cardsContainerView: UIView! {
        didSet {
            // Define and Add Swipe Down gesture to deal cards
            let swipeDown = UISwipeGestureRecognizer(target: self , action: #selector(swipedDownToDealCards))
            swipeDown.direction = .down
            cardsContainerView.addGestureRecognizer(swipeDown)
            
            // Define and Add rotation Gestures to shuffle cards On board
            let rotationGesture = UIRotationGestureRecognizer(target: self , action: #selector(rotateGestureToShuffle))
            cardsContainerView.addGestureRecognizer(rotationGesture)
        }
    }
    
    private var cardViews: [CardView] {
        cardsContainerView.subviews as! [CardView]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameStyle()
        updateViewFromModel()
        cardsContainerView.clipsToBounds = true
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        grid = Grid(
            layout: .aspectRatio(DrawingValues.cardAspectRatio),
            frame: cardsContainerView.bounds.insetBy(
                dx: DrawingValues.insetValue,
                dy: DrawingValues.insetValue
            )
        )
        cardsContainerView.setNeedsLayout()
        cardsContainerView.setNeedsDisplay()
        updateViewFromModel()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cardsContainerView.setNeedsLayout()
        cardsContainerView.setNeedsDisplay()
        updateViewFromModel()
    }
    
    @IBAction func dealButtonTapped(_ sender: UIButton) {
        game.dealCards()
        updateViewFromModel()
    }
    
    @IBAction func newGameButtonTapped(_ sender: UIButton) {
        game.newGame()
        updateViewFromModel()
    }
    
    // Adding the styles for board and font etc...
    private func gameStyle() {
        newGameButton.titleLabel?.adjustsFontSizeToFitWidth = true
        newGameButton.layer.cornerRadius = DrawingValues.buttonCornerRadius
        newGameButton.layer.cornerRadius = DrawingValues.buttonCornerRadius
        dealCardsButton.titleLabel?.adjustsFontSizeToFitWidth = true

    }
    
    //MARK: - UPDATE UI
    
    func updateViewFromModel() {
        scoreLabel.text = "Score = \(game.scoreCounter)"
        disableDearCardButton()

        // Update the grid cells to match the cardOnBoard count.
        grid.cellCount = game.cardsOnBoard.count
        
        // Clear All cardView, then iterate over cardsOnbaord.
        // And add cardView for each Card.
        cardsContainerView.subviews.forEach({$0.removeFromSuperview()})
        
        for index in game.cardsOnBoard.indices {
            guard let cardRect = grid[index] else {return}
            
            // Create CardView with frame equalt grid cell Rect with small insets.
            let cardView = CardView(
                frame: cardRect.insetBy(
                    dx: DrawingValues.cardViewInsetValue,
                    dy: DrawingValues.cardViewInsetValue
                )
            )
            
            let card = game.cardsOnBoard[index]
            
            // Interpt between cards attributs with CardView attributes.
            // Style the cardView based on the Card's properties
            styleCardView(cardView, from: card)
            
            addTapGestures(cardView)
            cardsContainerView.addSubview(cardView)
            
            //Update the card when Selected, Matched or Not matched.
            updateCardViewWhenSelected(cardView, from: card)
            updateCardViewWhenMatched(cardView, from: card)
            updateCardViewWhenMisMatched(cardView, from: card)
        }
    }
    
    // UPdate the card View Functions when Selected, Matched and  Mismatched
    private func updateCardViewWhenSelected(_ cardView: CardView, from card: Card) {
        if game.selectedCards.contains(card) {
            cardView.layer.borderWidth = DrawingValues.borderWidth
            cardView.layer.borderColor = UIColor.blue.cgColor
        }
    }
    
    private func updateCardViewWhenMatched(_ cardView: CardView, from card: Card) {
        if game.alreadyMatchedCards.contains(card) {
            cardView.layer.borderWidth = DrawingValues.borderWidth
            cardView.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    private func updateCardViewWhenMisMatched(_ cardView: CardView, from card: Card) {
        if game.notMatchedCards.contains(card) {
            cardView.layer.borderWidth = DrawingValues.borderWidth
            cardView.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    private func removeCardViewsWhenMatchedAndCardsCountEqualZero() {
        if !game.alreadyMatchedCards.isEmpty && game.cards.count == 0 {
            for card in game.alreadyMatchedCards {
                if let index = game.cardsOnBoard.firstIndex(of: card) {
                    cardsContainerView.subviews[index].removeFromSuperview()
                }
            }
        }
    }
    
    private func disableDearCardButton() {
        if game.cards.count == 0 {
            dealCardsButton.isEnabled = false
        }
    }

    // MARK: - Styling Card View
    
    private func styleCardView(_ cardView: CardView, from card: Card) {
        cardView.backgroundColor = .white
        switch card.shape {
        case .squiggle: cardView.shape = .squiggle
        case .oval: cardView.shape = .oval
        case .diamond: cardView.shape = .diamond
        }
        
        switch card.shade {
        case .striped: cardView.shade = .striped
        case .open: cardView.shade = .open
        case .solid: cardView.shade = .solid
        }
        
        switch card.number {
        case .one: cardView.numberOfShapes = .one
        case .two: cardView.numberOfShapes = .two
        case .three: cardView.numberOfShapes = .three
        }
        
        switch card.color {
        case .green: cardView.color = .green
        case .orange: cardView.color = .orange
        case .purple: cardView.color = .purple
        }
    }
   
    
    
    // MARK: - Gestures Function
    
    private func addTapGestures(_ cardView: CardView) {
        let tap = UITapGestureRecognizer(target: self , action: #selector(cardViewTapped(_:)))
        cardView.addGestureRecognizer(tap)
    }
    
    @objc
    func cardViewTapped(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else {return}
        
        if let cardView = recognizer.view as? CardView {
            
            if let index = cardsContainerView.subviews.firstIndex(of: cardView) {
                let card = game.cardsOnBoard[index]
                game.choose(card)
                updateViewFromModel()

            }
        }
    }
    
    @objc
    func swipedDownToDealCards(_ recognizer: UISwipeGestureRecognizer) {
        guard recognizer.state == .ended else {return}
        game.dealCards()
        updateViewFromModel()
    }
    
    @objc
    func rotateGestureToShuffle(_ recognizer:UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            game.shuffleCards()
            updateViewFromModel()
        default:
            break
        }
    }
    
    //MARK: - CONSTANTS
    
    private struct DrawingValues {
        static let borderWidth: CGFloat = 5
        static let insetValue: CGFloat = 16
        static let cardViewInsetValue: CGFloat = 5
        static let cardAspectRatio: CGFloat = 5/8
        static let buttonCornerRadius: CGFloat = 10
    }
}


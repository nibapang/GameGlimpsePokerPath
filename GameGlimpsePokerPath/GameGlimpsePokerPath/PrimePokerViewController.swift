//
//  PokerViewController.swift
//  GameGlimpsePokerPath
//
//  Created by jin fu on 2025/3/12.
//


import UIKit

@available(iOS 13.0, *)
class PrimePokerViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var targetScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var primeSwapButton: UIButton!
    
    // Add 5 card image views
    @IBOutlet weak var card1ImageView: UIImageView!
    @IBOutlet weak var card2ImageView: UIImageView!
    @IBOutlet weak var card3ImageView: UIImageView!
    @IBOutlet weak var card4ImageView: UIImageView!
    @IBOutlet weak var card5ImageView: UIImageView!
    
    // Remove collection view related code and add cardImageViews array
    private var cardImageViews: [UIImageView] = []
    
    // MARK: - Properties
    private var playerCards: [Int] = []
    private var deck: [Int] = Array(1...13) // A through K
    private let maxCardsInHand = 5
    private var remainingSwaps = 4  // Increased swaps
    private var targetScore = 100
    private var currentScore = 0
    private var consecutiveNonPrimeDeals = 0
    private var bonusMultiplier = 1.5  // Increased base multiplier
    
    private func cardValueToString(_ value: Int) -> String {
        switch value {
        case 1: return "A"
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "\(value)"
        }
    }
         
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCards()
        DispatchQueue.main.async {
            self.Howtoplay()
        }
    }
    
    private func setupUI() {
       
        
        dealButton.addTarget(self, action: #selector(dealButtonTapped), for: .touchUpInside)
        primeSwapButton.addTarget(self, action: #selector(primeSwapButtonTapped), for: .touchUpInside)
    }
    
    private func setupCards() {
        cardImageViews = [card1ImageView, card2ImageView, card3ImageView, card4ImageView, card5ImageView]
        
        for imageView in cardImageViews {
            imageView.layer.masksToBounds = false // Changed to false to show shadow
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true // This will clip the image but allow shadow
        }
    }
    
    private func setupGame() {
        // Reset deck and game values
        shuffleDeck()
        remainingSwaps = 4
        targetScore = Int.random(in: 30...100)
        currentScore = targetScore
        playerCards = []
        consecutiveNonPrimeDeals = 0
        bonusMultiplier = 1.5
        
        // Reset all card images and styling
        for imageView in cardImageViews {
            imageView.image = nil
            imageView.backgroundColor = UIColor.clear
            imageView.layer.shadowOpacity = 0
            imageView.transform = .identity
        }
        
        // Reset buttons
        dealButton.isEnabled = true
        primeSwapButton.isEnabled = false
        
        // Update labels
        updateLabels()
    }
    
    private func updateLabels() {
        targetScoreLabel.text = "Target Score: \(targetScore)"
        scoreLabel.text = "Remaining Score: \(currentScore)"
      //  swapsRemainingLabel.text = "Swaps Remaining: \(remainingSwaps)"
        primeSwapButton.setTitle("Prime Swap (\(remainingSwaps))", for: .normal)
        // Prime swap button is enabled only when there are cards and remaining swaps
        primeSwapButton.isEnabled = remainingSwaps > 0 && !playerCards.isEmpty
    }
    
    private func getScoreBreakdown() -> String {
        let primeNumbers = playerCards.filter { isPrime($0) }
        var breakdown = ""
        
        if primeNumbers.isEmpty {
            breakdown += "No prime cards - Score unchanged\n"
            return breakdown
        }
        
        // Base score
        let baseScore = primeNumbers.reduce(0, +)
        breakdown += "Prime Cards: \(primeNumbers.map { String($0) }.joined(separator: ", "))\n"
        breakdown += "Base Score (Sum of Primes): \(baseScore)\n"
        
        // Prime Jackpot
        if primeNumbers.count == playerCards.count {
            breakdown += "Prime Jackpot Bonus (2.5x Multiplier)\n"
        }
        
        // Multiplication Rule
        var multiplicationBonus = 0
        for i in 0..<primeNumbers.count {
            for j in (i+1)..<primeNumbers.count {
                if isPrime(primeNumbers[i] * primeNumbers[j]) {
                    multiplicationBonus += primeNumbers[i] * primeNumbers[j]
                }
            }
        }
        if multiplicationBonus > 0 {
            breakdown += "Multiplication Bonus: \(multiplicationBonus)\n"
        }
        
        return breakdown
    }
    
    private func checkWinCondition() {
        if currentScore <= 0 {
            let scoreBreakdown = getScoreBreakdown()
            let message = """
                Congratulations! You've reached the target score!
                
                Final Score Breakdown:
                \(scoreBreakdown)
                Initial Target: \(targetScore)
                Final Score: \(currentScore)
                Consecutive Non-Prime Deals: \(consecutiveNonPrimeDeals)
                Current Multiplier: \(String(format: "%.1f", bonusMultiplier))x
                """
            
            let alert = UIAlertController(title: "Victory! 🎉", 
                                        message: message, 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
                self?.setupGame() // This will now properly reset everything
            })
            present(alert, animated: true)
            
        } else if remainingSwaps == 0 && deck.count < maxCardsInHand {
            let message = """
                Game Over!
                
                Final Status:
                Target Score: \(targetScore)
                Remaining Score: \(currentScore)
                Points Needed: \(currentScore)
                Consecutive Non-Prime Deals: \(consecutiveNonPrimeDeals)
                """
            
            let alert = UIAlertController(title: "Game Over 😔", 
                                        message: message, 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                self?.setupGame() // This will now properly reset everything
            })
            present(alert, animated: true)
        }
    }
    
    private func Howtoplay() {
        let message = """
            Welcome Welcome Welcome!
            
            Game Rules:
            • Prime numbers (2,3,5,7,11,13) are special
            • Score = Sum of prime cards
            • Prime Jackpot: 2x score for all prime cards
            • Multiplication Rule: Bonus for prime products     
            • Prime Swap randomly replaces one non-prime card
            • Deal fills all empty card slots
            
            Reasons for Loss:
            • Failed to reach target score
            • No more swaps available
            """
        
        let alert = UIAlertController(title: "How To Play!",
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Let's Play", style: .default) { [weak self] _ in
            self?.setupGame()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Game Logic
    private func shuffleDeck() {
        deck = Array(1...13) // Reset deck to A through K
        deck.shuffle()
    }
    
    private func ensureEnoughCards(needed: Int) {
        if deck.count < needed {
            shuffleDeck()
        }
    }
    
    private func isPrime(_ number: Int) -> Bool {
        if number < 2 { return false }
        if number == 2 { return true }
        if number % 2 == 0 { return false }
        
        let sqrt = Int(Double(number).squareRoot())
        for i in stride(from: 3, through: sqrt, by: 2) {
            if number % i == 0 { return false }
        }
        return true
    }
    
    private func calculateScore() -> Int {
        // Only get prime numbers from player cards
        let primeNumbers = playerCards.filter { isPrime($0) }
        
        // If no prime numbers, return 0 (no score change)
        if primeNumbers.isEmpty {
            return 0
        }
        
        // Base score is just the sum of prime numbers
        var score = primeNumbers.reduce(0, +)
        
        // Prime Jackpot bonus (all cards are prime)
        if primeNumbers.count == playerCards.count {
            score = Int(Double(score) * 2.5)  // 2.5x multiplier for all primes
            consecutiveNonPrimeDeals = 0
        } else {
            consecutiveNonPrimeDeals += 1
        }
        
        // Multiplication Rule bonus (if any prime products)
        for i in 0..<primeNumbers.count {
            for j in (i+1)..<primeNumbers.count {
                if isPrime(primeNumbers[i] * primeNumbers[j]) {
                    score += primeNumbers[i] * primeNumbers[j]
                }
            }
        }
        
        return score
    }
    
    // MARK: - Actions
    @objc private func dealButtonTapped() {
        ensureEnoughCards(needed: maxCardsInHand)
        playerCards = Array(deck.prefix(maxCardsInHand))
        deck.removeFirst(maxCardsInHand)
        
        // Update all cards at once
        for (index, card) in playerCards.enumerated() {
            let imageView = cardImageViews[index]
            
            // Set card image
            imageView.image = UIImage(named: getCardImageName(for: card))
            
            // Remove any existing border
            imageView.layer.borderWidth = 0
            
            // Create highlight effect using a background view
            if isPrime(card) {
                // Create green glow effect for prime cards
                let glowView = UIView(frame: imageView.bounds)
                glowView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
                glowView.layer.cornerRadius = 8
                
                // Add subtle shadow for depth
                imageView.layer.shadowColor = UIColor.systemGreen.cgColor
                imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
                imageView.layer.shadowRadius = 8
                imageView.layer.shadowOpacity = 0.8
                
                // Add glow view behind the image
                imageView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            } else {
                // Regular cards get a subtle gray background
                imageView.backgroundColor = UIColor.systemGray6
                imageView.layer.shadowColor = UIColor.black.cgColor
                imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
                imageView.layer.shadowRadius = 4
                imageView.layer.shadowOpacity = 0.2
            }
            
            // Add corner radius to all cards
            imageView.layer.cornerRadius = 8
        }
        
        dealButton.isEnabled = false
        primeSwapButton.isEnabled = remainingSwaps > 0
        updateScore()
        checkWinCondition()
    }
    
    @objc private func primeSwapButtonTapped() {
        guard remainingSwaps > 0 else { return }
        
        let nonPrimePositions = playerCards.enumerated()
            .filter { !isPrime($0.element) }
            .map { $0.offset }
        
        if let randomPosition = nonPrimePositions.randomElement() {
            ensureEnoughCards(needed: 1)
            let newCard = deck.removeFirst()
            playerCards[randomPosition] = newCard
            
            let imageView = cardImageViews[randomPosition]
            
            // Animate card flip
            UIView.animate(withDuration: 0.3) {
                imageView.transform = CGAffineTransform(scaleX: 0.1, y: 1.0)
            } completion: { _ in
                // Update card
                imageView.image = UIImage(named: self.getCardImageName(for: newCard))
                
                // Update styling based on prime status
                if self.isPrime(newCard) {
                    // Prime card styling
                    imageView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                    imageView.layer.shadowColor = UIColor.systemGreen.cgColor
                    imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
                    imageView.layer.shadowRadius = 8
                    imageView.layer.shadowOpacity = 0.8
                } else {
                    // Regular card styling
                    imageView.backgroundColor = UIColor.systemGray6
                    imageView.layer.shadowColor = UIColor.black.cgColor
                    imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
                    imageView.layer.shadowRadius = 4
                    imageView.layer.shadowOpacity = 0.2
                }
                
                // Flip back
                UIView.animate(withDuration: 0.3) {
                    imageView.transform = .identity
                }
            }
            
            remainingSwaps -= 1
            updateScore()
            updateLabels()
            checkWinCondition()
        }
    }
    
    private func updateScore() {
        let roundScore = calculateScore()
        currentScore -= roundScore
        updateLabels()
    }
    
    private func getCardImageName(for value: Int) -> String {
        switch value {
        case 1: return "card_A"
        case 11: return "card_J"
        case 12: return "card_Q"
        case 13: return "card_K"
        default: return "card_\(value)"
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

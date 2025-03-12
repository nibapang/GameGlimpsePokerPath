//
//  GameViewController.swift
//  GameGlimpsePokerPath
//
//  Created by jin fu on 2025/3/12.
//


import UIKit

class SuitMathGameViewController: UIViewController {
    
    // MARK: - Properties
    private var board: [[Suit]] = Array(repeating: Array(repeating: .hearts, count: 6), count: 6)
    private var diceNumber = 1
    private var score = 0
    private var isRolling = false
    private var selectedButtons: [UIButton] = []
    private var canSelect = false
    
    // Timer properties
    private var timer: Timer?
    private var timeRemaining: Int = 60 // 1 minute in seconds
    
    // Target properties
    private var targetSuit: Suit = .hearts
    private var targetCount: Int = 0
    private var collectedCount: Int = 0
    
    // MARK: - Outlets
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var diceButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    
    // Array of button outlets
    @IBOutlet var boardButtons: [UIButton]! // Array of 36 buttons
    
    // MARK: - Suit enum
    enum Suit: String {
        case hearts = "heart"
        case diamonds = "diamond"
        case clubs = "club"
        case spades = "spade"
        
        static var allCases: [Suit] = [.hearts, .diamonds, .clubs, .spades]
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
    
    // Dice images array
    private let diceImages = [
        UIImage(named: "dice1"),
        UIImage(named: "dice2"),
        UIImage(named: "dice3"),
        UIImage(named: "dice4"),
        UIImage(named: "dice5"),
        UIImage(named: "dice6")
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNewGame()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .center
        
        // Setup dice button
        diceButton.setImage(diceImages[0], for: .normal)
        diceButton.imageView?.contentMode = .scaleAspectFit
        diceButton.backgroundColor = .clear
        
        instructionLabel.text = "Tap dice to roll"
        instructionLabel.numberOfLines = 2
        instructionLabel.textAlignment = .center
        
        // Setup board buttons
        for (index, button) in boardButtons.enumerated() {
            button.tag = index
            button.backgroundColor = .appcolorWhite
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.imageView?.contentMode = .scaleAspectFit
            // Add padding to the button image
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
    
    // MARK: - Game Setup
    private func setupNewGame() {
        score = 0
        collectedCount = 0
        timeRemaining = 60
        canSelect = false
        selectedButtons.removeAll()
        
        // Set random target with random count
        setNewRandomTarget()
        
        updateScoreLabel()
        updateTimerLabel()
        updateTargetLabel()
        randomizeBoard()
        startTimer()
    }
    
    private func setNewRandomTarget() {
        targetSuit = Suit.allCases.randomElement()!
        // Random target count between 15 and 25
        targetCount = Int.random(in: 15...25)
        collectedCount = 0
        updateTargetLabel()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        timeRemaining -= 1
        updateTimerLabel()
        
        if timeRemaining <= 0 {
            gameOver(won: false)
        }
    }
    
    private func updateTimerLabel() {
        timerLabel.text = "Time: \(formatTime(timeRemaining))"
    }
    
    private func updateTargetLabel() {
        _ = targetSuit.image
        targetLabel.text = "Collect \(targetCount - collectedCount) \(targetSuit.rawValue)s"
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    private func gameOver(won: Bool) {
        timer?.invalidate()
        timer = nil
        canSelect = false
        
        let title = "Game Over!"
        let message = """
            Time's up!
            Targets Completed: \(score / 50)
            Final Score: \(score)
            Time Played: \(60 - timeRemaining) seconds
            """
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.setupNewGame()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Game Logic
    private func randomizeBoard() {
        for i in 0..<6 {
            for j in 0..<6 {
                let index = i * 6 + j
                board[i][j] = Suit.allCases.randomElement()!
                updateButtonSuit(at: index)
            }
        }
    }
    
    private func updateButtonSuit(at index: Int) {
        let row = index / 6
        let col = index % 6
        let button = boardButtons[index]
        let suitImage = board[row][col].image
        button.setImage(suitImage, for: .normal)
    }
    
    @IBAction func rollDiceButtonTapped(_ sender: UIButton) {
        guard !isRolling && timeRemaining > 0 else { return }
        
        // Check if we need to add more target suits
        if !checkBoardForPossibleMoves() {
            addRandomTargetSuits()
        }
        
        clearSelectedButtons()
        
        isRolling = true
        canSelect = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.diceButton.transform = CGAffineTransform(rotationAngle: .pi)
            self.diceButton.alpha = 0.5
        }) { _ in
            self.diceNumber = Int.random(in: 1...6)
            self.diceButton.setImage(self.diceImages[self.diceNumber - 1], for: .normal)
            
            UIView.animate(withDuration: 0.5) {
                self.diceButton.transform = .identity
                self.diceButton.alpha = 1.0
            } completion: { _ in
                self.isRolling = false
                self.canSelect = true
                self.instructionLabel.text = "Select \(self.diceNumber) matching suits"
            }
        }
    }
    
    @IBAction func suitButtonTapped(_ sender: UIButton) {
        guard canSelect && timeRemaining > 0 else { return }
        
        let row = sender.tag / 6
        let col = sender.tag % 6
        let selectedSuit = board[row][col]
        
        if selectedButtons.contains(sender) {
            // Deselect button
            sender.layer.backgroundColor = UIColor.white.cgColor
            selectedButtons.removeAll { $0 == sender }
        } else {
            // Check if the suit matches the first selected suit
            if let firstButton = selectedButtons.first {
                let firstRow = firstButton.tag / 6
                let firstCol = firstButton.tag % 6
                let firstSuit = board[firstRow][firstCol]
                
                if selectedSuit == firstSuit && selectedButtons.count < diceNumber {
                    sender.layer.backgroundColor = UIColor.lightGray.cgColor
                    selectedButtons.append(sender)
                }
            } else {
                // First selection
                sender.layer.backgroundColor = UIColor.lightGray.cgColor
                selectedButtons.append(sender)
            }
        }
        
        if selectedButtons.count == diceNumber {
            handleMatch()
        }
    }
    
    private func handleMatch() {
        let firstButton = selectedButtons[0]
        let firstRow = firstButton.tag / 6
        let firstCol = firstButton.tag % 6
        let matchingSuit = board[firstRow][firstCol]
        
        let allMatch = selectedButtons.allSatisfy { button in
            let row = button.tag / 6
            let col = button.tag % 6
            return board[row][col] == matchingSuit
        }
        
        if allMatch {
            // Update score
            score += diceNumber * 10
            updateScoreLabel()
            
            // Check if matched suits contribute to target
            if matchingSuit == targetSuit {
                collectedCount += selectedButtons.count
                updateTargetLabel()
                
                // Check for target completion
                if collectedCount >= targetCount {
                    // Bonus points for completing target
                    score += 50
                    updateScoreLabel()
                    
                    // Stop timer temporarily
                    timer?.invalidate()
                    
                    // Show win alert
                    showWinAlert()
                    return
                }
            }
            
            // Replace matched suits with new ones
            replaceMatchedSuits()
            
            selectedButtons.removeAll()
            canSelect = false
            instructionLabel.text = "Tap dice to roll again"
        } else {
            clearSelectedButtons()
        }
    }
    
    private func clearSelectedButtons() {
        for button in selectedButtons {
            button.layer.backgroundColor = UIColor.white.cgColor
        }
        selectedButtons.removeAll()
    }
    
    private func replaceMatchedSuits() {
        for button in selectedButtons {
            let row = button.tag / 6
            let col = button.tag % 6
            
            // 30% chance to place target suit
            if Double.random(in: 0...1) < 0.3 {
                board[row][col] = targetSuit
            } else {
                // Random suit, but weight towards non-target suits
                var newSuit: Suit
                repeat {
                    newSuit = Suit.allCases.randomElement()!
                } while newSuit == targetSuit && Double.random(in: 0...1) < 0.7
                board[row][col] = newSuit
            }
            
            updateButtonSuit(at: button.tag)
            button.layer.backgroundColor = UIColor.white.cgColor
            
            // Animate the replacement
            button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3) {
                button.transform = .identity
            }
        }
    }
    
    private func showWinAlert() {
        let alert = UIAlertController(title: "Congratulations! 🎉", 
                                     message: "You completed the target!\nScore: \(score)\nTime remaining: \(timeRemaining) seconds\n\nWould you like to continue with a new target or start a new game?", 
                                     preferredStyle: .alert)
        
        // Continue with new target
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Set new random target
            self.setNewRandomTarget()
            
            // Resume timer
            self.startTimer()
            
            // Show completion animation
            self.showTargetCompletionAnimation()
            
            // Check board state
            self.checkBoardForPossibleMoves()
        })
        
        // Start new game
        alert.addAction(UIAlertAction(title: "New Game", style: .destructive) { [weak self] _ in
            self?.setupNewGame()
        })
        
        present(alert, animated: true)
    }
    
    private func checkBoardForPossibleMoves() -> Bool {
        // Count occurrences of target suit
        var targetSuitCount = 0
        for row in 0..<6 {
            for col in 0..<6 {
                if board[row][col] == targetSuit {
                    targetSuitCount += 1
                }
            }
        }
        
        // If there aren't enough target suits on the board, add some
        if targetSuitCount < (targetCount - collectedCount) {
            addRandomTargetSuits()
            return true
        }
        
        return targetSuitCount >= (targetCount - collectedCount)
    }
    
    private func addRandomTargetSuits() {
        let neededSuits = min(3, targetCount - collectedCount - countTargetSuitsOnBoard())
        var addedSuits = 0
        
        while addedSuits < neededSuits {
            let randomRow = Int.random(in: 0..<6)
            let randomCol = Int.random(in: 0..<6)
            
            if board[randomRow][randomCol] != targetSuit {
                board[randomRow][randomCol] = targetSuit
                let buttonIndex = randomRow * 6 + randomCol
                updateButtonSuit(at: buttonIndex)
                addedSuits += 1
                
                // Animate the new target suit - Fixed version
                let button = boardButtons[buttonIndex]
                button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.3) {
                    button.transform = .identity
                }
            }
        }
    }
    
    private func countTargetSuitsOnBoard() -> Int {
        var count = 0
        for row in 0..<6 {
            for col in 0..<6 {
                if board[row][col] == targetSuit {
                    count += 1
                }
            }
        }
        return count
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func showTargetCompletionAnimation() {
        // Create and show a temporary label for target completion
        let completionLabel = UILabel()
        completionLabel.text = """
            Target Complete! 🎉
            +50 points
            New Target: \(targetCount) \(targetSuit.rawValue)s
            """
        completionLabel.numberOfLines = 3
        completionLabel.textAlignment = .center
        completionLabel.textColor = .green
        completionLabel.font = .boldSystemFont(ofSize: 20)
        completionLabel.alpha = 0
        
        view.addSubview(completionLabel)
        completionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundView.alpha = 0
        
        view.insertSubview(backgroundView, belowSubview: completionLabel)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.5, animations: {
            completionLabel.alpha = 1
            backgroundView.alpha = 1
        }) { _ in
            // Animate out after delay
            UIView.animate(withDuration: 0.5, delay: 2.0, animations: {
                completionLabel.alpha = 0
                backgroundView.alpha = 0
            }) { _ in
                completionLabel.removeFromSuperview()
                backgroundView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

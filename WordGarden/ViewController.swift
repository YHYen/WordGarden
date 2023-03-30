//
//  ViewController.swift
//  WordGarden
//
//  Created by 顏逸修 on 2023/3/29.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var wordGuessedLabel: UILabel!
    @IBOutlet weak var wordRemainingLabel: UILabel!
    @IBOutlet weak var wordInGameLabel: UILabel!
    @IBOutlet weak var wordMissedLabel: UILabel!
    
    @IBOutlet weak var wordBeingRevealedLabel: UILabel!
    @IBOutlet weak var guessedLetterField: UITextField!
    @IBOutlet weak var guessLetterButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var flowerImageView: UIImageView!
    
    var wordsToGuess = ["SWIFT", "DOG", "CAT", "BALLOON", "EGG"]
    var currentWordIndex = 0
    var wordToGuess = ""
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 8
    var wrongGuessesRemaining = 8
    var wordGuessCount = 0
    var wordMissedCount = 0
    var guessCount = 0
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let text = guessedLetterField.text!
        guessLetterButton.isEnabled = !(text.isEmpty)
        
        gameStartAndRevealWord()
        
        updateGameStatusLabel()
    }
    
    func updateUIAfterGuess() {
        guessedLetterField.resignFirstResponder()
        guessedLetterField.text! = ""
        guessLetterButton.isEnabled = false
    }
    
    func gameStartAndRevealWord() {
        wordToGuess = wordsToGuess[currentWordIndex]
        wordBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count - 1)
    }
    
    func formatRevealWord() {
       
        var revealedWord = ""
        
        // loop through all letters in wordToGuess
        for letter in wordToGuess {
            // check if letter in wordToGuess is in letter guessed (i.e. did you guess this letter already?)
            if lettersGuessed.contains(letter) {
                // if so, add this letter + a blank space, to revealedWord
                revealedWord = revealedWord + "\(letter) "
            } else {
                // if not, add an undersocre + a blank space, to revealWord
                revealedWord = revealedWord + "_ "
            }
        }
        
        // remove the extra space at the last of revealedWord String
        revealedWord.removeLast()
        
        wordBeingRevealedLabel.text = revealedWord
    }
    
    
    func updateAfterWinOrLose() {
        // what do we do if game is over
        // - increment currentWordIndex by 1
        // - disabled guessLetterTextField
        // - disabled guessLetterButton
        // - set playAgainButton .isHidden to false
        // - update all labels at the top of screen
        
        currentWordIndex += 1
        guessedLetterField.isEnabled = false
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = false
        
        updateGameStatusLabel()
    }
    
    func updateGameStatusLabel() {
        // update labels at the top of screen
        wordGuessedLabel.text = "Words Guessed: \(wordGuessCount)"
        wordRemainingLabel.text = "Words Remaining: \(wordsToGuess.count - (wordGuessCount + wordMissedCount))"
        wordMissedLabel.text = "Words Missed: \(wordMissedCount)"
        wordInGameLabel.text = "Words in Game: \(wordsToGuess.count)"
    }
    
    
    func guessALetter() {
        // get current letter guessed and add it to all letter guessed
        let currentLetterGuessed = guessedLetterField.text!
        lettersGuessed = lettersGuessed + currentLetterGuessed
        
        // format and show revealedWord to wordBeingRevealedLabel to inclue new guess
        formatRevealWord()
        
        // update image, if needed, and keep track of wrong guesses
        if wordToGuess.contains(currentLetterGuessed) == false {
            wrongGuessesRemaining -= 1
            flowerImageView.image = UIImage(named: "flower\(wrongGuessesRemaining)")
            playSound(name: "incorrect")
        } else {
            playSound(name: "correct")
        }
        
        // update gameStatusMessageLabel
        guessCount += 1
        
        var guesses = "Guesses"
        if guessCount == 1 {
            guesses = "Guess"
        }
        
        gameStatusLabel.text = "You've Made \(guessCount) \(guesses)"
        
        // After each guess, check to see if two things happen:
        // 1) The user won the game
        // - all letters are guessed, so there no more underscores in wordBeingRevealedLabel.text
        // - handle game over
        // 2) the user lost the game
        // - wrongGuessesRemaining = 0
        // - handle gmae over
        if wordBeingRevealedLabel.text!.contains("_") == false {
            gameStatusLabel.text = "You've guessed it ! It took you \(guessCount) guesses to guess the word."
            wordGuessCount += 1
            playSound(name: "word-guessed")
            updateAfterWinOrLose()
        } else if wrongGuessesRemaining == 0 {
            gameStatusLabel.text = "So sorry, you're all out of guesses."
            wordMissedCount += 1
            playSound(name: "word-not-guessed")
            updateAfterWinOrLose()
        }
        
        // check to see if you've play all the words. If so, update the message indicating the player can restart entire game.
        if currentWordIndex >= wordsToGuess.count {
            gameStatusLabel.text! += "\n\nYou've tried all of the words! Restart from the beginning ?"
        }
    }
    
    
    func playSound(name: String) {
        if let sound = NSDataAsset(name: name) {
            do {
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
            } catch {
                print("😡 ERROR: \(error.localizedDescription). Could not initialize AVAudioPlayer object")
            }
        } else {
            print("😡 ERROR: Could not read data from file \(name)")
        }
    }
    
    
    @IBAction func guessLetterFieldChanged(_ sender: UITextField) {
        sender.text = String(sender.text?.last ?? " ").trimmingCharacters(in: .whitespaces).uppercased()
        
        guessLetterButton.isEnabled = !(sender.text!.isEmpty)
    }

    
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessALetter()
        updateUIAfterGuess()
    }
    

    @IBAction func guessLetterButtonPressed(_ sender: UIButton) {
        guessALetter()
        // this dismisses the keyboard
        updateUIAfterGuess()
    }
    
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        
        if currentWordIndex == wordsToGuess.count {
            currentWordIndex = 0
            wordGuessCount = 0
            wordMissedCount = 0
            
            updateGameStatusLabel()
        }
        
        // hide playAgainButton
        // enable guessedLetterField
        // current word should be set to the next word
        // set word being revealed. text to underscores separated by spaces
        // set wrongGuessesRemaining to maxNumberOfWrongGuesses
        // set guessCount = 0
        // set flowerImageView to flower8
        // clear out letter guessed, so new word restarts with no letters guessed, or = ""
        // set gameStatusLabel to original text "You've Made Zero Guess"
        
        playAgainButton.isHidden = true
        guessedLetterField.isEnabled = true
        
        gameStartAndRevealWord()
        
        wrongGuessesRemaining = maxNumberOfWrongGuesses
        guessCount = 0
        
        flowerImageView.image = UIImage(named: "flower\(maxNumberOfWrongGuesses)")
        
        lettersGuessed = ""
        
        gameStatusLabel.text = "You've Made Zero Guess"
    }
}


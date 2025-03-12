//
//  Utils.swift
//  GameGlimpsePokerPath
//
//  Created by jin fu on 2025/3/12.
//


import UIKit

//MARK: - Alert

class GameGlimpseAlterView {
    static func showAlert(title: String, message: String, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

//
//  UIViewController+Extension.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import UIKit

extension UIViewController {
    
    func alert(_ message: String, title: String? = nil, dismissButtonText: String = "Ok", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButtonText, style: .default) { _ in
            completion?()
        })
        self.present(alert, animated: true)
    }
}

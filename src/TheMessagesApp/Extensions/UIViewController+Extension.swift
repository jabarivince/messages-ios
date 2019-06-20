//
//  UIViewController+Extension.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import UIKit

extension UIViewController {
    var presentedVC: UIViewController {
        return presentedViewController ?? self
    }
    
    func alert(_ message: String, title: String? = nil, dismissButtonText: String = "Ok", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButtonText, style: .default) { _ in
            completion?()
        })
        self.present(alert, animated: true)
    }
    
    func promptToContinue(_ message: String,
                          title: String? = nil,
                          cancelButtonText: String = "Cancel",
                          continueButtonText: String = "Continue",
                          completion: @escaping () -> Void) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: cancelButtonText, style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: continueButtonText, style: .destructive, handler: { _ in
            completion()
        }))
        
        present(ac, animated: true, completion: nil)
    }

    func promptForText(title: String,
                       message: String? = nil,
                       placeholder: String?,
                       confirmButtonText: String = "Ok",
                       cancelButtonText: String = "Cancel",
                       completion: @escaping (String?) -> Void) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: cancelButtonText, style: .cancel, handler: nil))

        ac.addTextField { field in
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
            field.placeholder = placeholder
            field.returnKeyType = .done
            field.tintColor = .primary
        }

        let createAction = UIAlertAction(title: confirmButtonText, style: .default, handler: { _ in
            completion(ac.textFields?.first?.text)
        })
        
        ac.addAction(createAction)
        ac.preferredAction = createAction

        present(ac, animated: true) {
            ac.textFields?.first?.becomeFirstResponder()
        }
    }
}


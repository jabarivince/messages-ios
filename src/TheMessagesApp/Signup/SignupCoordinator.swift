//
//  SignupCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/16/19.
//

import UIKit

class SignupCoordinator: Coordinator<SignupViewModel> {
    let authenticationService = DefaultAuthenticationService.shared
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        
        observe(SignupSubmissionEvent.self) { [weak self] event in
            self?.authenticationService.createUser(from: event.request) { [weak self] error in
                
                if let error = error {
                    self?.viewController.alert(error.localizedDescription, title: "Oops!")
                } else {
                    self?.viewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        observe(SignupCancelEvent.self) { [weak self] event in
            self?.viewController.dismiss(animated: true, completion: nil)
        }
    }
}

struct SignupViewModel: ViewModel {}
struct SignupCancelEvent: ActionEvent {}

struct SignupSubmissionEvent: ActionEvent {
    let request: SignupSubmissionRequest
}

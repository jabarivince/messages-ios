//
//  SignupCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/16/19.
//

import UIKit

class SignupCoordinator: Coordinator<SignupViewModel> {
    private var authenticationService = DefaultAuthenticationService.shared

    required init(_ viewController: UIViewController) {
        super.init(viewController)
        
        observe(SignupCancelButtonTapped.self) { [unowned self] _ in
            self.dismiss()
        }
        
        observe(SignupSubmitButtonTapped.self) { [unowned self] event in
            self.authenticationService.createUser(from: event.request) { error in
                if let error = error {
                    self.alert(error)
                } else {
                    self.dismiss()
                }
            }
        }
    }
}

struct SignupViewModel: ViewModel {}
struct SignupCancelButtonTapped: ActionEvent {}
struct SignupSubmitButtonTapped: ActionEvent {
    let request: SignupSubmissionRequest
}

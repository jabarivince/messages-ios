//
//  LoginCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import UIKit
import Firebase

class LoginCoordinator: Coordinator<LoginViewModel> {
    let authenticationService = DefaultAuthenticationService.shared
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        
        observe(LoginSubmissionEvent.self) { [weak self] event in
            self?.authenticationService.login(email: event.email, password: event.password) { [weak self] user, error in
                if let error = error {
                    viewController.alert(error.localizedDescription, title: "Oops!")
                } else {
                    if let user = user {
                        let channelsController = UINavigationController(rootViewController: ChannelsViewController(currentUser: user))
                        self?.viewController.present(channelsController, animated: true, completion: nil)
                    } else {
                        // Error
                    }
                    
                }
            }
        }
        
        observe(LoginSignupButtonTappedEvent.self) { [weak self] event in
            let signUpController = SignupViewController()
            self?.viewController.present(signUpController, animated: true, completion: nil)
        }
    }
}

struct LoginSubmissionEvent: ActionEvent {
    let email: String
    let password: String
}

struct LoginViewModel: ViewModel {}
struct LoginSignupButtonTappedEvent: ActionEvent {}

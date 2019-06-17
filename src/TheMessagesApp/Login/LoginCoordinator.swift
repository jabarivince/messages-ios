//
//  LoginCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import UIKit

class LoginCoordinator: Coordinator {
    let authenticationService = DefaultAuthenticationService()
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        
        observe(LoginSubmissionEvent.self) { [weak self] event in
            self?.authenticationService.login(email: event.email, password: event.password) { [weak self] error in
                if let error = error {
                    viewController.alert(error.localizedDescription, title: "Oops!")
                } else {
                    let mainController = UINavigationController(rootViewController: HomeViewController())
                    self?.viewController.present(mainController, animated: true, completion: nil)
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

struct LoginSignupButtonTappedEvent: ActionEvent {}

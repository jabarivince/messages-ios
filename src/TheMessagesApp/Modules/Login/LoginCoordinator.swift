//
//  LoginCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import UIKit
import RxSwift

class LoginCoordinator: Coordinator<LoginViewModel> {
    private let authenticationService = DefaultAuthenticationService.shared
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        
        observe(LoginSubmissionEvent.self) { [unowned self] event in
            self.authenticationService.login(email: event.email, password: event.password) { (user, error) in
                if let error = error {
                    self.alert(error)
                } else if let _ = user {
                    self.viewModel.clear.onNext(())
                    self.navigate(to: ChannelsViewController.self)
                }
            }
        }
        
        observe(LoginSignupButtonTappedEvent.self) { [unowned self] _ in
            self.present(SignupViewController.self)
        }
    }
}

struct LoginSubmissionEvent: ActionEvent {
    let email: String
    let password: String
}

struct LoginViewModel: ViewModel {
    let clear = PublishSubject<Void>()
}

struct LoginSignupButtonTappedEvent: ActionEvent {}

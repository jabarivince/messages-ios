//
//  SignUpController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class SignupViewController: CoordinatedViewController<SignupCoordinator> {
    var signUpView: SignupView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

private extension SignupViewController {
    func setupViews() {
        let signUpView = SignupView(frame: view.frame)
        self.signUpView = signUpView
        self.signUpView.submitAction = submitPressed
        self.signUpView.cancelAction = cancelPressed
        view.addSubview(signUpView)
    }
    
    func submitPressed() {
        
        // NOTE - guard is unnecesary because textfield just returns ""
        // if the text field is empty. Might as well make the fields on
        // the requestion optional and do data validation in the service
        
        guard
            let email = signUpView.emailTextField.text,
            let password = signUpView.passwordTextField.text,
            let confirmPassword = signUpView.confirmPasswordTextField.text,
            let name = signUpView.nameTextField.text
        else { return }
        
        let request = SignupSubmissionRequest(email: email,
                                              password: password,
                                              confirmPassword: confirmPassword,
                                              name: name)
        
        coordinator.emit(SignupSubmissionEvent(request: request))
    }
    
    func cancelPressed() {
        coordinator.emit(SignupCancelEvent())
    }
}

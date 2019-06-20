//
//  SignUpController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class SignupViewController: UIViewController {
    var signUpView: SignupView!
    var coordinator: SignupCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = SignupCoordinator(self)
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
        let request = SignupSubmissionRequest(email: signUpView.emailTextField.text,
                                              password: signUpView.passwordTextField.text,
                                              confirmPassword: signUpView.confirmPasswordTextField.text,
                                              name: signUpView.nameTextField.text)
        
        coordinator.emit(SignupSubmissionEvent(request: request))
    }
    
    func cancelPressed() {
        coordinator.emit(SignupCancelEvent())
    }
}

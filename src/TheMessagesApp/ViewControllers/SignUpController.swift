//
//  SignUpController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class SignUpController: UIViewController {
    var signUpView: SignUpView!
    let authenticationService: AuthenticationService = DefaultAuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        let signUpView = SignUpView(frame: view.frame)
        self.signUpView = signUpView
        self.signUpView.submitAction = submitPressed
        self.signUpView.cancelAction = cancelPressed
        view.addSubview(signUpView)
    }
    
    func submitPressed() {
        guard
            let email = signUpView.emailTextField.text,
            let password = signUpView.confirmPasswordTextField.text,
            let name = signUpView.nameTextField.text
        else { return }
        
        authenticationService.createUser(email: email, password: password, name: name) {
             self.dismiss(animated: true, completion: nil)
        }
    }
    
    func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }
}

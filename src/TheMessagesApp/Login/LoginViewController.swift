//
//  LoginController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class LoginViewController: UIViewController {
    private var loginView: LoginView!
    var coordinator: LoginCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = LoginCoordinator(self)
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

private extension LoginViewController {
    func setupView() {
        loginView = LoginView(frame: view.frame)
        loginView.loginAction = loginPressed
        loginView.signupAction = signupPressed
        view.addSubview(loginView)
        loginView.setAnchor(top: view.topAnchor,
                            left: view.leftAnchor,
                            bottom: view.bottomAnchor,
                            right: view.rightAnchor,
                            paddingTop: 0,
                            paddingLeft: 0,
                            paddingBottom: 0,
                            paddingRight: 0)
    }
    
    func loginPressed() {
        guard
            let email = loginView.emailTextField.text,
            let password = loginView.passwordTextField.text
        else { return }
        
        coordinator.emit(LoginSubmissionEvent(email: email, password: password))
    }
    
    func signupPressed() {
        coordinator.emit(LoginSignupButtonTappedEvent())
    }
}

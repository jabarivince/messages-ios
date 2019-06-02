//
//  LoginController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class LoginController: UIViewController {
    var loginView: LoginView!
    let authenticationService: AuthenticationService = DefaultAuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
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
        
        authenticationService.login(email: email, password: password) { [weak self] in
            guard let self = self else { return }
            let mainController = UINavigationController(rootViewController: MainController())
            self.present(mainController, animated: true, completion: nil)
        }
    }
    
    func signupPressed() {
        let signUpController = SignUpController()
        present(signUpController, animated: true, completion: nil)
    }
}

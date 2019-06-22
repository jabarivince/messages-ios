//
//  LoginController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import RxSwift
import UIKit

class LoginViewController: UIViewController {
    lazy private var loginView = LoginView(frame: view.frame)
    lazy private var coordinator = LoginCoordinator(self)
    lazy private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loginView)
        loginView.setAnchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: 0,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0
        )
        
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

private extension LoginViewController {
    func setupObservers() {
        disposeBag.insert(
            loginView.loginButtonTap.subscribe() { [weak self] event in
                guard let self = self else { return }
                let email = self.loginView.email
                let password = self.loginView.password
                
                self.coordinator.emit(LoginSubmissionEvent(email: email, password: password))
            },
            
            loginView.signupButtonTap.subscribe() { [weak self] event in
                self?.coordinator.emit(LoginSignupButtonTappedEvent())
            },
            
            coordinator.viewModel.clear.subscribe() { [weak self] _ in
                self?.loginView.clear()
            }
        )
    }
}

//
//  SignUpController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import RxSwift
import UIKit

class SignupViewController: UIViewController {
    private lazy var coordinator = SignupCoordinator(self)
    private lazy var signUpView  = SignupView(frame: view.frame)
    private var disposeBag: DisposeBag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(signUpView)
        setupObservers()
    }
}

private extension SignupViewController {
    func setupObservers() {
        disposeBag = DisposeBag(disposing:
            
            // Submit button tapped
            signUpView.submitButtonTap.subscribe() { [unowned self] _ in
                let signUpView = self.signUpView
                self.coordinator.emit(
                    SignupSubmitButtonTapped(request: SignupSubmissionRequest(
                        email: signUpView.email,
                        password: signUpView.password,
                        confirmPassword: signUpView.confirmPassword,
                        name: signUpView.name
                    ))
                )
            },
            
            // Cancel button tapped
            signUpView.cancelButtonTap.subscribe() { [unowned self] _ in
                self.coordinator.emit(SignupCancelButtonTapped())
            }
        )
    }
}

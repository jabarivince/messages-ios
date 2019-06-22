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
    private lazy var signUpView = SignupView(frame: view.frame)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(signUpView)
        setupObservers()
    }
}

private extension SignupViewController {
    func setupObservers() {
        disposeBag.insert(
            signUpView.cancelButtonTap.bind(to: coordinator.cancel),
            
            signUpView.submitButtonTap.subscribe() { [unowned self] _ in
                self.submitPressed()
            }
        )
    }
    
    func submitPressed() {
        coordinator.submit.asObserver().onNext(
            SignupSubmissionRequest(
                email: signUpView.email,
                password: signUpView.password,
                confirmPassword: signUpView.confirmPassword,
                name: signUpView.name
        ))
    }
}

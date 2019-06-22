//
//  SignupCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/16/19.
//

import RxSwift
import UIKit

class SignupCoordinator: Coordinator<SignupViewModel> {
    private var authenticationService = DefaultAuthenticationService.shared
    private let disposeBag = DisposeBag()
    let submit = PublishSubject<SignupSubmissionRequest>()
    let cancel = PublishSubject<Void>()
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        
        disposeBag.insert(
            cancel.subscribe() { [unowned self] _ in
                self.dismiss()
            },
            
            submit.subscribe() { [unowned self] event in
                guard let request = event.element else { return }
                
                self.authenticationService.createUser(from: request) { error in
                    if let error = error {
                        self.alert(error)
                    } else {
                        self.dismiss()
                    }
                }
            }
        )
    }
}

struct SignupViewModel: ViewModel {}

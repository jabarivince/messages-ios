//
//  HomeCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import RxSwift

class HomeCoordinator: Coordinator {
    let authenticationService = DefaultAuthenticationService()
    
    let title = PublishSubject<String>()
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)

        observe(HomeViewDidLoadEvent.self) { [weak self] event in
            self?.authenticationService.getUser() { [weak self] user in
                if let name = user?.name {
                    self?.title.on(.next(name))
                }
            }
        }
        
        observe(HomeLogoutButtonTappedEvent.self) { [weak self] event in
            self?.authenticationService.logout()
            let loginController = UINavigationController(rootViewController: LoginViewController())
            self?.viewController.present(loginController, animated: true, completion: nil)
        }
    }
}

struct HomeViewDidLoadEvent: ActionEvent {}
struct HomeLogoutButtonTappedEvent: ActionEvent {}

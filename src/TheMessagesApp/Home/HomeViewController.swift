//
//  MainController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class HomeViewController: CoordinatedViewController<HomeCoordinator> {
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubscribers()
        view.backgroundColor = .white
        
        // TODO - Upgrade minimum version to iOS 12
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(logout))
        coordinator.emit(HomeViewDidLoadEvent())
    }
}

private extension HomeViewController {
    func addSubscribers() {
        // TODO - Add dispose bag
        
        let _ = coordinator.title.subscribe() { [weak self] event in
            self?.navigationItem.title = event.element
        }
    }
    
    @objc func logout() {
        coordinator.emit(HomeLogoutButtonTappedEvent())
    }
}

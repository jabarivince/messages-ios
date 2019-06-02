//
//  MainController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class MainController: UIViewController {
    let authenticationService: AuthenticationService = DefaultAuthenticationService()

    var user: User? {
        didSet {
            navigationItem.title = user?.name ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(logout))
        fetchUserInfo()
    }
    
    @objc func logout() {
        authenticationService.logout()
        let loginController = UINavigationController(rootViewController: LoginController())
        present(loginController, animated: true, completion: nil)
    }
    
    func fetchUserInfo() {
        authenticationService.getUser() { [weak self] user in
            guard let self = self else { return }
            self.user = user
        }
    }
}

//
//  AuthenticationService.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import Foundation
import Firebase

protocol AuthenticationService: class {
    var userIsLoggedIn: Bool { get }
    func getUser(completion: ((User?) -> Void)?)
    func createUser(email: String, password: String, name: String, completion: (() -> Void)?)
    func login(email: String, password: String, completion: (() -> Void)?)
    func logout()
}

class DefaultAuthenticationService: AuthenticationService {
    var persistenceService: PersistenceService
    var ref: DatabaseReference
    
    var userIsLoggedIn: Bool {
        return persistenceService.get(.currentUserId) != nil
    }
    
    var currentUserId: String? {
        let uid1 = Auth.auth().currentUser?.uid
        let uid2: String? = persistenceService.get(.currentUserId) as? String? ?? nil
        
        return (uid1 ?? uid2) ?? nil
    }
    
    func createUser(email: String, password: String, name: String, completion: (() -> Void)?) {
        let userData: [String: Any] = [
            "name": name
        ]
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                guard let uid = result?.user.uid else { return }
                self.ref.child("users/\(uid)").setValue(userData)
                self.logout()
                completion?()
            }
        }
    }
    
    func getUser(completion: ((User?) -> Void)?) {
        guard let uid = currentUserId else { return }

        ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard
                let data = snapshot.value as? NSDictionary,
                let username = data["name"] as? String
            else { return }
        
            let user = User(name: username, uid: uid)
            completion?(user)
        }
    }
    
    func login(email: String, password: String, completion: (() -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            guard let self = self else { return }

            if let err = error {
                print(err.localizedDescription)
                
            } else if let uid = user?.user.uid {
                self.persistenceService.set(.currentUserId, value: uid)
                completion?()
            } else {
                // error care
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let err {
            print(err.localizedDescription)
        }
        
        persistenceService.set(.currentUserId, value: nil)
    }
    
    init() {
        persistenceService = DefaultPersistenceService.shared
        ref = Database.database().reference()
    }
}

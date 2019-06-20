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
    func getUser(completion: ((LocalUser?, Error?) -> Void)?)
    func createUser(from request: SignupSubmissionRequest, completion: ((Error?) -> Void)?)
    func login(email: String, password: String, completion: ((User?, Error?) -> Void)?)
    func logout()
}

class DefaultAuthenticationService: AuthenticationService {
    internal var persistenceService: PersistenceService
    internal var ref: DatabaseReference
    static let shared = DefaultAuthenticationService()
    
    var userIsLoggedIn: Bool {
        return persistenceService.get(.currentUserId) != nil
    }
    
    func createUser(from request: SignupSubmissionRequest, completion: ((Error?) -> Void)?) {
        let userData: [String: Any] = [
            "name": request.name
        ]
        
        if request.password != request.confirmPassword {
            let error = SignupError("Passwords must match")
            completion?(error)
        }
        
        Auth.auth().createUser(withEmail: request.email, password: request.password) { [weak self] (result, error) in
            if let err = error {
                completion?(err)
            } else {
                guard let uid = result?.user.uid else { return }
                
                self?.ref.child("users/\(uid)").setValue(userData)
                self?.logout()
                completion?(nil)
            }
        }
    }
    
    func getUser(completion: ((LocalUser?, Error?) -> Void)?) {
        guard let user = Auth.auth().currentUser else {
            completion?(nil, GetUserError("No id for current user"))
            return
        }
        
        ref.child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            guard
                let data = snapshot.value as? NSDictionary,
                let username = data["name"] as? String
            else {
                completion?(nil, GetUserError("Malformed data returned from service"))
                return
            }
        
            let user = LocalUser(name: username, uid: user.uid, user: user)
            completion?(user, nil)
        }
    }
    
    func login(email: String, password: String, completion: ((User?, Error?) -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }

            if let err = error {
                completion?(nil, err)
                
            } else if let user = result?.user {
                self.persistenceService.set(.currentUserId, value: user.uid)
                completion?(user, nil)
            } else {
                // error case
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        
        persistenceService.set(.currentUserId, value: nil)
    }
    
    private init() {
        persistenceService = DefaultPersistenceService.shared
        ref = Database.database().reference()
    }
}

class SignupError: CustomError {}
class GetUserError: CustomError {}

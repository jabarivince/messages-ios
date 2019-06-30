//
//  AuthenticationService.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import Firebase
import Foundation

protocol AuthenticationService: class {
    var userIsLoggedIn: Bool { get }
    func getUser(completion: ((LocalUser?, Error?) -> Void)?)
    func createUser(from request: SignupSubmissionRequest, completion: ((Error?) -> Void)?)
    func login(email: String, password: String, completion: ((User?, Error?) -> Void)?)
    func logout()
}

class DefaultAuthenticationService: AuthenticationService {
    static let shared = DefaultAuthenticationService()
    private let ref   = Database.database().reference()
    private let auth  = Auth.auth()
    
    var userIsLoggedIn: Bool {
        return auth.currentUser != nil
    }
    
    func createUser(from request: SignupSubmissionRequest, completion: ((Error?) -> Void)?) {
        let userData: [String: Any] = [
            "name": request.name
        ]
        
        if request.password != request.confirmPassword {
            let error = Exception("Passwords must match")
            completion?(error)
        }
        
        auth.createUser(withEmail: request.email, password: request.password) { [weak self] (result, error) in
            if let err = error {
                completion?(err)
            } else {
                guard let uid = result?.uid else { return }
                
                self?.ref.child("users/\(uid)").setValue(userData)
                self?.logout()
                completion?(nil)
            }
        }
    }
    
    func getUser(completion: ((LocalUser?, Error?) -> Void)?) {
        guard let user = auth.currentUser else {
            completion?(nil, Exception("No id for current user"))
            return
        }
        
        ref.child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
            guard
                let data = snapshot.value as? NSDictionary,
                let username = data["name"] as? String
            else {
                completion?(nil, Exception("Malformed data returned from service"))
                return
            }
        
            let user = LocalUser(name: username, user: user,uid: user.uid)
            completion?(user, nil)
        }
    }
    
    func login(email: String, password: String, completion: ((User?, Error?) -> Void)?) {
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if let err = error {
                completion?(nil, err)
                
            } else if let user = result {
                completion?(user, nil)
            }
        }
    }
    
    func logout() {
        try? auth.signOut()
    }
    
    private init() {}
}

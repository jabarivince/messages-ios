//
//  SignupSubmissionRequest.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import Foundation

struct SignupSubmissionRequest {
    let email: String
    let password: String
    let confirmPassword: String
    let name: String
    
    init(email: String?, password: String?, confirmPassword: String?, name: String?) {
        self.email = email ?? ""
        self.password = password ?? ""
        self.confirmPassword = confirmPassword ?? ""
        self.name = name ?? ""
    }
}

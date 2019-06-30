//
//  CustomError.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import Foundation

struct Exception: LocalizedError {
    var errorDescription: String? {
        return message
    }
    
    private let message: String
    
    init(_ message: String) {
        self.message = NSLocalizedString(message, comment: "Custom error")
    }
}

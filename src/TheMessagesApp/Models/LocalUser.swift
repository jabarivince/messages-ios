//
//  AppUser.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import Firebase

struct LocalUser: Equatable, Hashable {
    var name: String?
    var user: User
    var uid: String? // TODO - Convert to computed property
}

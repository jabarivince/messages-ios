//
//  CoordinatedViewController.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import UIKit

class CoordinatedViewController<T: Coordinator>: UIViewController {
    internal lazy var coordinator = T.init(self)
}

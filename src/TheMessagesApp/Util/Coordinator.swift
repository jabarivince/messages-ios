//
//  Coordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/16/19.
//

import UIKit

protocol ActionEvent: Hashable { }

class Coordinator {
    private var events: [ObjectIdentifier: [Any]] = [:]
    internal weak var viewController: UIViewController!
    
    func emit<T: ActionEvent>(_ event: T) {
        let id = ObjectIdentifier(type(of: event))
        
        if let observers = events[id] as? [(T) -> Void] {
            observers.forEach { observer in
                observer(event)
            }
        } else {
            // Error state
        }
    }
    
    func observe<T: ActionEvent>(_ eventType: T.Type, completion: @escaping (T) -> Void) {
        let id = ObjectIdentifier(eventType)
        var observers = events[id] ?? []
        observers.append(completion)
        events[id] = observers
    }
        
    required init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}


//
//  Coordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/16/19.
//

import UIKit

protocol ActionEvent: Hashable { }

protocol ViewModel {
    init()
}

class Coordinator<E: ViewModel> {
    private var events: [ObjectIdentifier: [Any]] = [:]
    weak var viewController: UIViewController?
    var viewModel: E
    
    func emit<T: ActionEvent>(_ event: T) {
        let id = ObjectIdentifier(type(of: event))
        
        if let observers = events[id] as? [(T) -> Void] {
            observers.forEach { observer in
                observer(event)
            }
        }
    }
    
    func observe<T: ActionEvent>(_ eventType: T.Type, completion: @escaping (T) -> Void) {
        let id = ObjectIdentifier(eventType)
        events[id] = (events[id] ?? []) + [completion]
    }
    
    required init(_ viewController: UIViewController) {
        self.viewController = viewController
        viewModel = E.init()
    }
}

extension Coordinator {
    func navigate<U: UIViewController>(to controller: U.Type) {
        let controller = UINavigationController(rootViewController: U.init())
        viewController?.present(controller, animated: true, completion: nil)
    }
    
    func push<U: UIViewController>(_ controller: U.Type) {
        viewController?.navigationController?.pushViewController(U.init(), animated: true)
    }
    
    func present<U: UIViewController>(_ controller: U.Type) {
        viewController?.present(U.init(), animated: true, completion: nil)
    }
    
    func pop() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}

extension Coordinator {
    func alert(_ message: String, title: String? = nil, completion: (() -> Void)? = nil) {
        viewController?.alert(message, title: title, completion: completion)
    }
    
    func alert<U: Error>(_ error: U, title: String = "Oops!", completion: (() -> Void)? = nil) {
        alert(error.localizedDescription, title: title, completion: completion)
    }
    
    func prompt(_ message: String,
                title: String? = nil,
                cancelButtonText: String = "Cancel",
                continueButtonText: String = "Continue",
                completion: @escaping () -> Void) {
        
        viewController?.promptToContinue(
            message,
            title: title,
            cancelButtonText: cancelButtonText,
            continueButtonText: continueButtonText,
            completion: completion
        )
    }
    
    func promptForText(title: String,
                       message: String? = nil,
                       placeholder: String?,
                       confirmButtonText: String = "Ok",
                       cancelButtonText: String = "Cancel",
                       completion: @escaping (String) -> Void) {
        
        viewController?.promptForText(
            title: title,
            message: message,
            placeholder: placeholder,
            confirmButtonText: confirmButtonText,
            cancelButtonText: cancelButtonText,
            completion: completion
        )
    }
}

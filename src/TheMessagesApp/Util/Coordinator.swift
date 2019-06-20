//
//  Coordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/16/19.
//

import UIKit

/**
 * Marker protocol for use in `Coordinator`. `ViewModel` intentionally
 * requires an `init()` with zero arguments so that it can be initialized
 * within the `Coordinator`. That way, the `coordinator.viewModel` property does not
 * have to be optional, nor do we need a protocol that requires conforming
 * objects to implement a `viewModel` property.
 */
protocol ViewModel {
    init()
}

/**
 * Marker protocol for use in `Coordinator`.
 */
protocol ActionEvent: Hashable { }

/**
 * ## Implementation details
 * A Coordinator keeps a map called events where keys are
 * metatypes of some type `T` that subclasses ActionEvent. The values are
 * arrays of closures that accept instances of the `ActionEvent` of type `T`.
 *
 * ## Properties
 * - `events`: `Dictionary` of closures by event type.
 * - `viewModel`: A reference to an object that holds all of the coordinator's state.
 * - `viewController`: A reference to the `UIViewController` to handle navigation.
 
 * ## Functions
 * - `observe()`: Adds a closure to the map by event type `T`.
 * - `emit()`: Executes all of the associated closures (in series) for the specified event type `T`.
 */
class Coordinator<E: ViewModel> {
    private var events: [ObjectIdentifier: [Any]] = [:]
    weak var viewController: UIViewController!
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


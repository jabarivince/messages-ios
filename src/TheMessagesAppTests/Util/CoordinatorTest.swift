//
//  CoordinatorTest.swift
//  TheMessagesApp
//
//  Created by jabari on 6/18/19.
//

import Quick
import Nimble
@testable import TheMessagesApp

class CoordinatorSpec: QuickSpec {
    struct TestViewModel: ViewModel {
        var value = 0
    }
    
    struct TestEvent: ActionEvent {
        let value: Int
    }
    
    class TestCoordinator: Coordinator<TestViewModel> {
        required init(_ viewController: UIViewController) {
            super.init(viewController)
            
            observe(TestEvent.self) { [weak self] event in
                self?.viewModel.value = event.value
            }
        }
    }
    
    override func spec() {
        describe("Basic functionality") {
            it("Test that observer updates view model") {
                let coordinator = TestCoordinator(UIViewController())
                let value = Int.random(in: .min...Int.max)
                
                coordinator.emit(TestEvent(value: value))
                expect(coordinator.viewModel.value).to(equal(value))
            }
        }
    }
}

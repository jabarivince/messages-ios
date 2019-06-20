//
//  ObservableType+Extension.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import RxSwift

extension ObservableType {
    func subscribe(bag: DisposeBag, _ on: @escaping (RxSwift.Event<Self.Element>) -> Void) {
        subscribe(on).disposed(by: bag)
    }
}

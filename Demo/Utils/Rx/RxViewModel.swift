//
//  RxViewModel.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class Event {} // represent a UI event

protocol RxViewModelProtocol {
    var events: BehaviorRelay<Event> { get }
    var currentEvent: Event { get }
}

open class RxViewModel: NSObject, RxViewModelProtocol {
    
    // MARK: Private constants
    private let disposeBag = DisposeBag()
    
    // MARK: Public properties
    private var _events = BehaviorRelay<Event>(value: Event())
    var events: BehaviorRelay<Event> {
        return _events
    }
    
    var currentEvent: Event {
        return self.events.value
    }
    
    // MARK: Public methods
    func launch(_ rx: () -> Disposable) {
        rx().disposed(by: self.disposeBag)
    }
    
    
}

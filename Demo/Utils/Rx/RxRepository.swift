//
//  RxRepository.swift
//  Unsplash
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import Foundation
import RxSwift

open class RxRepository: NSObject {
    
    // MARK: Private constants
    private let disposeBag = DisposeBag()
    
    // MARK: Public methods
    func launch(_ rx: () -> Disposable) {
        rx().disposed(by: self.disposeBag)
    }
    
    
}

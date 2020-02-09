//
//  RxViewController.swift
//  Unsplash
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import UIKit
import RxSwift
import ObjectiveC

var disposeBagHandle: UInt8 = 0

private func synchronized<T>(_ obj: AnyObject, _ closure: () -> T) -> T {
    objc_sync_enter(obj)
    defer { objc_sync_exit(obj) }
    return closure()
}

extension UIViewController {
    
    private var disposeBag: DisposeBag {
        get {
            return synchronized(self) {
                return objc_getAssociatedObject(self, &disposeBagHandle)
                    ?? {
                        let newDisposeBag = DisposeBag()
                        objc_setAssociatedObject(self, &disposeBagHandle, newDisposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                        return newDisposeBag
                    }()
                } as! DisposeBag
        }
        
        set {
            synchronized(self) {
                objc_setAssociatedObject(self, &disposeBagHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func launch(_ rx: () -> Disposable?) {
        rx()?.disposed(by: self.disposeBag)
    }
    
}



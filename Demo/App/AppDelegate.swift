//
//  AppDelegate.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 05/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import UIKit
import Dip
import UnsplasherSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Public constant
    var window: UIWindow?
    
    // MARK: - Public constant
    let diContainer = DependencyContainer { container in
        unowned let container = container
        container.configure()
        try! container.bootstrap() // lock container
        DependencyContainer.uiContainers = [container]
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Unsplash.configure(appId: "746c15ffc9ff3bb230304e0d038a976e6127f0dc19953a6547790800b29d4c0e", secret: "4752c5bbad272317bde4e09b70b8a4c9816c122618cde92c1797390583b54f53", scopes: Unsplash.PermissionScope.allCases)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: PhotosViewController.instantiate())
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        return true
    }

}


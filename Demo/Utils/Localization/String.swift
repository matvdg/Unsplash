//
//  String.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import Foundation

extension String {
    // Returns localized String
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

}

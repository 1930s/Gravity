//
//  UserDefaults.swift
//  ARKitBasics
//
//  Created by Alexander Pagliaro on 4/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

enum UserDefaultKeys: String {
    case currentObjectType
    case lastUsedObject
    case recentlyUsedObjects
    case lastUsedTextAttributesForTypes
}

class UserDefaultsManager {
    class func set(value: Any?, for key: UserDefaultKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    class func value(for key: UserDefaultKeys) -> Any? {
        return UserDefaults.standard.value(forKey: key.rawValue)
    }
}

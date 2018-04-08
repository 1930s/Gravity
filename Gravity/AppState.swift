//
//  AppState.swift
//  ARKitBasics
//
//  Created by Alexander Pagliaro on 4/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import SceneKit
import ARKit

struct AppState {
    var objects: [Object] = []
}

enum ObjectType: RawRepresentable {
    case text(TextObjectType)
    init?(rawValue: Int) {
        switch rawValue {
        case 0...3:
            self = ObjectType.text(TextObjectType(rawValue: rawValue)!)
        default:
            self = .text(.twoDimensional)
        }
    }
    var rawValue: Int {
        switch self {
        case .text(let type):
            return type.rawValue
        }
    }
}

enum TextObjectType: Int {
    case twoDimensional
    case threeDimensional
    case nth
    case ribbon
}

struct Object {
    var type: ObjectType
    var text: String?
    var textAttributes: TextAttributes?
    var backgroundColor: UIColor?
}

struct TextAttributes {
    var fontName: String?
    var fontSize: String?
    var textColor: UIColor?
    var strokeWidth: CGFloat?
    var strokeColor: UIColor?
}

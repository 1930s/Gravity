//
//  AppState.swift
//  ARKitBasics
//
//  Created by Alexander Pagliaro on 4/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import SceneKit
import ARKit

struct AppState: Codable {
    var objects: [Object] = []
    var currentObject: Object = Object(type: .text(.ribbon))
    var recentObjects: [Object] = []
    enum CodingKeys: String, CodingKey {
        case currentObject
        case recentObjects
    }
}

enum ObjectType: RawRepresentable, Codable {
    case text(TextObjectType) // 0...10
    case shape(ShapeObjectType) // 100...110
    init?(rawValue: Int) {
        switch rawValue {
        case 0...3:
            self = ObjectType.text(TextObjectType(rawValue: rawValue)!)
        case 100...200:
            self = ObjectType.shape(ShapeObjectType(rawValue: rawValue)!)
        default:
            self = .text(.twoDimensional)
        }
    }
    var rawValue: Int {
        switch self {
        case .text(let type):
            return type.rawValue
        case .shape(let type):
            return type.rawValue
        }
    }
}

// 0...10
enum TextObjectType: Int, Codable {
    case twoDimensional = 0
    case threeDimensional = 1
    case nth = 2
    case ribbon = 3
}
// 100...
enum ShapeObjectType: Int, Codable {
    case arrow = 100
}
// 1000...
enum MediaObjectType: Int, Codable {
    case image = 1000
}

struct Object: Codable, Hashable {
    var identifier: UUID = UUID()
    var type: ObjectType
    var text: String?
    var textAttributes: TextAttributes = TextAttributes()
    var backgroundColor: UIColor?
    
    var hashValue: Int {
        return identifier.hashValue
    }
    static func ==(lhs: Object, rhs: Object) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case textAttributes
        case backgroundColor
    }
    
    init(type: ObjectType) {
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(ObjectType.self, forKey: .type)
        text = try values.decodeIfPresent(String.self, forKey: .text)
        textAttributes = try values.decode(TextAttributes.self, forKey: .textAttributes)
        if let colorData = try values.decodeIfPresent(Data.self, forKey: .backgroundColor) {
            backgroundColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(textAttributes, forKey: .textAttributes)
        if let color = backgroundColor {
            try container.encode(NSKeyedArchiver.archivedData(withRootObject: color), forKey: .backgroundColor)
        }
    }
    
    func fontName() -> String {
        return textAttributes.fontName ?? fontNames[0]
    }
    
    func getText() -> String {
        return text ?? "Hello World"
    }
    
    func fontSize() -> CGFloat {
        return textAttributes.fontSize ?? 30.0
    }
    
    func textColor() -> UIColor {
        return textAttributes.textColor ?? UIColor.white
    }
}

struct TextAttributes: Codable {
    var fontName: String?
    var fontSize: CGFloat?
    var textColor: UIColor?
    var strokeWidth: CGFloat?
    var strokeColor: UIColor?
    
    enum CodingKeys: String, CodingKey {
        case fontName
        case fontSize
        case textColor
        case strokeWidth
        case strokeColor
    }
    
    init() {
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fontName = try values.decodeIfPresent(String.self, forKey: .fontName)
        fontSize = try values.decodeIfPresent(CGFloat.self, forKey: .fontSize)
        strokeWidth = try values.decodeIfPresent(CGFloat.self, forKey: .strokeWidth)
        if let textColorData = try values.decodeIfPresent(Data.self, forKey: .textColor) {
            textColor = NSKeyedUnarchiver.unarchiveObject(with: textColorData) as? UIColor
        }
        if let strokeColorData = try values.decodeIfPresent(Data.self, forKey: .strokeColor) {
            strokeColor = NSKeyedUnarchiver.unarchiveObject(with: strokeColorData) as? UIColor
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fontName, forKey: .fontName)
        try container.encodeIfPresent(fontSize, forKey: .fontSize)
        try container.encodeIfPresent(strokeWidth, forKey: .strokeWidth)
        if let textColor = textColor {
            try container.encodeIfPresent(NSKeyedArchiver.archivedData(withRootObject: textColor), forKey: .textColor)
        }
        if let strokeColor = strokeColor {
            try container.encodeIfPresent(NSKeyedArchiver.archivedData(withRootObject: strokeColor), forKey: .strokeColor)
        }
    }
}

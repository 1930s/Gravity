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
    case media(MediaObjectType) // 1000...1100
    init?(rawValue: Int) {
        switch rawValue {
        case 0...3:
            self = ObjectType.text(TextObjectType(rawValue: rawValue)!)
        case 100...200:
            self = ObjectType.shape(ShapeObjectType(rawValue: rawValue)!)
        case 1000...1100:
            self = ObjectType.media(MediaObjectType(rawValue: rawValue)!)
        default:
            self = .text(.ribbon)
        }
    }
    var rawValue: Int {
        switch self {
        case .text(let type):
            return type.rawValue
        case .shape(let type):
            return type.rawValue
        case .media(let type):
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
    case location = 101
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
    var mediaURL: URL? {
        get {
            do {
                let mediaURL = identifier.uuidString.appending(".jpg")
                let mediaFolder = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("media", isDirectory: true)
                if FileManager.default.fileExists(atPath: mediaFolder.absoluteString) == false {
                    try FileManager.default.createDirectory(at: mediaFolder, withIntermediateDirectories: true, attributes: nil)
                }
                let url = mediaFolder.appendingPathComponent(mediaURL)
                return url
            } catch {
                print(error)
            }
            return nil
        }
    }
    var image: UIImage? {
        get {
            guard let mediaURL = mediaURL else { return nil }
            return UIImage(contentsOfFile: mediaURL.absoluteString)
        }
    }
    
    var hashValue: Int {
        return identifier.hashValue
    }
    
    static func ==(lhs: Object, rhs: Object) -> Bool {
        return lhs.type == rhs.type && lhs.text == rhs.text && lhs.textAttributes == rhs.textAttributes && lhs.backgroundColor == rhs.backgroundColor && lhs.identifier == rhs.identifier
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case type
        case text
        case textAttributes
        case backgroundColor
    }
    
    init(type: ObjectType) {
        self.type = type
        switch type {
        case .text(_):
            self.text = randomQuote()
        default:
            break
        }
    }
    
    func randomQuote() -> String? {
        guard let url = Bundle.main.url(forResource: "Quotes", withExtension: "plist") else { return nil }
        guard let quotes = NSArray(contentsOf: url) as? [String] else { return nil }
        guard quotes.count > 0 else { return nil }
        let randomIndex = arc4random_uniform(UInt32(quotes.count))
        return quotes[Int(randomIndex)]
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(UUID.self, forKey: .identifier)
        type = try values.decode(ObjectType.self, forKey: .type)
        text = try values.decodeIfPresent(String.self, forKey: .text)
        textAttributes = try values.decode(TextAttributes.self, forKey: .textAttributes)
        if let colorData = try values.decodeIfPresent(Data.self, forKey: .backgroundColor) {
            backgroundColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
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
        return textAttributes.textColor ?? UIColor.gravityBlue()
    }
}

struct TextAttributes: Codable, Equatable {
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

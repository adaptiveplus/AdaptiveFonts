//
//  Font.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

import Foundation

public struct Font {

    /// The font variant.
    ///
    /// - regular: Regular.
    /// - _700: Bold.
    /// - italic: Italic.
    /// - _700italic: BoldItalic.
    public enum Variant: String, Codable {
        case thin = "100"
        case thinItalic = "100italic"
        case extralight = "200"
        case extralightItalic = "200italic"
        case light = "300"
        case lightItalic = "300italic"
        case regular = "regular"
        case regularItalic = "italic"
        case medium = "500"
        case mediumItalic = "500italic"
        case semibold = "600"
        case semiboldItalic = "600italic"
        case bold = "700"
        case boldItalic = "700italic"
        case extrabold = "800"
        case extraboldItalic = "800italic"
        case black = "900"
        case blackItalic = "900italic"
    }

    /// The font family.
    public let family: String

    /// The font variant.
    public let variant: Variant

    var name: String {
        return "\(family)-\(String(describing: variant).capitalizingFirstLetter())"
    }
    
    var idName: String {
        return "\(family)-\(variant.rawValue)"
    }

    var filename: String {
        return "\(name).ttf"
    }

    /// Create a new font struct.
    ///
    /// - Parameters:
    ///   - family: The font family.
    ///   - variant: The font variant.
    public init(family: String, variant: Variant) {
        self.family = family
        self.variant = variant
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

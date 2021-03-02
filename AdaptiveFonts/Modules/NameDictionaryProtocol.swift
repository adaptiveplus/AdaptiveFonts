//
//  NameDictionary.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

import Foundation
import UIKit

protocol NameDictionaryProtocol {

    func postscriptName(for font: Font) -> String?
    func setPostscriptName(_ name: String, for font: Font) -> Bool
}

final class NameDictionary: NameDictionaryProtocol {
    private let storage: Storable
    private var cache: NSMutableDictionary?

    init(storage: Storable) {
        self.storage = storage
    }

    // MARK: - Interface

    /// Get the postscript name of specified font.
    ///
    /// - Parameter font: The font needed to get the postscript name.
    /// - Returns: The postscript name.
    func postscriptName(for font: Font) -> String? {
        guard let nameDictionary = cache ?? NSMutableDictionary(contentsOf: storage.nameDictionaryURL) else {
            return nil
        }

        if cache == nil {
            cache = nameDictionary
        }

        return lookUpPostscriptName(for: font) ??
            (nameDictionary.value(forKey: font.idName) as? String)
    }

    /// Set the postscript name of specified font.
    ///
    /// - Parameters:
    ///   - name: The postscript name.
    ///   - font: The font needed to get the postscript name.
    /// - Returns: `true` if set successfully, otherwise `false`.
    @discardableResult func setPostscriptName(_ name: String, for font: Font) -> Bool {
        let URL = storage.nameDictionaryURL
        let nameDictionary = cache ?? NSMutableDictionary(contentsOf: URL) ?? NSMutableDictionary(capacity: 1)

        nameDictionary.setValue(name, forKey: font.idName)
        if cache == nil {
            cache = nameDictionary
        }

        return nameDictionary.write(to: URL, atomically: true)
    }

    // MARK: - Helpers

    /// Try to look up the postscript name of specified font from registered fonts.
    ///
    /// - Parameter font: The font needed to get the postscript name.
    /// - Returns: The postscript name.
    private func lookUpPostscriptName(for font: Font) -> String? {
        let fontNames = UIFont.fontNames(forFamilyName: font.family)
        let filteredFontNames = fontNames.filter { (fontName) in
            return font.name.lowercased() == fontName.lowercased()
        }

        return filteredFontNames.count > 0 ? filteredFontNames[0] : nil
    }

    private func regexMatches(_ regex: NSRegularExpression, string: String) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        
        return regex.matches(in: string, options: [], range: range).count > 0
    }
}

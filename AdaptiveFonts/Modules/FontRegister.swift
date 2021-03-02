//
//  FontRegister.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

import Foundation
import CoreText

/// The class to register font.
final class FontRegister {
    private let storage: Storable
    private let nameDictionary: NameDictionaryProtocol

    init(storage: Storable, nameDictionary: NameDictionaryProtocol) {
        self.storage = storage
        self.nameDictionary = nameDictionary
    }

    /// Register the font.
    ///
    /// - Parameter font: The font.
    /// - Returns: `true` if successful, otherwise `false.
    @discardableResult func register(_ font: Font) -> Bool {
        guard let data = try? Data(contentsOf: storage.URL(for: font)),
            let provider = CGDataProvider(data: data as CFData) else {
                return false
        }

        let cgfont = CGFont(provider)

        if let cgfont = cgfont {
            guard CTFontManagerRegisterGraphicsFont(cgfont, nil) else { return false }
            guard let postscriptName = cgfont.postScriptName as String?,
                nameDictionary.setPostscriptName(postscriptName, for: font) else {
                    CTFontManagerUnregisterGraphicsFont(cgfont, nil)

                    return false
            }
        } else {
            return false
        }
        
        return true
    }
}


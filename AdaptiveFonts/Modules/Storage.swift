//
//  Storage.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//
import Foundation

protocol Storable {
    var nameDictionaryURL: URL { get }

    func URL(for font: Font) -> URL
}

final class Storage: Storable {
    private let metadataFile = "googleFonts.json"
    private let nameDictionaryFile = "nameDictionary.plist"

    /// The URL to Google Fonts metadata file.
    lazy var metadataURL: URL = {
        return self.domainURL.appendingPathComponent(self.metadataFile)
    }()

    /// The URL to name dictionary file.
    lazy var nameDictionaryURL: URL = {
        return self.domainURL.appendingPathComponent(self.nameDictionaryFile)
    }()

    lazy var domainURL: URL = {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentURL
    }()

    /// Check if the file of specified font exists.
    ///
    /// - Parameter font: The font needed to check its file.
    /// - Returns: `true` if the file exists, otherwise `false`.
    func fileExists(for font: Font) -> Bool {
        let fontURL = domainURL.appendingPathComponent("\(font.filename)")

        return FileManager.default.fileExists(atPath: fontURL.path)
    }

    /// Check if the Google Fonts metadata file exists.
    ///
    /// - Returns: `true` if the file exists, otherwised `false`.
    func googleFontsMetadataExists() -> Bool {
        return FileManager.default.fileExists(atPath: metadataURL.path)
    }

    func URL(for font: Font) -> URL {
        return domainURL.appendingPathComponent("\(font.filename)")
    }

    func removeGoogleFontsMetadata() {
        try? FileManager.default.removeItem(at: metadataURL)
    }
}

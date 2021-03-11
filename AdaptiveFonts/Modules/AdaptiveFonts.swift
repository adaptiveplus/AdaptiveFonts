//
//  AdaptiveFonts.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

import Foundation
import UIKit

public final class AdaptiveFonts {
    /// The shared instance.
    public static let shared = AdaptiveFonts()

    /// The Google API key used for Google Fonts.
    public var APIKey: String = "" {
        didSet {
            googleFontsMetadata.APIKey = APIKey
        }
    }

    private static let domain = "AdaptiveFonts"
    private let queue: DispatchQueue
    private let storage: Storage
    private let nameDictionary: NameDictionary
    private let fontRegister: FontRegister
    private let fontDownloader: FontDownloader
    private let googleFontsMetadata: GoogleFontsMetadata
    private let operationQueue: OperationQueue

    // MARK: - Init

    private init() {
        queue = DispatchQueue(label: AdaptiveFonts.domain)
        storage = Storage()
        nameDictionary = NameDictionary(storage: storage)
        fontRegister = FontRegister(storage: storage, nameDictionary: nameDictionary)
        fontDownloader = FontDownloader(storage: storage, queue: queue)
        googleFontsMetadata = GoogleFontsMetadata(APIKey: APIKey, storage: storage, queue: queue)
        operationQueue = OperationQueue()
        operationQueue.name = AdaptiveFonts.domain
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility
        operationQueue.underlyingQueue = queue
    }

    // MARK: - Public interface

    /// Create the `UIFont` with specified font information.
    ///
    /// - Note: Google Fonts has higher priority
    ///         that means the `at` param is only used unless the given font
    ///         information is found on Google Fonts, otherwise the `at` param
    ///         is ignored.
    ///
    /// - Parameters:
    ///   - font: The font information.
    ///   - size: The font size.
    ///   - at: The URL used to download the font file. Default is `nil`.
    ///   - completion: The completion handler.
    /// - Returns: The font operation.
    @discardableResult
    public func font(for font: Font,
                     size: CGFloat,
                     at url: URL? = nil,
                     completion: @escaping (UIFont?) -> Void) -> FontOperation {
        let operation = InternalFontOperation(storage: storage,
                                              nameDictionary: nameDictionary,
                                              fontRegister: fontRegister,
                                              fontDownloader: fontDownloader,
                                              googleFontsMetadata: googleFontsMetadata,
                                              font: font,
                                              size: size,
                                              url: url) { uifont in
                                                DispatchQueue.main.async {
                                                    completion(uifont)
                                                }
        }

        operationQueue.addOperation(operation)

        return FontOperation(operation: operation)
    }
    
    /// Create the `UIFont` with specified font information.
    ///
    /// - Note: Google Fonts has higher priority
    ///         that means the `at` param is only used unless the given font
    ///         information is found on Google Fonts, otherwise the `at` param
    ///         is ignored.
    ///
    /// - Parameters:
    ///   - font: The font information.
    ///   - size: The font size.
    ///   - at: The URL used to download the font file. Default is `nil`.
    /// - Returns: The font.
    @discardableResult
    public func fontSync(for font: Font,
                     size: CGFloat,
                     at url: URL? = nil) -> UIFont? {
        var foundFount: UIFont? = nil
        let operation = InternalFontOperation(storage: storage,
                                              nameDictionary: nameDictionary,
                                              fontRegister: fontRegister,
                                              fontDownloader: fontDownloader,
                                              googleFontsMetadata: googleFontsMetadata,
                                              font: font,
                                              size: size,
                                              url: url) { uifont in
                                                foundFount = uifont
                                              }
        
        operationQueue.addOperation(operation)
        operation.waitUntilFinished()
        return foundFount
    }
}

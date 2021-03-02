//
//  FontOperation.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

import Alamofire

/// The font operation.
public final class FontOperation {
    private let operation: InternalFontOperation

    init(operation: InternalFontOperation) {
        self.operation = operation
    }
    
    public func waitUntilFinished() {
        self.operation.waitUntilFinished()
    }

    /// Cancel the operation.
    public func cancel() {
        operation.cancel()
    }
}

final class InternalFontOperation: Operation {
    typealias Completion = (UIFont?) -> Void

    private let storage: Storage
    private let nameDictionary: NameDictionary
    private let fontRegister: FontRegister
    private let fontDownloader: FontDownloader
    private let googleFontsMetadata: GoogleFontsMetadata
    private let font: Font
    private let size: CGFloat
    private let url: URL?
    private let completion: Completion
    private var metadataRequest: DownloadRequest?
    private var downloadRequest: DownloadRequest?

    // MARK: - Init

    init(storage: Storage,
         nameDictionary: NameDictionary,
         fontRegister: FontRegister,
         fontDownloader: FontDownloader,
         googleFontsMetadata: GoogleFontsMetadata,
         font: Font,
         size: CGFloat,
         url: URL?,
         completion: @escaping Completion) {
        self.storage = storage
        self.nameDictionary = nameDictionary
        self.fontRegister = fontRegister
        self.fontDownloader = fontDownloader
        self.googleFontsMetadata = googleFontsMetadata
        self.font = font
        self.size = size
        self.url = url
        self.completion = completion

        super.init()
    }

    // MARK: - Override

    override var isAsynchronous: Bool { return true }

    private var _isExecuting: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    override var isExecuting: Bool { return _isExecuting }

    private var _isFinished: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    override var isFinished: Bool { return _isFinished }

    override func start() {
        guard !isCancelled else {
            finish()

            return
        }

        _isExecuting = true

        if let postscriptName = nameDictionary.postscriptName(for: font),
            let _ = UIFont(name: postscriptName, size: size) {
            finish()

            return
        }

        if storage.fileExists(for: font) {
            register(font)
            finish()
        } else if self.googleFontsMetadata.exist() {
            download(font, familyDictionary: nil) { result in
                switch result {
                case .success:
                    self.register(self.font)
                    self.finish()
                case .failure:
                    self.fail()
                }
            }
        } else {
            fetchGoogleFontsMetadata { fetchResult in
                switch fetchResult {
                case .success(let familyDictionary):
                    guard !self.isCancelled else {
                        self.finish()

                        return
                    }

                    self.download(self.font, familyDictionary: familyDictionary) { downloadResult in
                        switch downloadResult {
                        case .success:
                            self.register(self.font)
                            self.finish()
                        case .failure:
                            self.fail()
                        }
                    }
                case .failure: self.fail()
                }
            }
        }
    }

    // MARK: - Helpers

    private func fetchGoogleFontsMetadata(completion: @escaping (Result<GoogleFontsMetadata.FamilyDictionary>) -> Void) {
        metadataRequest = googleFontsMetadata.fetch(completion: completion)
    }

    private func download(_ font: Font,
                          familyDictionary: GoogleFontsMetadata.FamilyDictionary?,
                          completion: @escaping (Result<URL>) -> Void) {
        var candidateURL: URL?

        if let file = googleFontsMetadata.file(of: font, familyDictionary: familyDictionary),
            let url = URL(string: file) {
            candidateURL = url
        }
        if candidateURL == nil {
            candidateURL = self.url
        }

        guard let url = candidateURL else {
            completion(.failure(nil))

            return
        }

        downloadRequest = fontDownloader.download(font, at: url, completion: completion)
    }

    private func register(_ font: Font) {
        fontRegister.register(font)
    }

    private func finish() {
        defer {
            _isExecuting = false
            _isFinished = true
        }
        guard !isCancelled else { return }
        guard let postscriptName = nameDictionary.postscriptName(for: font),
            let uifont = UIFont(name: postscriptName, size: size)
            else {
                completion(nil)

                return
        }

        completion(uifont)
    }
    
    private func fail() {
        defer {
            _isExecuting = false
            _isFinished = true
        }
        guard !isCancelled else { return }
        
        completion(nil)
    }
}


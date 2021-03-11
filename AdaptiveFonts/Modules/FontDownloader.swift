//
//  FontDownloader.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

final class FontDownloader {
    private let storage: Storage
    private let queue: DispatchQueue?

    init(storage: Storage, queue: DispatchQueue?) {
        self.storage = storage
        self.queue = queue
    }
    

    /// Download the font at specified URL.
    ///
    /// - Parameters:
    ///   - font: The font.
    ///   - URL: The URL
    ///   - completion: The completion handler.
    /// - Returns: The download request.
    func download(_ font: Font, at url: URL, completion: @escaping (Result<URL>) -> Void) {
        let storageURL = storage.URL(for: font)
        
        AdaptiveFontsNetworkLayer.download(url: url, to: storageURL, httpType: .get) { (response) in
            switch response {
            case .failure(let error):
                completion(.failure(error))
            case .success(let urlPath):
                completion(.success(urlPath))
            }
        }
    }
}

//
//  FontDownloader.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

import Alamofire

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
    func download(_ font: Font, at URL: URL, completion: @escaping (Result<URL>) -> Void) -> DownloadRequest {
        let storageURL = storage.URL(for: font)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)

        return AF.download(URL, to: destination)
            .response(queue: queue ?? DispatchQueue.main) { response in
                if let error = response.error {
                    completion(.failure(error))
                } else {
                    completion(.success(storageURL))
                }
        }
    }
}

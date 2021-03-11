//
//  AdaptiveFontsNetworkLayer.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 03.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case del = "DELETE"
}

final class AdaptiveFontsNetworkLayer {
    /// The shared instance.
    
    public static let shared = AdaptiveFontsNetworkLayer()
    private let fileManager = FileManager.default
    typealias Destination = (_ temporaryURL: URL, _ response: HTTPURLResponse) -> (URL)
    
    public class func download(url: URL, to file: URL, httpType: HTTPMethod, completion: @escaping (Result<URL>) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let targetURL = documentURL.appendingPathComponent(file.lastPathComponent)
        
        let downloadTask = session.downloadTask(with: request) { (tempURL, response, error) in
            guard let tempURL = tempURL, error == nil else {
                completion(.failure(error))
                return
            }
            _ = try? FileManager.default.replaceItemAt(targetURL, withItemAt: tempURL)
            completion(.success(targetURL))
        }
        downloadTask.resume()
    }
    
    private func suggestedDownloadDestination(for directory: FileManager.SearchPathDirectory = .documentDirectory,
                                                   in domain: FileManager.SearchPathDomainMask = .userDomainMask) -> Destination {
        { temporaryURL, response in
            let directoryURLs = FileManager.default.urls(for: directory, in: domain)
            let url = directoryURLs.first?.appendingPathComponent(response.suggestedFilename!) ?? temporaryURL
            return (url)
        }
    }
}


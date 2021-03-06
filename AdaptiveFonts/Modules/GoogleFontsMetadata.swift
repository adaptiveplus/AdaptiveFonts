//
//  GoogleFontsMetadata.swift
//  AdaptiveFonts
//
//  Created by Nurzhigit on 01.03.2021.
//  Copyright © 2021 Sprint Squads. All rights reserved.
//
import UIKit
/// The class to work Google Fonts API.
/// This class is used to fetch Google Fonts metadata, i.e. list of fonts supported by Google Fonts.
/// The metadata can be downloaded if no persisted file found or load locally.

final class GoogleFontsMetadata {
    typealias JSON = [String: Any]
    typealias ItemsJSON = [ItemJSON]
    typealias ItemJSON = [String: Any]
    typealias FilesJSON = [String: String]
    typealias FamilyDictionary = [String: [String]]

    private let APIEndpoint = "https://api.adaptive.plus/v1/web-fonts"
    private let storage: Storage
    private let queue: DispatchQueue?
    private let defaultVariantFilter: (String) -> Bool = {
        let variants: [Font.Variant] = [.thin, .thinItalic, .extralight, .extralightItalic, .light, .lightItalic, .regular, .regularItalic, .medium, .mediumItalic, .semibold, .semiboldItalic, .bold, .boldItalic, .extrabold, .extraboldItalic, .black, .blackItalic]

        return variants.map { $0.rawValue }.contains($0)
    }
    private var cache: FamilyDictionary?

    init(storage: Storage, queue: DispatchQueue?) {
        self.storage = storage
        self.queue = queue
    }

    // MARK: - Interface

    /// Fetch the Google Fonts metadata.
    ///
    /// - Parameter completion: The completion handler.
    /// - Returns: The download request.
    func fetch(completion: @escaping (Result<FamilyDictionary>) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let components = URLComponents(string: APIEndpoint)!
        let request = URLRequest(url: components.url!)
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode,
                error == nil
                else {
                    completion(.failure(error))
                    return
            }
            guard let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? JSON else {
                completion(.failure(error))
                return
            }
            let cache = self.parse(json: responseObject, variantFilter: self.defaultVariantFilter)
            self.cache = cache
            completion(.success(cache))
        }
        task.resume()
    }

    /// Get the family dictionary from persisted Google Fonts metadata file.
    ///
    /// - Returns: The family dictionary.
    func familyDictionary() -> FamilyDictionary {
        if let cache = cache {
            return cache
        }

        guard let data = try? Data(contentsOf: storage.metadataURL),
            let optionalJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = optionalJson as? JSON else {
                cache = nil

                return [:]
        }

        if cache == nil {
            cache = parse(json: json, variantFilter: defaultVariantFilter)
        }

        return cache!
    }

    /// Get the file of specified font.
    ///
    /// - Parameters:
    ///   - font: The font needed to get the file.
    ///   - familyDictionary: The family dictionary to look up the file.
    /// - Returns: The file.
    func file(of font: Font, familyDictionary: FamilyDictionary?) -> String? {
        let familyDictionary = cache ?? familyDictionary ?? self.familyDictionary()

        guard let files = familyDictionary[font.family],
            let index = files.firstIndex(where: { $0.hasSuffix(font.variant.rawValue) }) else {
                return nil
        }

        return files[index]
    }

    /// Check if the Google Fonts metadata file exists.
    ///
    /// - Returns: `true` if existing, otherwise `false`.
    func exist() -> Bool {
        return storage.googleFontsMetadataExists()
    }

    // MARK: - Helpers

    /// Parse the JSON to the family dictionary.
    ///
    /// - Note: Only concerned variants are taken.
    ///
    /// - Parameters:
    ///   - json: The JSON.
    ///   - variantFilter: The variant filter.
    /// - Returns: The family dictionary.
    private func parse(json: JSON, variantFilter: ((String) -> Bool)) -> FamilyDictionary {
        guard let items = json["items"] as? ItemsJSON else {
            return [:]
        }

        return items.reduce([:]) { result, item in
            guard let family = item["family"] as? String,
                let files = item["files"] as? FilesJSON else {
                    return result
            }

            var result = result

            result[family] = files.compactMap { (key, value) in
                guard variantFilter(key),
                    var urlComponents = URLComponents(string: value) else { return nil }

                urlComponents.scheme = "https"
                urlComponents.fragment = key
                
                return urlComponents.string
            }
            
            return result
        }
    }
}

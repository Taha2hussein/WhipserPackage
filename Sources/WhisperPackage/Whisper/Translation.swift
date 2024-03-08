//
//  SwiftyTranslate.swift
//  SwiftyTranslate
//
//  Created by Christoph Pageler on 15.12.20.
//

import Foundation
//#if canImport(FoundationNetworking)
//import FoundationNetworking
//#endif

public struct SwiftyTranslate {
    public enum Error: Swift.Error {
        case invalidURL
        case noData
        case tooManyRequests
        case invalidData
    }
    
    public struct Translation {
        public var origin: String
        public var translated: String
    }
    
    public static func translate(text: String, from: String, to: String) -> Result<Translation, Error> {
        var urlComponents = URLComponents(string: "https://translate.googleapis.com/translate_a/single")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: from),
            URLQueryItem(name: "tl", value: to),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "q", value: text),
        ]
        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }
        
        var result: Result<Translation, Error>?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.noData)
                semaphore.signal()
                return
            }
            
            guard httpResponse.statusCode != 429 else {
                result = .failure(.tooManyRequests)
                semaphore.signal()
                return
            }
            
            guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
                result = .failure(.invalidData)
                semaphore.signal()
                return
            }
            
            // Extract array structure
            guard let firstArray = object as? [Any],
                  let secondArray = firstArray.first as? [Any] else {
                result = .failure(.invalidData)
                semaphore.signal()
                return
            }
            
            // Extract result
            // Strings separated by "\n" are separated in the array
            var originParts: [String]?
            var resultParts: [String]?
            
            for sectionInSecondArray in secondArray {
                guard let sectionResultArray = sectionInSecondArray as? [Any] else { continue }
                let sectionResult = sectionResultArray[0..<2]
                
                guard let translated = sectionResult.first as? String,
                      let origin = sectionResult.last as? String else {
                    continue
                }
                
                if originParts == nil { originParts = [] }
                originParts?.append(origin)
                
                if resultParts == nil { resultParts = [] }
                resultParts?.append(translated)
            }
            
            // (Re)join separated strings
            if let originParts = originParts, let resultParts = resultParts {
                let origin = originParts.joined()
                let translated = resultParts.joined()
                result = .success(Translation(origin: origin, translated: translated))
            } else {
                result = .failure(.invalidData)
            }
            
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        return result ?? .failure(.noData)
    }
}

//#if swift(>=5.5)
//@available(iOS 13.0.0, *)
//@available(macOS 10.15.0, *)
//@available(watchOS 6.0, *)
//@available(tvOS 13.0.0, *)
//extension SwiftyTranslate {
//    public static func translate(text: String, from: String, to: String) async throws -> Translation {
//        try await withCheckedThrowingContinuation({ continuation in
//            SwiftyTranslate.translate(text: text, from: from, to: to) { result in
//                switch result {
//                case .success(let value):
//                    continuation.resume(returning: value)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        })
//    }
//}
//#endif

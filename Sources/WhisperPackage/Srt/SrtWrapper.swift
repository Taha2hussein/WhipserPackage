//
//  SrtWrapper.swift
//  whisper-ios-demo
//
//  Created by Taha Hussein on 25/02/2024.
//

import Foundation

public class SrtWrapper {
    
    // Function to save translated texts to an .srt file
    public func saveTranslatedTextsToSRT(translatedTexts: [String], outputFileName: String) {
        var srtString = ""
        
        for (index, translatedText) in translatedTexts.enumerated() {
            let subtitleNumber = index + 1
            //            let startTime = translatedText.startTime
            //            let endTime = translatedText.endTime
            srtString += "\(subtitleNumber)\n\(translatedText)\n\n"
        }
        
        // Get the document directory URL
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(outputFileName)
            
            do {
                try srtString.write(to: fileURL, atomically: true, encoding: .utf8)
                print("SRT file created successfully at: \(fileURL.path)")
            } catch {
                print("Error creating SRT file: \(error)")
            }
        } else {
            print("Document directory not found.")
        }
    }
    
    public func checkPath(outputFileName: String) -> Result<[String], Error> {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(outputFileName)
            var subtitles = [String]()
            // Check if the file exists
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let srtString = try String(contentsOf: fileURL, encoding: .utf8)
                    print("Contents of SRT file:")
                    let subtitleComponents = srtString.components(separatedBy: "\n\n")

                    // Iterate through subtitle components and parse each one
                    for component in subtitleComponents {
                        let lines = component.components(separatedBy: .newlines)
                        if lines.count > 0 {
                            let text = lines.joined(separator: "\n")
                            subtitles.append(text)
                        }
                    }
                    return .success(subtitles)
                } catch {
                    print("Error reading SRT file: \(error)")
                    return .failure(error)
                }
            } else {
                let error = NSError(domain: "FileNotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found at path: \(fileURL.path)"])
                return .failure(error)
            }
        } else {
            let error = NSError(domain: "DirectoryNotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document directory not found."])
            return .failure(error)
        }
    }
}

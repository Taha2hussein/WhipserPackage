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
    
    public  func chackPath(outputFileName: String){
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(outputFileName)
            
            // Check if the file exists
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let srtString = try String(contentsOf: fileURL, encoding: .utf8)
                    print("Contents of SRT file:")
                    let subtitleComponents = srtString.components(separatedBy: "\n\n")
                    
                    var subtitles = [String]()
                    
                    // Iterate through subtitle components and parse each one
                    for component in subtitleComponents {
                        let lines = component.components(separatedBy: .newlines)
                        if lines.count > 0 {
                            let text = lines[0..<lines.count].joined(separator: "\n")
                            //                                let subtitle = SrtModel( startTime: startTime, endTime: endTime, text: text)
                            print(text)
                            subtitles.append(text)
                        }
                    }
                } catch {
                    print("Error reading SRT file: \(error)")
                }
            } else {
                print("File not found at path: \(fileURL.path)")
            }
        } else {
            print("Document directory not found.")
        }
    }
}

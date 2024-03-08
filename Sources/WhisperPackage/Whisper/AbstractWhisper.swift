//
//  AbstractWhisper.swift
//  whisper-ios-demo
//
//  Created by Taha Hussein on 25/02/2024.
//
import Foundation
import whisper_cpp

public protocol AbstractWhisperProtocol {
    func readWav(modelPath: String, wavPath: String)
    func translateExample(text: String,t0: String , t1: String)
}

public class AbstractWhisper: AbstractWhisperProtocol {
    public static let shared = AbstractWhisper()
    let SrtWrappe = SrtWrapper()
    
    private var translatedTexts: [String] = []
    
    // Define C function pointer types
    typealias FinishCallback = @convention(c) (Int32) -> Int32
    typealias ProgressCallback = @convention(c) (UnsafePointer<CChar>?) -> Int32
    typealias ResultCallback = @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafePointer<CChar>?) -> Int32
    
    // Define global functions for the callbacks
    private func progressCallbackWrapper(progress: UnsafePointer<CChar>?) -> Int32 {
        guard let progress = progress else {
            return 0
        }
        
        let str = String(cString: progress)
//        self.translateExample(text: str)
        
        return 0
    }
    
    private func finishCallbackWrapper(progress: Int32) -> Int32 {
        print(progress , "translation progress")
        let outputFilePath = "translated_subtitles.srt"
        SrtWrappe.saveTranslatedTextsToSRT(translatedTexts: translatedTexts, outputFileName: outputFilePath)
        return 0
    }
    
    private func resultCallbackWrapper(time0: UnsafePointer<CChar>?, time1: UnsafePointer<CChar>?, text: UnsafePointer<CChar>?) -> Int32 {
        guard let text = text else {
            return 0
        }
        
        guard let t0 = time0 else {
            return 0
        }
        
        guard let t1 = time1 else {
            return 0
        }
        let tim0 = String(cString: t0)
        let tim1 = String(cString: t1)
        let str = String(cString: text)
        self.translateExample(text: str, t0: tim0, t1: tim1)
        return 0
    }
    //finish_callback(0);
    public func readWav(modelPath: String, wavPath: String)  {
        // Create C function pointers
        let progressCallback: ProgressCallback = { progress in
            return AbstractWhisper.shared.progressCallbackWrapper(progress: progress)
        }
        
        let resultCallback: ResultCallback = { time0, time1, text in
            return AbstractWhisper.shared.resultCallbackWrapper(time0: time0, time1: time1, text: text)
        }
        
        let finishCallback: FinishCallback = { progress  in
            return AbstractWhisper.shared.finishCallbackWrapper(progress: progress)
        }
        _ = read_wav(modelPath, wavPath, progressCallback, resultCallback, finishCallback)
    }
    
    // Function to translate text
    public func translateExample(text: String,t0: String , t1: String) {
        let fullText = "[\(t0) --> \(t1)]  \(text)"
        
       let translated =  SwiftyTranslate.translate(text: "[\(t0) --> \(t1)]  \(text)", from: "en", to: "ar")
            self.handleTranslationResult(result: translated)
    }
    
    func handleTranslationResult(result: Result<SwiftyTranslate.Translation, SwiftyTranslate.Error>) {
        switch result {
        case .success(let translation):
            print("\(translation.translated)")
            self.translatedTexts.append(translation.translated)
        case .failure(let error):
            print("Translation failed with error: \(error)")
        }
    }
}

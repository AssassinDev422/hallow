//
//  Utilities.swift
//  Hallow
//
//  Created by Alex Jones on 8/9/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static let backgroundAudioURL: String = "audio/Background - 5 mins.mp3"
    
    static var pausedTime = 0.00
    
    static var isX: Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    static func urlInDocumentsDirectory(forPath path: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
        return documentsDirectory.appendingPathComponent(path)
    }
    
    static func pullUpDownloads() -> [String] {
        let path = "audio/"
        var fileNames: [String] = []
        let fileManager = FileManager.default
        let _documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
        let documentsDirectory = _documentsDirectory.appendingPathComponent(path)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            print("fileURLS: \(fileURLs)")
            for fileURL in fileURLs {
                fileNames.append(fileURL.lastPathComponent)
                print("\(fileURL.lastPathComponent)")
            }
            return fileNames
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
            return []
        }
    }
    
    static func deleteFile(path: String) -> () {
        let fileManager = FileManager.default
        let _documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
        let documentsDirectory = _documentsDirectory.appendingPathComponent(path)
        do {
            try fileManager.removeItem(at: documentsDirectory)
            print("File deleted: \(path)") //FIXME: Error
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
    
    
}

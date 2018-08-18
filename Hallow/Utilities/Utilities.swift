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
}

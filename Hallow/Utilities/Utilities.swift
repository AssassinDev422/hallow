//
//  Utilities.swift
//  Hallow
//
//  Created by Alex Jones on 8/9/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation

class Utilities {
    static var pausedTime = 0.00
    
    static func urlInDocumentsDirectory(forPath path: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
        return documentsDirectory.appendingPathComponent(path)
    }
}

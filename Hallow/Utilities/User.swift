//
//  User.swift
//  Hallow
//
//  Created by Alex Jones on 5/22/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

class User {
    var name: String
    var email: String
    
    init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let name = data["Name"] as? String,
            let email = data["Email"] as? String else {
                fatalError("This user file could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.name = name
        self.email = email
    }
}

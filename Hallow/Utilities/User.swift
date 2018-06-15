//
//  User.swift
//  Hallow
//
//  Created by Alex Jones on 5/22/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

//TODO: Update password if password reset happens

class User {
    var name: String
    var email: String
    var password: String
    
    init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let name = data["Name"] as? String,
            let email = data["Email"] as? String,
            let password = data["Password"] as? String else {
                fatalError("This user file could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.name = name
        self.email = email
        self.password = password
    }
}

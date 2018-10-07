//
//  Database.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import Foundation
import Firebase
extension Database
{
    static func fetchUser(userID:String,completitionHandler:@escaping (User) -> ())
    {
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]
            {
                let user = User(uid:userID,dictionary: dictionary)
                completitionHandler(user)
            }
            
            
        }) { (err) in
            
        }
    }
}

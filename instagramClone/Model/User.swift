//
//  User.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/4/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import Foundation
struct User {
    let username:String
    let profileImageUrl:String
    let uid:String
    init(uid:String,dictionary:[String:Any]) {
        self.username = dictionary["username"] as? String  ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
        self.uid = uid
    }
}

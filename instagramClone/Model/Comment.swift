//
//  Comment.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/9/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
struct Comment {
    let user:User
    let text:String
    let uid:String
    init(user:User,dictionary:[String:Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.user = user
    }
}

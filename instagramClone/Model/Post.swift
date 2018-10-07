//
//  Post.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
struct Post {
    let postImageUrl:String
    let creationDate:String
    let user:User
    let caption:String
    init(user:User,dictionary:[String:Any]) {
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.creationDate = dictionary["creationDate"] as? String ?? ""
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
    }
}

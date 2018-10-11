//
//  Post.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
struct Post {
    var postId:String?
    let postImageUrl:String
    let creationDate:Date
    let user:User
    let caption:String
    var hasLiked:Bool = false
    init(user:User,dictionary:[String:Any]) {
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        let date = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: date)
    }
}

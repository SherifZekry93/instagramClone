//
//  ConstraintExtension.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/4/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
extension UIView
{
   
    func anchorToView(top : NSLayoutYAxisAnchor? = nil ,left : NSLayoutXAxisAnchor? = nil,bottom : NSLayoutYAxisAnchor? = nil,right : NSLayoutXAxisAnchor? = nil,padding:UIEdgeInsets = .zero,size:CGSize = .zero,centerH:Bool? = false, centerV:Bool? = false)
    {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top
        {
            self.topAnchor.constraint(equalTo: top,constant:padding.top).isActive = true
        }
        if let bottom = bottom
        {
            self.bottomAnchor.constraint(equalTo: bottom,constant:-padding.bottom).isActive = true
        }
        if let right = right
        {
            self.rightAnchor.constraint(equalTo: right,constant:-padding.right).isActive = true
        }
        if let left = left
        {
            self.leftAnchor.constraint(equalTo: left,constant:padding.left).isActive = true
        }
        if size.width != 0
        {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0
        {
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        if centerH!
        {
            self.centerXAnchor.constraint(equalTo: (self.superview?.centerXAnchor)!).isActive = true
        }
        if centerV!
        {
            self.centerYAnchor.constraint(equalTo: (self.superview?.centerYAnchor)!).isActive = true
        }
    }
}

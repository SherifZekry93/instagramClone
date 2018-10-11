//
//  PhotoSelectorCell.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/5/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
class PhotoSelectorCell: UICollectionViewCell {
    
    let photoImageView:UIImageView  = {
       let iv = UIImageView()
       iv.contentMode = .scaleAspectFill
       iv.clipsToBounds = true
       iv.sd_setIndicatorStyle(.gray)
       iv.sd_showActivityIndicatorView()
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchorToView(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  CustomSearchCell.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
class UserSearchCell: UICollectionViewCell {
    var user:User?{
        didSet{
            guard let user = user else {return}
            profileImageView.sd_setImage(with: URL(string: user.profileImageUrl), completed: nil)
            let attributedString = NSMutableAttributedString(string: "\(user.username)", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 16)])
            attributedString.append(NSAttributedString(string: "\n12 Posts", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.gray]))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            usernameLabel.attributedText = attributedString
        }
    }
    let profileImageView:UIImageView = {
       let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    let usernameLabel:UILabel = {
       let label = UILabel()
        
        label.numberOfLines = -1
        return label
    }()
    let separatorView:UIView = {
       let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchorToView(top: topAnchor, left: leftAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 0), size: .init(width: 50, height: 50))
        addSubview(usernameLabel)
        usernameLabel.anchorToView(left: profileImageView.rightAnchor, right: rightAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8),centerV:true)
        addSubview(separatorView)
        separatorView.anchorToView(left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, size: .init(width: 0, height: 0.5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  HomeFeedCell.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
protocol HomePostCellDelegate {
    func didTabComments(post:Post)
    func didLike(for cell:HomeFeedCell)
}
class HomeFeedCell: UICollectionViewCell {
    var delegate:HomePostCellDelegate?
    var post:Post?{
        didSet{
            guard let hasLiked = post?.hasLiked else {return}
            likeButton.setImage(hasLiked ?  #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal): #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal) , for: .normal)
            guard let postImageURL = post?.postImageUrl else {return}
            if let url = URL(string: postImageURL)
            {
                postPhotoImageView.sd_setImage(with: url, completed: nil)
            }
            userNameLabel.text = post?.user.username
            guard let url = post?.user.profileImageUrl else {return}
            userProfileImageView.sd_setImage(with: URL(string: url), completed: nil)
        setupCaptionLabel()
        }
        
    }
    fileprivate func setupCaptionLabel()
    {
        guard let post = post else {
            return
        }
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14)])

        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)]))

        attributedText.append(NSAttributedString(string: "\n\(post.creationDate.timeAgoDisplay())", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.gray]))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        captionLabel.attributedText = attributedText
        
    }
    let postPhotoImageView:UIImageView  = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = nil
        iv.sd_setIndicatorStyle(.gray)
        iv.sd_showActivityIndicatorView()
        return iv
    }()
    let userProfileImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        iv.layer.cornerRadius = 20
        return iv
    }()
    let userNameLabel:UILabel = {
       let label = UILabel()
       label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Your name"
       return label
    }()
    let optionsButton:UIButton = {
       let button = UIButton(type: .system)
       button.setTitle("•••", for: .normal)
       button.setTitleColor(.black, for: .normal)
       button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
       return button
    }()
    let captionLabel:UILabel = {
        let label = UILabel()
   
        label.numberOfLines = -1
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    lazy var likeButton:UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComments), for: .touchUpInside)
        return button
    }()
    
    let sendButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    lazy var stackView:UIStackView = {
      let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,sendButton])
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let ribonButton:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    func setupViews()
    {
        addSubview(postPhotoImageView)
        addSubview(userProfileImageView)
        addSubview(userNameLabel)
        addSubview(optionsButton)
        addSubview(captionLabel)
        userProfileImageView.anchorToView(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, padding: .init(top: 8, left: 8, bottom: 8, right: 0), size: .init(width: 40, height: 40))
        postPhotoImageView.anchorToView(top: userProfileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, padding: .init(top: 8, left: 0, bottom: 8, right: 0),size:.init(width: 0, height: frame.width))
        userNameLabel.anchorToView(left: userProfileImageView.rightAnchor, right: optionsButton.leftAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
        userNameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor).isActive = true
        optionsButton.anchorToView(left: userNameLabel.rightAnchor,right: rightAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8),size:.init(width: 44, height: 0))
        optionsButton.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        setupActionButtons()
        captionLabel.anchorToView(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
    }
    func setupActionButtons()
    {
        addSubview(stackView)
        stackView.anchorToView(top: postPhotoImageView.bottomAnchor, left: leftAnchor,padding:.init(top: 0, left: 8, bottom: 0, right: 0) ,size: .init(width: 120, height: 50))
        addSubview(ribonButton)
        ribonButton.anchorToView(top: postPhotoImageView.bottomAnchor,  right: rightAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 8), size: .init(width: 40, height: 50))
    }
    @objc func handleComments()
    {
        guard let post = post else {
            return
        }
        delegate?.didTabComments(post:post)
    }
    @objc func handleLike()
    {
        delegate?.didLike(for: self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

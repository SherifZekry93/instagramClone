//
//  SharePhotoViewController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/5/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class SharePhotoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "share", style: .plain, target: self, action: #selector(handleSharePhoto))
        setupImageAndTextViews()
    }
    let sharePhotoImageView:UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let imageCaptionTextView:UITextView = {
       let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    func setupImageAndTextViews()
    {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.anchorToView(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, padding: .zero, size: .init(width: 0, height: 100), centerH: false, centerV: false)
        containerView.addSubview(sharePhotoImageView)
        sharePhotoImageView.anchorToView(top: containerView.topAnchor, left: containerView.leftAnchor, padding:.init(top: 8, left: 8, bottom: 0, right: 0), size: .init(width: 84, height: 84))
        containerView.addSubview(imageCaptionTextView)
        imageCaptionTextView.anchorToView(top: sharePhotoImageView.topAnchor, left: sharePhotoImageView.rightAnchor, bottom: sharePhotoImageView.bottomAnchor, right: containerView.rightAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    @objc func handleSharePhoto()
    {
        guard let sharePhotoImage = sharePhotoImageView.image else {return}
        guard let toUploadData = UIImagePNGRepresentation(sharePhotoImage) else {return}
        let fileName = NSUUID().uuidString
        navigationItem.rightBarButtonItem?.isEnabled = false
        let storageRef = Storage.storage().reference().child("posts").child(fileName)
        storageRef.putData(toUploadData, metadata: nil) { (meta, err) in
            if err != nil
            {
                self.navigationItem.rightBarButtonItem?.isEnabled = true

                print("uploading image field",err!)
                return
            }
            storageRef.downloadURL(completion: { (url, err) in
                if err != nil
                {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("failed to get download url",err!)
                    return
                }
                guard let imageUrl = url?.absoluteString else {return}
                self.saveToDatabaseWithImageURL(url: imageUrl)
            })
        }
    }
    fileprivate func saveToDatabaseWithImageURL(url:String)
    {
        guard let image = sharePhotoImageView.image else {return}
            guard let currentUserID = Auth.auth().currentUser?.uid else {return}
            let postsRef = Database.database().reference().child("posts").child(currentUserID)
            let ref = postsRef.childByAutoId()
            guard let caption = imageCaptionTextView.text else {return}
        let values = ["postImageUrl":url,"caption":caption,"width":image.size.width,"height":image.size.height,"creationDate":Date().timeIntervalSince1970] as [String : Any]
            ref.updateChildValues(values) { (err, ref) in
                if err != nil
                {
                    print("err saving data",err)
                    return
                }
                print("sucessfully uploaded post")
                self.dismiss(animated: true, completion: nil)
        }
    }
}

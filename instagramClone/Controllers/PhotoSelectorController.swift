//
//  PhotoSelectorController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/5/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Photos
class PhotoSelectorController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupNavigationController()
        setupCollectionView()
        fetchPhotos()
        //monitorUserPermission()
    }
    let cellID = "cellID"
    let headerID = "headerID"
    var images = [UIImage]()
    var selectedImage:UIImage?
    var assets = [PHAsset]()
    func fetchOptions() -> PHFetchOptions
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    func fetchPhotosAfterPermission()
    {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions())
        DispatchQueue.global(qos: .background).async
            {
                allPhotos.enumerateObjects { (asset, count, stop) in
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 200, height: 200)
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                        self.assets.append(asset)
                        if let image = image
                        {
                            self.images.append(image)
                        }
                        if self.selectedImage == nil
                        {
                            self.selectedImage = image
                        }
                        if count == allPhotos.count - 1
                        {
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                }
        }
    }
    func fetchPhotos()
    {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
           fetchPhotosAfterPermission()
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.fetchPhotosAfterPermission()
                }
                    
                else {
                    
                }
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }

        
    }
    func setupCollectionView()
    {
        collectionView?.backgroundColor = .white
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoSelectorCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! PhotoSelectorHeader
        if let selected = selectedImage
        {
            header.photoImageView.image = selected
            if let index = self.images.index(of: selected)
            {
                let imageManager = PHImageManager.default()
                imageManager.requestImage(for: assets[index], targetSize: CGSize(width: 600, height: 600), contentMode: .aspectFit, options: PHImageRequestOptions()) { (image, _) in
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    func setupNavigationController()
    {
         navigationController?.navigationBar.tintColor = .black
         navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleSelect))
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectedImage = images[indexPath.item]
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
        collectionView.reloadData()
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    @objc func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    @objc func handleSelect()
    {
        let controller = SharePhotoViewController()
        controller.sharePhotoImageView.image = selectedImage
        navigationController?.pushViewController(controller, animated: true)
    }
}

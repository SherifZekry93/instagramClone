//
//  MainTabBarController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/4/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class MainTabBarController: UITabBarController,UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if index == 2
        {
            present(UINavigationController(rootViewController:  PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())), animated: true, completion: nil)
            return false
        }
        return true
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.delegate = self
        if Auth.auth().currentUser?.uid == nil
        {
            DispatchQueue.main.async {
                let navigationController = UINavigationController(rootViewController: LoginController())
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        else
        {
            setupControllers()
        }
    }
    func setupControllers()
    {
        //home controller
        let homeNavController = setupNavController(rootController: HomeFeedController(collectionViewLayout: UICollectionViewFlowLayout()), image: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"))
        //search controller
        let searchController = setupNavController(rootController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()), image: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"))
        //plus controller
        let plusController = setupNavController(rootController: UIViewController(), image: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        //likes Controller
        let likesController = setupNavController(rootController: UIViewController(), image: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        
        //user profile
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        //guard let userID = Auth.auth().currentUser?.uid else {return}
//        userProfileController.fetchUser(uid: userID)
        
        let userNavigationController = setupNavController(rootController: userProfileController, image:#imageLiteral(resourceName: "profile_unselected"), selectedImage:#imageLiteral(resourceName: "profile_selected"))
        tabBar.tintColor = .black
        viewControllers = [homeNavController,searchController,plusController,likesController,userNavigationController]
        guard let tabarItems = tabBar.items else {return}
        for item in tabarItems
        {
            item.imageInsets = .init(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    func setupNavController(rootController:UIViewController,image:UIImage,selectedImage:UIImage) -> UINavigationController
    {
        let navigationController = UINavigationController(rootViewController: rootController)
        rootController.tabBarItem.image = image
        rootController.tabBarItem.selectedImage = selectedImage
        return navigationController
    }
}

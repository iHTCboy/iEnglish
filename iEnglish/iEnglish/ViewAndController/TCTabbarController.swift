//
//  TCTabbarController.swift
//  iEnglish
//
//  Created by HTC on 2017/6/5.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit

class TCTabbarController: UITabBarController {

    static let shared = TCTabbarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let words = WordsViewController()
        words.tabBarItem = UITabBarItem.init(title: "iEnglish", image: #imageLiteral(resourceName: "tabbar_iEnglish"), tag: 0)
        
        let category = CategoryViewController()
        category.tabBarItem = UITabBarItem.init(title: "Category", image: #imageLiteral(resourceName: "tabbar_categate"), tag: 1)
        
        let setting = SettingController()
        setting.tabBarItem = UITabBarItem.init(title: "Setting", image: #imageLiteral(resourceName: "tabbar_setting"), tag: 2)
        
        viewControllers = [TCNavigationController(rootViewController: words), TCNavigationController(rootViewController: category), TCNavigationController(rootViewController: setting)]
        tabBar.tintColor = kColorAppMain
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//
//  TabBarViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6)
        self.tabBar.unselectedItemTintColor = UIColor(named: "darkIndigo")
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        
        
        let defaults = UserDefaults.standard

        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                defaults.set(true, forKey: "iPhoneX")
            default:
                defaults.set(false, forKey: "iPhoneX")
            }
        }
    }

}

class CustomTabBar: UITabBar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        let defaults = UserDefaults.standard
        let iPhoneX = defaults.bool(forKey: "iPhoneX")
        if iPhoneX == true {
            sizeThatFits.height = 100
        } else {
            sizeThatFits.height = 65
        }
        return sizeThatFits
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let topBorder = CALayer()
        
        let borderHeight: CGFloat = 3
        
        topBorder.borderWidth = borderHeight
        topBorder.borderColor = UIColor(named: "darkIndigo")?.withAlphaComponent(0.1).cgColor
        topBorder.frame = CGRect(x: 0, y: -1, width: self.frame.width, height: borderHeight)
        
        self.layer.addSublayer(topBorder)
        
    }
}

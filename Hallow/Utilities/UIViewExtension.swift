//
//  UIViewExtension.swift
//  Hallow
//
//  Created by Alex Jones on 5/29/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Background gradient

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.white
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}

// MARK: - Designable text field

@IBDesignable
class DesignableUITextField: UITextField {
    
    @IBInspectable var leftPadding: CGFloat = 10
    @IBInspectable var bottomPadding: CGFloat = 2
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        textRect.origin.y += bottomPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.tintColor = UIColor.white
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: color])
    }
}

// MARK: - Draw circle as image from single color

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}

extension AudioController {
    func setUpProgressControlUI(progressSlider: UISlider!) {
        let image = #imageLiteral(resourceName: "thumbIcon")
        let newWidth = 3
        let newHeight = 6
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        progressSlider.setThumbImage(thumbImage, for: .normal)
        
        progressSlider.transform = progressSlider.transform.scaledBy(x: 1, y: 2)
        progressSlider.tintColor = UIColor(named: "fadedPink")
    }
}

// MARK: - Tab bar set up

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
        if iPhoneX {
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



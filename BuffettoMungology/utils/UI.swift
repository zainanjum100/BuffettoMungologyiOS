//
//  UI.swift
//  BuffettoMungology
//
//  Created by Anthony Ezeh on 13/07/2019.
//  Copyright © 2019 Gallivanter. All rights reserved.
//

import UIKit

public class UI: NSObject
{
    public static func networkActivity(_ show: Bool)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
    
    
    public static func roundButton(_ button: UIButton)
    {
        button.layer.cornerRadius = button.frame.height / 2;
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0
    }
        
    public static func insets() -> UIEdgeInsets
    {
        var inset = UIEdgeInsets.zero;
        if #available(iOS 11, *)
        {
            inset = (UIApplication.shared.delegate?.window??.safeAreaInsets)!;
        }
        return inset;
    }
    
    public static func toast(_ view: UIView, _ message: String)
    {
        view.makeToast(message: message)
    }
    
}

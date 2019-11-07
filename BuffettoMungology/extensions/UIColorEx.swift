//
//  UIColorEx.swift
//  BuffettoMungology
//
//  Created by Anthony Ezeh on 13/07/2019.
//  Copyright © 2019 Gallivanter. All rights reserved.
//

import UIKit

extension UIColor
{
    
    public convenience init(hex: String)
    {
        self.init(hex: hex, alpha:1)
    }
    
    public convenience init(hex: String, alpha: CGFloat)
    {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#")
        {
            let tIndex = hex.index(hex.startIndex, offsetBy: 1)
            
            hexWithoutSymbol = String(hex[tIndex...]);   //.substring(start: 1)
        }
        
        let scanner = Scanner(string: hexWithoutSymbol)
        var hexInt:UInt32 = 0x0
        scanner.scanHexInt32(&hexInt)
        
        var a = alpha;
        var r:UInt32!, g:UInt32!, b:UInt32!
        switch (hexWithoutSymbol.count)
        {
        case 3: // #RGB
            r = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
            g = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
            b = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
            break;
        case 6: // #RRGGBB
            r = (hexInt >> 16) & 0xff
            g = (hexInt >> 8) & 0xff
            b = hexInt & 0xff
            break;
        case 8: // #AARRGGBB
            a = CGFloat((hexInt >> 24) & 0xff)
            r = (hexInt >> 16) & 0xff
            g = (hexInt >> 8) & 0xff
            b = hexInt & 0xff
            break;
        default:
            r = 0
            g = 0
            b = 0
            break;
        }
        
        self.init(red: (CGFloat(r)/255), green: (CGFloat(g)/255), blue: (CGFloat(b)/255), alpha:a)
    }
}

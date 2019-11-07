//
//  Utils.swift
//  AudioBook
//
//  Created by Anthonio Ez on 29/03/2018.
//  Copyright © 2018 AudioBook. All rights reserved.
//

import UIKit
import SystemConfiguration

class Utils: NSObject
{    
    public static var GB: Double = 1024 * 1024 * 1024
    public static var MB: Double = 1024 * 1024
    public static var KB: Double = 1024

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
    
    
    public static func formatByte(_ data: Double, _ precision: Int = 2, _ spacer: String = "") -> String
    {
        let value: Double = Double(data);
        let format = "%.\(precision)f\(spacer)"
        
        if (value >= GB)
        {
            return String(format: format, value / GB) + "GB";
        }
        else if (value >= MB)
        {
            return String(format: format, value / MB) + "MB";
        }
        else if (value >= KB)
        {
            return String(format: format, value / KB) + "KB";
        }
        else
        {
            return String(format: "%.0f%@", data, spacer) + "B";
        }
    }
    
    static func formatDuration(_ duration: TimeInterval) -> String
    {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        if(duration > 3600)
        {
            formatter.allowedUnits = [ .hour,  .minute, .second ]
        }
        else
        {
            formatter.allowedUnits = [ .minute, .second ]
        }
        formatter.zeroFormattingBehavior = [ .pad ]
        
        let formattedDuration = formatter.string(from: duration)
        
        return formattedDuration ?? "";
    }
    
    public static func isOnline() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    public static func alert(_ controller: UIViewController, _ title: String, _ message: String, response: (() -> Void)?)
    {
        let alertController: UIAlertController  = UIAlertController(title: title, message: message, preferredStyle: .alert );
        
        let actionOk : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { re in
            alertController.dismiss(animated: true, completion: nil)
            
            response?()
        })
        
        alertController.addAction(actionOk)
        
        controller.present(alertController, animated: true, completion: nil)
    }
}

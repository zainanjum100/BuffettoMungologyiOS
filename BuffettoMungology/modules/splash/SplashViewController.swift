//
//  SplashViewController.swift
//  AudioBook
//
//  Created by Anthonio Ez on 29/03/2018.
//  Copyright © 2018 AudioBook. All rights reserved.
//

import UIKit
import Alamofire

class SplashViewController: UIViewController
{
    @IBOutlet weak var buttonRetry: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static func instance() -> SplashViewController
    {
        let vc = SplashViewController(nibName: "SplashViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        perform(#selector(startApp), with: nil, afterDelay: 2);
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func startApp()
    {
        App.home()
    }
}

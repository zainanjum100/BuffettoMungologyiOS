//
//  SocialMediaLogin.swift
//  BuffettoMungology
//
//  Created by Noman2 on 02/11/2019.
//  Copyright © 2019 Gallivanter. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
class SocialMediaLogin: UIViewController {

    
    @IBOutlet weak var fbButtonOutlet: UIButton!
    
    @IBOutlet weak var gmailButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  perform(#selector(startApp), with: nil, afterDelay: 2)
        
        
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
    
        
        setView()

        // Do any additional setup after loading the view.
    }
    
    func setView(){
        self.fbButtonOutlet.layer.cornerRadius = 8
        self.gmailButtonOutlet.layer.cornerRadius = 8
    }
    
    static func instance() -> SocialMediaLogin
       {
           let vc = SocialMediaLogin(nibName: "SocialMediaLogin", bundle: nil)
           return vc;
       }
    @IBAction func btnGoogle(_ sender: Any) {
        
    }
    @IBAction func btnFb(_ sender: Any) {
        
        if let _ = AccessToken.current {
            self.navigationController?.pushViewController(MainViewController.instance(), animated: true)

            UserDefaults.standard.set(true, forKey: "isLoggedIn")
        }
        else{
            let manager = LoginManager()
            manager.logIn(permissions: [.publicProfile], viewController: self) { (loginResult) in
                
                switch loginResult {
                case .failed(let error):
                    print(error)
                    
                case .cancelled:
                    print("User Cancelled Login")
                   
                case .success(let grantedPermissions, declined: let declinedPermissions, token: let accessToken):
                    print("Logged In")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
            self.navigationController?.pushViewController(MainViewController.instance(), animated: true)
                    
                    
                    
                }
            }
        }
        
    }
    
    
    
    @IBAction func btnGmail(_ sender: Any) {
        
       
    }
    
    
    

   
}

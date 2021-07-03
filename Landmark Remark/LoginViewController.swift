//
//  ViewController.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 30/06/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import UIKit
import FirebaseUI

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var loginViewModel: LoginViewModel!
    
    // Reference to Firebase Auth
    var authUI: FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        usernameTxtFld.becomeFirstResponder()
        loginViewModel = LoginViewModel()
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self;
        
        presentFirebaseLoginUI()
        
    }
    
    func presentFirebaseLoginUI() {
        
        guard let fAuthUI = self.authUI else {return}
        self.authUI?.providers = [FUIGoogleAuth.init(authUI: fAuthUI), FUIEmailAuth()]
        self.view.addSubview(fAuthUI.authViewController().view)
//        self.show(fAuthUI.authViewController(), sender: nil)
    }

    @IBAction func loginUserAction(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowMapView"{
                let mapViewCtlr = segue.destination as! MapViewController
                mapViewCtlr.mapViewModel = MapViewModel()
            }
    }
}

extension LoginViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
                
        print("called")
        
        if let user = authUI.auth?.currentUser {
            
            let landmarkUser:User = User.init(userId: user.uid, username: user.displayName!)
            
            loginViewModel.login(landmarkUser: landmarkUser, completion: {[weak self] landmark in
                
                print("\(String(describing: landmark))")
                if landmark != nil {
                    self?.performSegue(withIdentifier: "ShowMapView", sender: nil)
                }
                
            })
        
//        UserHelper.login(user) { [weak self] (user) in
//            if let _ = user, let strongSelf = self {
//                strongSelf.presentViewController(true)
//            }
        }

        
        
        
    }
}


//
//  ViewController.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 30/06/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import UIKit
import FirebaseUI

class LoginViewController: UIViewController  {

    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    // Reference to Login View model
    var loginViewModel: LoginViewModel!
    
    // Reference to Firebase Auth
    var authUI: FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginViewModel = LoginViewModel()
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self;
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true

        presentFirebaseLoginUI()
        
    }
    
    /*
     Method      : presentFirebaseLoginUI
     Description : Present Firebase Auth controller as login for (Google,FB,Email,Phone)
     parameter   : none
     Return      : none
     */
    func presentFirebaseLoginUI() {
        
        guard let fAuthUI = self.authUI else {return}
        self.authUI?.providers = [
            FUIGoogleAuth.init(authUI: fAuthUI),
            FUIFacebookAuth.init(authUI: fAuthUI),
            FUIEmailAuth(),
            FUIPhoneAuth(authUI: fAuthUI)]

        self.view.addSubview(fAuthUI.authViewController().view)
        
    }

    /*
     Method      : prepareForSegue: sender:
     Description : Show map view after successful login
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowMapView"{
                let mapViewCtlr = segue.destination as! MapViewController
                mapViewCtlr.mapViewModel = MapViewModel()
                mapViewCtlr.currentUser = loginViewModel.currentLandmarkUser
            }
    }
}

// MARK: FUIAuth Delegate Methods
extension LoginViewController: FUIAuthDelegate {
    
    /*
     Method      : authUI:didSignInWithAuthDataResult:error:
     Description : After successful login initialise User Model and save in Firebase DB
     */
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
                
        print("called")
        
        if let user = authUI.auth?.currentUser {
            
            var username: String
            
            if let displayname = user.displayName {
                username = displayname
            }
            else
            {
                username = user.phoneNumber ?? ""
            }
            
            let landmarkUser:User = User.init(userId: user.uid, username: username)
            
            loginViewModel.login(landmarkUser: landmarkUser, completion: {[weak self] landmark in
                guard let self = self else {return}
                
                print("\(String(describing: landmark))")
                if landmark != nil {
                    self.performSegue(withIdentifier: "ShowMapView", sender: nil)
                }
                
            })
        }
    }
    
    /*
     Method      : authPickerViewControllerForAuthUI
     Description : Show custom login view
     */
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {

        // A custom FUIAuthPickerViewController subclass to customise the UI of Firebase Login View
        return CustomFirebaseAuthViewController(nibName: "CustomFirebaseViewController",
                                     bundle: Bundle.main,
                                     authUI: authUI)
        
    }
    
}


//
//  LoginViewModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 02/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation

// ViewModel Class to handle/automate all the operation between view and model
final class LoginViewModel {
    
    var userArray: [User] = [User]()
    let apiService: FirebaseAPIServiceProtocol
    public var currentLandmarkUser: User?
    
    // Initialization
    init(apiService: FirebaseAPIServiceProtocol = FirebaseAPIService()) {
        self.apiService = apiService
    }
    
    /*
     Method      : landmarkUser
     Description : Binder function to check if user exists in FirebaseDB. Create new
                    user in firebase DB and notify the view
                   and allow access.
     parameter   : landmarkUser, completion
     Return      : none
     */
    func login(landmarkUser: User, completion: @escaping (_ landmarkUser: User?) -> Void){
        
        // fetch all the users from firebase db
        apiService.fetchLandmarkUsers(completion: ({ [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let response):
                self.userArray = response
                    
                // Check if logged in user exists in firebase db
                let existingUser = self.userArray.filter({
                    $0.userId == landmarkUser.userId
                })
                
                if existingUser.count == 0 {
                    
                    // If new user then save the user in firebase db
                    self.apiService.saveLandmarkUser(landmarkUser: landmarkUser, completion: ({ [weak self] result in
                        
                        switch result {
                        
                            case .success(let response):
                                self!.currentLandmarkUser = response
                                print("save landmark")
                                completion(self!.currentLandmarkUser)
                            case .failure(let error):
                            print("\(error)")
                            completion(nil)
                        }
                    }))
                }
                else {

                    self.currentLandmarkUser = landmarkUser
                    print("no landmark user found")
                    completion(self.currentLandmarkUser)
                }
                
            case .failure(let error):
                print("\(error)")
                completion(nil)
            
            }
            
        }))
        
    }
}

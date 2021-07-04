//
//  LoginViewModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 02/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation

final class LoginViewModel {
    
    var userArray: [User] = [User]()
    let apiService: FirebaseAPIServiceProtocol
    public var currentLandmarkUser: User?
    
    
    init(apiService: FirebaseAPIServiceProtocol = FirebaseAPIService()) {
        self.apiService = apiService
    }
    
    
    func login(landmarkUser: User, completion: @escaping (_ landmarkUser: User?) -> Void){
        
        apiService.fetchLandmarkUsers(completion: ({ [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let response):
                    self.userArray = response
                    
                let existingUser = self.userArray.map{
                    $0.userId == landmarkUser.userId
                }
                
                if existingUser.count == 0 {
                    
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
                    print("no landmark found")
                    completion(self.currentLandmarkUser)
                }
                
                
            case .failure(let error):
                print("\(error)")
                completion(nil)
            
            }
            
        }))
        
    }
}

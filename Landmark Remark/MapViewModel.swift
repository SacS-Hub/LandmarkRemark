//
//  MapViewModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 03/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import FirebaseAuth

// ViewModel Class to handle/automate all the operation between view and model
protocol RemarksDelegates: AnyObject {
    
    func remarkSavedWithSuccess(_ remark: Remark)
    func remarksFetchedWithSuccess(_ status: Bool)
    func operationFailedWithError(_ message: String)
}

final class MapViewModel {
    
    var remarksArray: [Remark] = [Remark]()
    let apiService: FirebaseAPIServiceProtocol
    
    weak var delegate : RemarksDelegates?
    
    // Firebase API service class dependency injected
    init(apiService: FirebaseAPIServiceProtocol = FirebaseAPIService()) {
        self.apiService = apiService
    }

    /*
     Method      : getAllRemarks
     Description : Binder function to fetch all remarks from firebase db and notify the
                   view
     parameter   : completion handler
     Return      : none
     */
    func getAllRemarks(){
        
        // Retrieve all the remarks using fire base api service
        apiService.fetchAllRemarksFromFirebase(completion: ({ [weak self] result in
            guard let self = self else {return}
                                                                
            switch result {
            case .success(let response):
                self.remarksArray = response
                self.delegate?.remarksFetchedWithSuccess(true)
                print("all remark success")
            case .failure(let error):
                self.delegate?.operationFailedWithError(error.localizedDescription)
                print("all remark error")
            }}))
    
    }
    
    /*
     Method      : addUserRemark
     Description : Binder function to save remark to firebase db and notify the view
     parameter   : completion handler
     Return      : none
     */
    func addUserRemark (landmarkRemark: Remark) {
        
        // Save the remark using fire base api service
        apiService.saveUserRemark(landmarkRemark: landmarkRemark, completion: ({ [weak self] result in
            guard let self = self else {return}
            
            switch result {
            
            //
            case .success(let response):
                self.remarksArray.append(response)
                self.delegate?.remarkSavedWithSuccess(response)
                print("add remark success")
            case .failure(let error):
                self.delegate?.operationFailedWithError(error.localizedDescription)
                print("add remark error")
            }
        }))
    }
    
    /*
     Method      : logout
     Description : Binder function to log user out of the application
     parameter   : none
     Return      : none
     */
    func logout(){
        
        //Logout Firebase User
        let firebaseAuth = Auth.auth()
        
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }

    }
}

//
//  ServiceAPI.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 02/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import FirebaseDatabase

// Abstraction for all the service call in the app
protocol FirebaseAPIServiceProtocol {
    
    func fetchLandmarkUsers(completion: @escaping (Result<[User], FirebaseDBError>) -> Void )
    func saveLandmarkUser(landmarkUser: User, completion: @escaping (Result<User, Error>) -> Void )
    
    func fetchAllRemarksFromFirebase(completion: @escaping (Result<[Remark], FirebaseDBError>) -> Void )
    func saveUserRemark(landmarkRemark: Remark, completion: @escaping (Result<Remark, Error>) -> Void )

}

enum FirebaseDBError: Error {
    case noData
}

class FirebaseAPIService: FirebaseAPIServiceProtocol {
    
    // Initialise Firebase DB references
    var dbUserRef: DatabaseReference = Database.database().reference(withPath: StringConstants.FirebaseUserDBRef)
    var dbRemarkRef: DatabaseReference = Database.database().reference(withPath: StringConstants.FirebaseRemarkDBRef)

    /*
     Method      : fetchLandmarkUsers
     Description : Fetch all the users from Firebase Database
     parameter   : Completion handler to notify finished operation
     Return      : none
     */
    func fetchLandmarkUsers(completion: @escaping (Result<[User], FirebaseDBError>) -> Void ){
        
        
        dbUserRef.observeSingleEvent (of: .value, with: { snapshot in
            
            guard snapshot.value != nil else { completion(.failure(.noData)); return}
            
            var landmarkUserArr: [User] = []
            
            if snapshot.children.allObjects.count == 0{
                completion(.success(landmarkUserArr))

            }
            else {
                
                for child in (snapshot.children.allObjects as? [DataSnapshot])! {
                    if let value = child.value as? [String: AnyObject],
                       let landmarkUser = User(dictionary: value) {
                        landmarkUserArr.append(landmarkUser)
                        
                    }
                }
                completion(.success(landmarkUserArr))
            }
            
        })
        
    }
    
    /*
     Method      : saveLandmarkUser
     Description : Save new logged in user to Firebase Database
     parameter   : User model to save
     Return      : none
     */
    func saveLandmarkUser(landmarkUser: User, completion: @escaping (Result<User, Error>) -> Void ){
        
        let  child = self.dbUserRef.childByAutoId()
        child.setValue(landmarkUser.userDict()) { (error, reference) in
            if (error != nil){
                completion(.failure(error!))
            }
            completion(.success(landmarkUser))
        }
    }
    
    /*
     Method      : fetchAllRemarksFromFirebase
     Description : Fetch all the remarks from Firebase Database
     parameter   : Completion handler to notify finished operation
     Return      : none
     */
    func fetchAllRemarksFromFirebase(completion: @escaping (Result<[Remark], FirebaseDBError>) -> Void ) {
        
        dbRemarkRef.observeSingleEvent (of: .value, with: { snapshot in
            
            guard snapshot.value != nil else { completion(.failure(.noData)); return}
            
            var landmarkRemarkArr: [Remark] = []
            
            if snapshot.children.allObjects.count == 0{
                completion(.success(landmarkRemarkArr))

            }
            else {
                for child in (snapshot.children.allObjects as? [DataSnapshot])! {
                    if let value = child.value as? [String: AnyObject],
                       let landmarkRemark = Remark(dictionary: value) {
                        landmarkRemarkArr.append(landmarkRemark)
                    }
                }
                completion(.success(landmarkRemarkArr))

            }
        })

        
    }
    
    /*
     Method      : saveUserRemark
     Description : Save user remarks to Firebase Database
     parameter   : Remark model to save
     Return      : none
     */
    func saveUserRemark(landmarkRemark: Remark, completion: @escaping (Result<Remark, Error>) -> Void ) {
        
        let  child = self.dbRemarkRef.childByAutoId()
        
        print("\(landmarkRemark.remarkDict())")
        child.setValue(landmarkRemark.remarkDict()) { (error, reference) in
            if (error != nil){
                completion(.failure(error!))
            }
            completion(.success(landmarkRemark))
        }
        
    }


}

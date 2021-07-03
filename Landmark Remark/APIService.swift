//
//  ServiceAPI.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 02/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
    
    var dbUserRef: DatabaseReference = Database.database().reference(withPath: "landmarkUsers")
    var dbRemarkRef: DatabaseReference = Database.database().reference(withPath: "landmarkRemarks")

    
    func fetchLandmarkUsers(completion: @escaping (Result<[User], FirebaseDBError>) -> Void ){
        
        
//        dbRef.observe(.value, with: { (snapshot) in
        dbUserRef.observeSingleEvent (of: .value, with: { snapshot in
            
            guard snapshot.value != nil else { completion(.failure(.noData)); return}
            
            var landmarkUserArr: [User] = []
            
            if snapshot.children.allObjects.count == 0{
                completion(.success(landmarkUserArr))

            }
            
            for child in (snapshot.children.allObjects as? [DataSnapshot])! {
                if let value = child.value as? [String: AnyObject],
                   let landmarkUser = User(dictionary: value) {
                    landmarkUserArr.append(landmarkUser)
                        completion(.success(landmarkUserArr))
                }
            }
            
        })
        
    }
    
    func saveLandmarkUser(landmarkUser: User, completion: @escaping (Result<User, Error>) -> Void ){
        
        let  child = self.dbUserRef.childByAutoId()
        child.setValue(landmarkUser.userDict()) { (error, reference) in
            if (error != nil){
                completion(.failure(error!))
            }
            completion(.success(landmarkUser))
        }
    }
    
    func fetchAllRemarksFromFirebase(completion: @escaping (Result<[Remark], FirebaseDBError>) -> Void ) {
        
    }
    
    func saveUserRemark(landmarkRemark: Remark, completion: @escaping (Result<Remark, Error>) -> Void ) {
        
        let  child = self.dbRemarkRef.childByAutoId()
        child.setValue(landmarkRemark.remarkDict()) { (error, reference) in
            if (error != nil){
                completion(.failure(error!))
            }
            completion(.success(landmarkRemark))
        }
        
    }


}

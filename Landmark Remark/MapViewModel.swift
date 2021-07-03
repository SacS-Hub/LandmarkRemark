//
//  MapViewModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 03/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation

protocol RemarksDelegates: AnyObject {
    
    func remarkSavedWithSuccess(_ remark: Remark)
    func remarksFetchedWithSuccess(_ status: Bool)
    func operationFailedWithError(_ message: String)
//    func reloadAnnotations()
}

final class MapViewModel {
    
    var remarksArray: [Remark] = [Remark]()
    let apiService: FirebaseAPIServiceProtocol
    
    weak var delegate : RemarksDelegates?
    
    init(apiService: FirebaseAPIServiceProtocol = FirebaseAPIService()) {
        self.apiService = apiService
    }

    func getAllRemarks(completion: @escaping (_ Landmark_Remark: Remark?) -> Void){
        
        apiService.fetchAllRemarksFromFirebase(completion: ({ [weak self] result in
            guard let self = self else {return}
                                                                
            switch result {
            case .success(let response):
                self.remarksArray = response
                self.delegate?.remarksFetchedWithSuccess(true)
                print("success")
            case .failure(let error):
                self.delegate?.operationFailedWithError(error.localizedDescription)
                print("error")
            }}))
    
    }
    
    func saveUserRemark (landmarkRemark: Remark, completion: @escaping (_ landmarkUser: Remark?) -> Void) {
        
        apiService.saveUserRemark(landmarkRemark: landmarkRemark, completion: ({ [weak self] result in
            guard let self = self else {return}
            
            switch result {
            
            case .success(let response):
                self.remarksArray.append(response)
                self.delegate?.remarkSavedWithSuccess(response)
                print("success")
            case .failure(let error):
                self.delegate?.operationFailedWithError(error.localizedDescription)
                print("error")
            }
        }))
    }
    

}

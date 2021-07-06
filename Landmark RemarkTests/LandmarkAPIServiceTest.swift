//
//  LandmarkAPIServiceTest.swift
//  Landmark RemarkTests
//
//  Created by Sachin Jagat on 05/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import XCTest
@testable import Landmark_Remark

class LandmarkAPIServiceTest: XCTestCase {

    var apiService: FirebaseAPIService?
        
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        apiService = FirebaseAPIService()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        apiService = nil
    }

    // Firebase DB service test case to fetch all remarks
    func testFetchAllFirebaseRemarks() {
        
        //Given
        guard let service = apiService else {
            return
        }
        
        // When
        let expect = XCTestExpectation(description: "callback")
        
        service.fetchAllRemarksFromFirebase(completion: ({ result in
            
            guard case .success(let data) = result else {
                return
            }
            expect.fulfill()
            
            data.forEach({
                (remark: Remark!) in
                
                // Then
                XCTAssertNotNil(remark.message)
            })
        }))
        
        wait(for: [expect], timeout: 5.0)
    }

    // Firebase DB service test case to save remark
    func testAddRemarkFirebaseService () throws {
        //Given
        guard let service = apiService else {
            return
        }
        
        let remark = Remark(remarkId: "", message: "This is unit test case", latitude: -33.86961623924146, longitude: 151.2087044589725, date: Utilities.dateToString(date: Date()), distance: 0.0, user: User.init(userId: "ABC@#$", username: "&^%#%_"))
        
        // When
        let expect = XCTestExpectation(description: "callback")
        
        service.saveUserRemark(landmarkRemark: remark, completion: ({ result in
            
            guard case .success(let data) = result else {
                return
            }
            expect.fulfill()
            
            // Then
            XCTAssertNotNil(data.message)
        }))
        wait(for: [expect], timeout: 5.0)
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

//
//  LoginTestCase.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import XCTest
@testable import Expreso_Tec_App


class LoginTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testID(){
        idTestForError(nil, expectedError: LoginError.IDNull)
        idTestForError("", expectedError: LoginError.IDEmpty)
        //Spaces test
        idTestForError("A013273 11", expectedError: LoginError.IDInvalidLength)
        idTestForError(" A01327311", expectedError: LoginError.IDInvalidLength)
        idTestForError(" 01327311", expectedError: LoginError.IDMalformed)
        idTestForError("A012 7311", expectedError: LoginError.IDMalformed)

        //Format test
        idTestForError("@01327311", expectedError: LoginError.IDMalformed)
        idTestForError("B01327311", expectedError: LoginError.IDMalformed)
        idTestForError("'01327311", expectedError: LoginError.IDMalformed)
        idTestForError("B01327311", expectedError: LoginError.IDMalformed)
        idTestForError("e01327311", expectedError: LoginError.IDMalformed)
        idTestForError("F01327311", expectedError: LoginError.IDMalformed)
        idTestForError("h01327311", expectedError: LoginError.IDMalformed)
        idTestForError("001327311", expectedError: LoginError.IDMalformed)
        idTestForError("AA0132731", expectedError: LoginError.IDMalformed)
        idTestForError("AAA013278", expectedError: LoginError.IDMalformed)
        
        //Length
        idTestForError("A0132731", expectedError: LoginError.IDInvalidLength)
        idTestForError("00132731", expectedError: LoginError.IDInvalidLength)
        idTestForError("0013231", expectedError: LoginError.IDInvalidLength)
        idTestForError("A013231", expectedError: LoginError.IDInvalidLength)
        idTestForError("A013273112", expectedError: LoginError.IDInvalidLength)
        idTestForError("AA13273112", expectedError: LoginError.IDInvalidLength)
        idTestForError("AB013273112", expectedError: LoginError.IDInvalidLength)
        idTestForError("A2313273112", expectedError: LoginError.IDInvalidLength)
        
        //VALID
        idTestForError("A01323311", expectedError: nil)
        idTestForError("L01323311", expectedError: nil)
        idTestForError("a01323311", expectedError: nil)
        idTestForError("l01323311", expectedError: nil)
        idTestForError("D01323311", expectedError: nil)
        idTestForError("d01323311", expectedError: nil)
    }
    
    func idTestForError(str : String?, expectedError : LoginError?){
        genericTest(str, expectedError: expectedError, type: .ID)
    }
    
    func passwordTestForError(str : String?, expectedError : LoginError?){
        genericTest(str, expectedError: expectedError, type: .Password)
    }

    func genericTest(str : String?,  expectedError : LoginError?, type : ValidationType){
        do{
            if type == .ID{
                try User.validateID(str)
            }
            else if type == .Password{
                try User.validatePassword(str)
            }
            else{
                XCTFail("Invalid type sent to function")
            }
            if expectedError != nil{
                XCTFail("Expected error of type \(expectedError). Recieved nothing instead")
            }
        }
        catch{
            XCTAssertTrue(error is LoginError, "Error should be a login error")
            let foundError = error as! LoginError
            XCTAssertEqual(foundError, expectedError, "Expected error of type \(expectedError). Recieved \(foundError) instead")
        }
    }
    
    
    
    func testPassword(){
        passwordTestForError(nil, expectedError: LoginError.PasswordNull)
        passwordTestForError("", expectedError: LoginError.PasswordEmpty)
        passwordTestForError("asdfgh", expectedError: nil)
        passwordTestForError("asdgh", expectedError: LoginError.PasswordTooShort)
        passwordTestForError("sdgh", expectedError: LoginError.PasswordTooShort)
    }
    
    func testWhole(){
        //Rigth data
        loginTestGeneric("A01327311", password: "testing1", login: true)
        loginTestGeneric("a01327311", password: "testing1", login: true)
        loginTestGeneric("A01327312", password: "testing2", login: true)
        loginTestGeneric("a01327312", password: "testing2", login: true)
        //No id matching nor pass
        loginTestGeneric("A09827311", password: "testing4", login: false)
        //No matching pass
        loginTestGeneric("A01327311", password: "testing4", login: false)
        //No matching id
        loginTestGeneric("A01327315", password: "testing1", login: false)
        //Matching different tuples
        loginTestGeneric("A01327311", password: "testing2", login: false)

        
    }
    
    func loginTestGeneric(id : String, password : String, login : Bool){
        var userLogged = false
        let expectation = self.expectationWithDescription("LoginRigth")
        
        User.loginWithData(id, password: password) {
            (u, e) in
            if let user = u{
                if user.userID == id.capitalizedString{
                    userLogged = true
                }
                else{
                    XCTFail("Retrived not requested user")
                }
            }
            else if let error = e{
                if !login && error != LoginError.InvalidData{
                    XCTFail("Error must been an invalid data. For testing the parameters use passwordTestForError and idTestForError.")
                }
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(7) {
            (error) in
            if login{
                XCTAssertTrue(userLogged, "User must be logged at this point on user \(id) and password \(password)")
            }
            else{
                XCTAssertFalse(userLogged, "User must not be logged as false was passed")

            }
        }
    }
    
    
    
    enum ValidationType{
        case ID, Password
    }
}



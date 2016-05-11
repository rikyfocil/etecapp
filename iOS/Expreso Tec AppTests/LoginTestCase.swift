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
    
    func testID(){
        idTestForError(nil, validity: ValidType.Invalid(LoginError.IDNull) )
        idTestForError("", validity: ValidType.Invalid( LoginError.IDEmpty) )
        //Spaces test
        idTestForError("A013273 11", validity: ValidType.Invalid( LoginError.IDInvalidLength) )
        idTestForError(" A01327311", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError(" 01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("A012 7311", validity: ValidType.Invalid( LoginError.IDMalformed))

        //Format test
        idTestForError("@01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("B01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("'01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("B01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("e01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("F01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("h01327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("001327311", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("AA0132731", validity: ValidType.Invalid( LoginError.IDMalformed))
        idTestForError("AAA013278", validity: ValidType.Invalid( LoginError.IDMalformed))
        
        //Length
        idTestForError("A0132731", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError("00132731", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError("0013231", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError("A013231", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError("A013273112", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError("AA13273112", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError("AB013273112", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        idTestForError("A2313273112", validity: ValidType.Invalid( LoginError.IDInvalidLength))
        
        //VALID
        idTestForError("A01323311", validity: ValidType.Rider)
        idTestForError("L01323311", validity: ValidType.Rider)
        idTestForError("a01323311", validity: ValidType.Rider)
        idTestForError("l01323311", validity: ValidType.Rider)
        idTestForError("D01323311", validity: ValidType.Driver)
        idTestForError("d01323311", validity: ValidType.Driver)
    }
    
    func idTestForError(str : String?, validity : ValidType ){
        genericTest(str, type: .ID, validFor: validity)
    }
    
    func passwordTestForError(str : String?, expectedError : LoginError?){
        genericTest( str, type: .Password, validFor: expectedError == nil ? ValidType.Valid : ValidType.Invalid(expectedError!) )
    }

    func genericTest(str : String?, type : ValidationType, validFor : ValidType){
        
        //Validate parameters sent to function
       
        
        switch validFor {
       
        case .Valid:
        
            if type == .ID{
                XCTFail("Valid is only available for password. Please use Driver or Rider for ID")
            }
        
        case .Rider, .Driver:
            
            if type == .Password{
                XCTFail("Rider and driver is only available for users. Please use Valid for Password")
            }
         
        default:
            break;
        
        }
        
        if type == .ID{
        
            do{
                
                try LoginSystem.validateID(str)
                
                
                switch validFor {
                
                case .Invalid(let error):
                    XCTFail("Failed test. Expecting \(error) but the ID was marked as valid")
                
               
                /*Cross check from this point*/
                case .Driver:
                    
                    try LoginSystem.validateIDForDrivers(str)

                    do{
                        try LoginSystem.validateIDForStandardUser(str)
                        XCTFail("A driver valid id is not a rider valid id")
                    }
                    catch{}
                    
                case .Rider:
                    try LoginSystem.validateIDForStandardUser(str)
                    
                    do{
                        try LoginSystem.validateIDForDrivers(str)
                        XCTFail("A driver valid id is not a rider valid id")
                    }
                    catch{}
                
                default: break
                    
                }
                
                
            }
            catch let error as LoginError{
                
                if case ValidType.Invalid(let lerror) = validFor{
                    XCTAssertEqual(lerror, error, "Expected \(error) but got \(lerror)")
                }
                else{
                    XCTFail("Error \(error) obtained but the test was marked as \(validFor)")
                }
                
            }
            catch{
                XCTFail("Invalid error thrown")
            }
        
        }
        else{
        
            do{
                
                try LoginSystem.validatePassword(str)
                
                if case ValidType.Invalid(let error) = validFor{
                    
                    XCTFail("Failed test. Expecting \(error) but the password was marked as valid")
                    
                }
                
            }
            catch let error as LoginError{
                
                if case ValidType.Invalid(let lerror) = validFor{
                    XCTAssertEqual(lerror, error, "Expected \(error) but got \(lerror)")
                }
                else{
                    XCTFail("Error \(error) obtained but the test was marked as \(validFor)")
                }
                
            }
            catch{
                XCTFail("Invalid error thrown")
            }
            
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
        loginTestGeneric("A01327311", password: "testing1", login: ValidType.Rider)
        loginTestGeneric("a01327311", password: "testing1", login: ValidType.Rider)
        loginTestGeneric("A01327312", password: "testing2", login: ValidType.Rider)
        loginTestGeneric("a01327312", password: "testing2", login: ValidType.Rider)
        loginTestGeneric("d00000001", password: "testingd", login: ValidType.Driver)
        loginTestGeneric("D00000001", password: "testingd", login: ValidType.Driver)
        
        //No id matching nor pass
        loginTestGeneric("A09827311", password: "testing4", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("D12300012", password: "testingf", login: ValidType.Invalid(LoginError.UnknownError))

        //No matching pass
        loginTestGeneric("A01327311", password: "testing4", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("D00000001", password: "testingf", login: ValidType.Invalid(LoginError.UnknownError))

        //No matching id
        loginTestGeneric("A01327315", password: "testing1", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("D00001231", password: "testingd", login: ValidType.Invalid(LoginError.UnknownError))

        //Matching different tuples
        loginTestGeneric("A01327311", password: "testing2", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("D00000037", password: "testingd", login: ValidType.Invalid(LoginError.UnknownError))

        //Different casing password
        loginTestGeneric("D00000001", password: "Testingd", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("D00000001", password: "TESTINGD", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("A01327311", password: "Testing1", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("A01327311", password: "TESTING1", login: ValidType.Invalid(LoginError.UnknownError))

        //Send invalid data to login
        loginTestGeneric("D0000 0001", password: "Testingd", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("D00000001", password: "", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("", password: "1234567", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("D200000001", password: "testingd", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("M00000001", password: "testingd", login: ValidType.Invalid(LoginError.UnknownError))
        loginTestGeneric("Q00000001", password: "testingd", login: ValidType.Invalid(LoginError.UnknownError))

        
    }
    
    func loginTestGeneric(id : String, password : String, login : ValidType){

        var userLogged = false
        let expectation = self.expectationWithDescription("LoginRigth")
        
        LoginSystem.loginWithData(id, password: password, userSuccess: {
            
            (user) in
            if case .Rider = login{}
            else{
                XCTFail("Got a rider user but was expecting a \(login)")
            }
            userLogged = true
            XCTAssertEqual(id.uppercaseString, user.userID, "Logged not requestest rider")
            expectation.fulfill()

            }, driverSuccess: {
               
                (driver) in
                if case .Driver = login{}
                else{
                    XCTFail("Got a driver user but was expecting a \(login)")
                }
                userLogged = true
                expectation.fulfill()
       
        }){
            (_) in
            if case .Invalid(_) = login{}
            else{
                XCTFail("Could not loging but was expecting a \(login)")
            }
            expectation.fulfill()
        }
        
        
        waitForExpectationsWithTimeout(7) {
            (error) in
            
            if let err = error{
                XCTFail("Error raised by timeout \(err)")
            }
            
            switch login{
            
            case .Driver, .Rider, .Valid:
                XCTAssertTrue(userLogged, "Expected any type of user to be logged by this point")
            case .Invalid(_):
                XCTAssertFalse(userLogged, "Expect login failure")
            }
            
        }
    }
    
    enum ValidationType{
        
        case ID
        case Password
    
    }
    
    enum ValidType{
    
        case Invalid(LoginError)
        case Valid
        case Driver
        case Rider
        
    }
    
    
}



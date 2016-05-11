//
//  UserTest.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 10/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import XCTest
@testable import Expreso_Tec_App

class UserTest: XCTestCase {

    
    var user : User!
    var routes : [Route]!
    
    var logedUser = false
    var retrivedRoutes = false
    
    override func setUp() {
        
        super.setUp()
        self.continueAfterFailure = false
        
        let expectation2 : XCTestExpectation
        
        if !logedUser || !retrivedRoutes{
            getUser("waiting for users"){
                u in self.user = u
            }
            expectation2 = expectationWithDescription("waiting for routes")
        }
        else{
            return
        }
        
        RouteLoader.notifyWhenLoaded {
            (routes) in
            if routes == nil{
                XCTFail("Ups. Failed to load routes")
            }
            
            self.routes = routes!
            self.retrivedRoutes = true
            expectation2.fulfill()
        }
        
        RouteLoader.startGetingRoutes()
        
        waitForExpectationsWithTimeout(10) {
            (error) in
            if error != nil{
                XCTFail("Time out for user or routes")
            }
        }
        
    }
    
    func getUser(str : String, callback: (User) ->()){
        
        let expectation = expectationWithDescription(str)
        LoginSystem.loginWithData("A01327311", password: "testing1", userSuccess: {
            (userL) in
            
            callback(userL)
            self.logedUser = true
            expectation.fulfill()
            
            }, driverSuccess: {
                (_) in
                XCTFail("Failed to login correct user. Please refer to login test cases")
        }) {
            (_) in
            XCTFail("Failed to login user. Please refer to login test cases")
        }
        
    }
    
    func testUnscribe(){
    
        var routes = self.user!.subscribedRoutes
        
        XCTAssertGreaterThan(routes.count, 0, "Function cannot work without routes. Test suscribe to route and test this method again")
        
        let route = routes.first!
        let expectation = expectationWithDescription("callChange")
        
        user?.registerForRouteChangingNotifications({
            _ -> (Bool) in
            expectation.fulfill()
            return false
        })
        
        routes.removeFirst()
        user!.updateRouteSubscriptions(routes) {
            (completed) in
            XCTAssert(completed)
        }
        
        waitForExpectationsWithTimeout(8) {
            (error) in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertFalse(user!.subscribedRoutes.contains(route), "User unsubscribed from route")
        
        var nuser : User!
        getUser("Cross check"){
            u in nuser = u
        }
        
        waitForExpectationsWithTimeout(8) {
            (error) in
            XCTAssertNil(error, "Failed attempt to retrieve the user again from db")
        }
        
        XCTAssertFalse(nuser!.subscribedRoutes.contains(route), "User unsubscribed from route")
        XCTAssertEqual(routes.count, user!.subscribedRoutes.count)
        XCTAssertEqual(routes.count, nuser!.subscribedRoutes.count)

    }

    func testSubscribe(){
        
        
        let uroutes = self.user!.subscribedRoutes
        
        XCTAssertLessThan(uroutes.count, self.routes.count, "User may be subscribed to all the routes. Please unsubscribe 1 (Call testUnsubscribe)")

        var route : Route!

        for routeIterator in self.routes{
            
            if !uroutes.contains(routeIterator){
                route = routeIterator
                break
            }
            
        }
        
        let expectation = expectationWithDescription("callChange")
        
        user?.registerForRouteChangingNotifications({
            _ -> (Bool) in
            expectation.fulfill()
            return false
        })
        
        user!.updateRouteSubscriptions(uroutes + [route]) {
            (completed) in
            XCTAssert(completed)
        }
        
        waitForExpectationsWithTimeout(8) {
            (error) in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertTrue(user!.subscribedRoutes.contains(route), "User didn't suscribed to route")
        
        var nuser : User!
        getUser("Cross check"){
            u in nuser = u
        }
        
        waitForExpectationsWithTimeout(8) {
            (error) in
            XCTAssertNil(error, "Failed attempt to retrieve the user again from db")
        }
        
        XCTAssertTrue(nuser!.subscribedRoutes.contains(route), "User didn't suscribed to route")
        XCTAssertEqual(uroutes.count + 1, user!.subscribedRoutes.count)
        XCTAssertEqual(uroutes.count + 1, nuser!.subscribedRoutes.count)
        
    }

}

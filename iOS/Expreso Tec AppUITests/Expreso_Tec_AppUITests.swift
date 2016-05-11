//
//  Expreso_Tec_AppUITests.swift
//  Expreso Tec AppUITests
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import XCTest

class Expreso_Tec_AppUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
}

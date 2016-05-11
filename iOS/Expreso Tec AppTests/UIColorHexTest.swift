//
//  UIColorHexTest.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 10/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import XCTest
import Expreso_Tec_App

class UIColorHexTest: XCTestCase {

    func testHexColor() {
        
        XCTAssertNil(UIColor(fromHexHashtagedString: ""))
        XCTAssertNil(UIColor(fromHexHashtagedString: "FFFFFF"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#A"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#AA"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#AAAAA"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#AAAAAAA"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#FFFFF-"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#GGGGGG"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#IIIIII"))
        XCTAssertNil(UIColor(fromHexHashtagedString: "#0000-1B"))
        
        let red = UIColor(fromHexHashtagedString: "#FF0000")
        let green = UIColor(fromHexHashtagedString: "#00ff00")
        let blue = UIColor(fromHexHashtagedString: "#0000FF")
        
        guard red != nil && blue != nil && green != nil else{
            XCTFail("A color from valid hexadecimal was not created")
            return
        }
        
        XCTAssertEqual(green!, UIColor.greenColor())
        XCTAssertEqual(blue!, UIColor.blueColor())
        XCTAssertEqual(red!, UIColor.redColor())

    }
    

}

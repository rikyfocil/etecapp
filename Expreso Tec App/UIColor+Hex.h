//
//  UIColor+Hex.h
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 30/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
This category provides an extension to UIColor so it can be created with a Hexadecimal RGB String
 */
@interface UIColor(hexified)

/**
 This method provides an extension to UIColor that allows it to be formed with a Hexadecimal String formed as the example
 
 @param: string: The hex string that wants to be be converted formed like #FFFFFF
 
 @return: The UIColor associated to the string or nil if the format was not correct
 
 */
+(instancetype _Nullable) colorFromHexHashtagedString: (NSString* _Nonnull) string;

@end

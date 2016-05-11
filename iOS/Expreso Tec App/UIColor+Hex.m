//
//  UIColor+Hex.m
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 30/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor(hexified)

+(instancetype _Nullable) colorFromHexHashtagedString: (NSString* _Nonnull) string{
    
    if(string == nil || string.length != 7)
        return nil;
    
    
    
    for(int i = 1; i < string.length; i++){

        if([string characterAtIndex:i] >= '0' && [string characterAtIndex:i] <= '9'){
            continue;
        }
        if([string characterAtIndex:i] >= 'A' && [string characterAtIndex:i] <= 'F'){
            continue;
        }
        if([string characterAtIndex:i] >= 'a' && [string characterAtIndex:i] <= 'f'){
            continue;
        }
        
        return nil;
    }
    
    
    NSUInteger red, green, blue;
    int scanned = sscanf([string UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
    
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
}


@end

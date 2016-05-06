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
    
    NSUInteger red, green, blue;
    int scanned = sscanf([string UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
    
    if(scanned < 3){
        return nil;
    }
    
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
}


@end

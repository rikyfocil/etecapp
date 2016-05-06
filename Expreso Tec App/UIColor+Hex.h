//
//  UIColor+Hex.h
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 30/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(hexified)

+(instancetype _Nullable) colorFromHexHashtagedString: (NSString* _Nonnull) string;

@end

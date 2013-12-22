//
//  UIColor+UIColor_RGB.h
//  Notes
//
//  Created by Adam D. Fanslau on 6/19/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NAV_BAR_COLOR_TEMP [UIColor colorWithR:50 G:132 B:229 alpha:1] //colorWithR:0 G:128 B:255 alpha:1]//colorWithR:0 G:144 B:217 alpha:1]//128 B:191 alpha:1]  //82 G:153 B:204 alpha:1]

@interface UIColor (UIColor_RGB)
+ (UIColor*)colorWithR:(float)r G:(float)g B:(float)b alpha:(float)alpha;
+ (UIColor*)colorWithGray:(float)gray alpha:(float)alpha;
+ (UIColor*)iOS7BlueColor;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end

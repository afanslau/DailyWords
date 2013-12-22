//
//  NSDate+Misc.h
//  Notes
//
//  Created by Adam D. Fanslau on 6/24/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import <Foundation/Foundation.h>

//Remember that [NSDate dateWithNaturalLanguageString:] exists! It will prove useful in the future when recognizing text


@interface NSDate (Misc)
+ (NSDate *)dateWithoutTime;
+ (NSDate*)dateWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
- (NSDate *)dateByAddingDays:(NSInteger)numDays;
- (NSDate *)dateAsDateWithoutTime;
- (NSDate *)dateWithZeroSeconds;
- (int)differenceInDaysTo:(NSDate *)toDate;
- (NSString *)formattedDateString;
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;
+ (NSString *)formattedStringUsingTimeInterval:(NSTimeInterval)seconds;
- (NSDate*)dateWithSameTimeAsDate:(NSDate*)timeDate;


@end

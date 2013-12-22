//
//  NSDate+Misc.m
//  Notes
//
//  Created by Adam D. Fanslau on 6/24/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import "NSDate+Misc.h"
NSTimeInterval const justNow = 5;

@implementation NSDate(Misc)
+ (NSDate *)dateWithoutTime
{
    return [[NSDate date] dateAsDateWithoutTime];
}
+ (NSDate*)dateWithDay:(int)day month:(int)month year:(int)year
{
//    NSDateComponents *comps = [[NSDateComponents alloc] init];
//    [comps setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
//    [comps setDay:day];
//    [comps setMonth:month];
//    [comps setYear:year];

    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
    [tempFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *message = [NSString stringWithFormat:@"%04d-%02d-%02d 0:0:0", year, month, day];
    return [tempFormatter dateFromString:message];
    
}

-(NSDate *)dateByAddingDays:(NSInteger)numDays
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:numDays];
    
    NSDate *date = [gregorian dateByAddingComponents:comps toDate:self options:0];
    return date;
}
- (NSDate *)dateAsDateWithoutTime
{
    NSString *formattedString = [self formattedDateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE MMMM dd, yyyy"];
    NSDate *ret = [formatter dateFromString:formattedString];
    return ret;
}
- (NSDate *)dateWithZeroSeconds
{
    NSTimeInterval time = floor([self timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}
- (int)differenceInDaysTo:(NSDate *)toDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                fromDate:self
                                                  toDate:toDate
                                                 options:0];
    NSInteger days = [components day];
    return days;
}

- (NSString *)formattedDateString
{
    return [self formattedStringUsingFormat:@"EEEE MMMM dd, yyyy"];
}
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

+ (NSString*)formattedStringUsingTimeInterval:(NSTimeInterval)seconds
{
    if (seconds<justNow) return @"Just Now";
    NSInteger minutes = seconds/60;
    NSInteger hours = seconds/(60*60);
    NSInteger days = seconds/(60*60*24);
    NSInteger weeks = seconds/(60*60*24*7);
    NSInteger months = truncf(seconds/(60*60*24*7*52.0)*12);
    NSInteger years = seconds/(60*60*24*7*52);
    
    
    NSString* time;
    NSInteger num;
    if (years > 0) {
        time = @"year";
        num = years;
    } else if (months > 0) {
        time = @"month";
        num = months;
    } else if (weeks > 0) {
        time = @"week";
        num = weeks;
    } else if (days > 0) {
        time = @"day";
        num = days;
    } else if (hours > 0) {
        time = @"hour";
        num = hours;
    } else if (minutes > 0) {
        time = @"minute";
        num = minutes;
    } else {
        time = @"second";
        num = seconds;
    }
    if (num>1 || num==0) {
        time = [time stringByAppendingString:@"s"];
    }
    NSString* dateString = [NSString stringWithFormat:@"%d %@ ago", num, time];
    return dateString;
}

- (NSDate*)dateWithSameTimeAsDate:(NSDate*)timeDate
{
    NSTimeInterval time = [timeDate timeIntervalSinceDate:[timeDate dateAsDateWithoutTime]];
    NSDate *finalDate = [[self dateAsDateWithoutTime] dateByAddingTimeInterval:time];
    return finalDate;
}

@end
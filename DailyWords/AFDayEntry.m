//
//  AFDayEntry.m
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import "AFDayEntry.h"
#import "NSDate+Misc.h"


@implementation AFDayEntry

@dynamic date;
@dynamic text;
@dynamic wordCount;

- (BOOL)isToday
{
    BOOL test = [[self.date dateAsDateWithoutTime] isEqualToDate:[NSDate dateWithoutTime]];
    NSLog(@"isToday: %d", test);
    return test;
}

- (NSUInteger)calculateWordCount:(NSString*)string
{
    NSLog(@"Calculating word count...");
    NSDate* start = [NSDate date];
    __block NSUInteger wordCount = 0;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:NSStringEnumerationByWords
                            usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                wordCount++;
                            }];
    NSLog(@"Returned in %f seconds", [start timeIntervalSinceNow]);
    return wordCount;
}

- (void)setText:(NSString *)text
{
    [self willChangeValueForKey:@"text"];
    [self setPrimitiveValue:text forKey:@"text"];
    [self setWordCount:[NSNumber numberWithInt:[self calculateWordCount:text]]];
    [self didChangeValueForKey:@"text"];
}

- (void)setDate:(NSDate *)date
{
    [self willChangeValueForKey:@"date"];
    [self setPrimitiveValue:[date dateAsDateWithoutTime] forKey:@"date"];
    [self didChangeValueForKey:@"date"];
}

@end

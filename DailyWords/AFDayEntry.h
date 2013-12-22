//
//  AFDayEntry.h
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AFDayEntry : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * wordCount;
- (BOOL)isToday;
@end

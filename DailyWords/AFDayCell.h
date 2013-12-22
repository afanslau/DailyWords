//
//  AFDayCell.h
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFDayEntry.h"

@interface AFDayCell : UITableViewCell
@property (strong, nonatomic) AFDayEntry* dayEntry;
@property (strong, nonatomic) IBOutlet UILabel* textPreviewLabel;
@property (strong, nonatomic) IBOutlet UILabel* dateLabel;
@property (strong, nonatomic) IBOutlet UILabel* wordCountLabel;

- (void)setPreferredFonts;

@end

//
//  AFDayCell.m
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import "AFDayCell.h"
#import "NSDate+Misc.h"

@implementation AFDayCell
@synthesize dayEntry = _dayEntry;
@synthesize textPreviewLabel;
@synthesize dateLabel;
@synthesize wordCountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPreferredFonts
{
    [self.dateLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.textPreviewLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self.wordCountLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDayEntry:(AFDayEntry *)dayEntry
{
    _dayEntry = dayEntry;
    [self.dateLabel setText:[dayEntry.date formattedStringUsingFormat:@"MMM d"]];
    [self.wordCountLabel setText:[NSString stringWithFormat:@"%d words", dayEntry.wordCount.integerValue]];
    [self.textPreviewLabel setText:dayEntry.text];
}

@end

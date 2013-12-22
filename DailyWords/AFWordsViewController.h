//
//  AFWordsViewController.h
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFDayEntry.h"

@interface AFWordsViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView* textView;
@property (strong, nonatomic) AFDayEntry* dayEntry;

- (IBAction)donePressed:(id)sender;

@end

//
//  AFDayTableViewController.h
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AFDayTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIButton* headerView;
@property (strong, nonatomic) IBOutlet UILabel* headerTodayLabel;
@property (strong, nonatomic) IBOutlet UILabel* headerWordCountLabel;
@property (strong, nonatomic) IBOutlet UIButton* startWritingButton;
@end

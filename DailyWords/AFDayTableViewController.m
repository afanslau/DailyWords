//
//  AFDayTableViewController.m
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//
#import "AFAppDelegate.h"
#import "AFDayTableViewController.h"
#import "AFDayCell.h"
#import "NSDate+Misc.h"
#import "AFWordsViewController.h"
#import "UIColor+UIColor_RGB.h"
#import "AMBlurView.h"

@interface AFDayTableViewController ()
@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) NSArray* dayEntries;
@property (strong, nonatomic) AFDayEntry* todaysEntry;
@property (strong, nonatomic) UIColor* backgroundColor;
@end

@implementation AFDayTableViewController
@synthesize context = _context;
@synthesize dayEntries = _dayEntries;
@synthesize todaysEntry = _todaysEntry;

static NSString* segueIdentifier = @"DayDetail";
static NSString *CellIdentifier = @"DayCell";



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backgroundColor = [UIColor colorFromHexString:@"17304d"];

    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:self.backgroundColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
  
    [self registerForNotifications];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self resetTodaysEntry];
    [self resetDayEntries];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];


//    [self setupHeaderView];
    [self.tableView reloadData];
//    [self resetWordCount];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Lazy Loading
- (NSManagedObjectContext*)context
{
    if (!_context) {
        _context = [(AFAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return _context;
}

- (void)resetDayEntries
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AFDayEntry"
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"Error fetching dates!");
    }
    [self setDayEntries:fetchedObjects];
}

- (void)resetTodaysEntry
{
    //Fetch the last day and fill in any missing days
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AFDayEntry" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    AFDayEntry* lastEntry;
    if (fetchedObjects == nil) {
        NSLog(@"Error fetching last date %@", error);
    } else if (fetchedObjects.count > 0) {
        lastEntry = [fetchedObjects lastObject];
        
        //If the last day was before yesterday, create all days in between
        NSDate* today = [NSDate dateWithoutTime];
        NSDate* lastDay = [lastEntry.date dateAsDateWithoutTime];
        NSComparisonResult comparison = [lastDay compare:today];
        AFDayEntry* nextEntry = lastEntry;
        if (comparison == NSOrderedAscending) {
            NSDate* nextDay = [lastDay dateByAddingDays:1];
            //Continue to add days until I hit tomorrow
            while ([nextDay compare:[NSDate dateWithoutTime]] != NSOrderedDescending) {
                nextEntry = [NSEntityDescription insertNewObjectForEntityForName:@"AFDayEntry" inManagedObjectContext:self.context];
                [nextEntry setDate:nextDay];
                nextDay = [nextDay dateByAddingDays:1];
            }
        } else if (comparison == NSOrderedSame) {
            NSLog(@"today = last day. Database is up to date");
        } else {
            NSLog(@"today is after today. wtf");
        }
        self.todaysEntry = nextEntry;
        
    //fetchedObjects is empty - this should only happen once.
    } else {
        self.todaysEntry = [NSEntityDescription insertNewObjectForEntityForName:@"AFDayEntry" inManagedObjectContext:self.context];
        [self.todaysEntry setDate:[NSDate dateWithoutTime]];
    }
}

//Is this good practice?
static CGFloat headerHeight = 120;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [[NSBundle mainBundle] loadNibNamed:@"DayTableHeaderView" owner:self options:nil];
    //    [self resetHeaderDate];
    //    [self resetWordCount];
    //    [self resetWriteButtonText];


    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), headerHeight);
    AMBlurView* blurView = [[AMBlurView alloc] init];
    [blurView setFrame:frame];
    [self.headerView setFrame:frame];

    [blurView setBlurTintColor:self.backgroundColor];
    [blurView setTranslucent:NO];
//    [blurView setTranslucencyAlpha:0.7];
    
    [self.headerView setBackgroundColor:[UIColor clearColor]];
//    [self.headerView setAlpha:0.5];
    [blurView addSubview:self.headerView];
    
    
    
    [self.headerWordCountLabel setText:[NSString stringWithFormat:@"You have written %ld words today", self.todaysEntry.wordCount.longValue]];
    
    NSString* buttonText = @"Continue Writing";
    if (self.todaysEntry.wordCount.integerValue == 0) {
        buttonText = @"Write Something";
    }
    [self.startWritingButton setTitle:buttonText forState:UIControlStateNormal];
    return blurView;
}

#pragma mark - Header View Methods

- (void)resetHeaderDate
{
//    [self.headerTodayLabel setText:[NSString stringWithFormat:@"Today is %@", [[NSDate date] formattedStringUsingFormat:@"MMMM d, yyyy"]]];
}
- (void)resetWordCount
{
    [self.headerWordCountLabel setText:[NSString stringWithFormat:@"You have written %ld words today", self.todaysEntry.wordCount.longValue]];
}

- (void)resetWriteButtonText
{
    NSString* buttonText = @"Continue Writing";
    if (self.todaysEntry.wordCount.integerValue == 0) {
        buttonText = @"Write Something";
    }
    [self.startWritingButton setTitle:buttonText forState:UIControlStateNormal];
}

#pragma mark - NSNotificationCenter
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significantTimeChange:) name:timeChangeNotification object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification*)notif
{
    [self.startWritingButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self.tableView reloadData];
}

- (void)significantTimeChange:(NSNotification*)notif
{
    [self resetTodaysEntry];
    [self resetDayEntries];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dayEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AFDayCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setDayEntry:[self.dayEntries objectAtIndex:indexPath.row]];
    [cell setPreferredFonts];
    return cell;
}

- (IBAction)startWritingButtonPressed:(UIButton *)sender {
    
    //Get today's entry
    [self performSegueWithIdentifier:segueIdentifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AFWordsViewController* dvc = segue.destinationViewController;
    AFDayEntry* dayEntry;
    if ([sender isKindOfClass:[UIButton class]]) {
        NSLog(@"Segue called from button");
        dayEntry = self.todaysEntry;
    } else if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSLog(@"Segue called from cell");
        NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        dayEntry = [self.dayEntries objectAtIndex:indexPath.row];
    }
    [dvc setDayEntry:dayEntry];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

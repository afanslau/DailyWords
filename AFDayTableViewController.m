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

@interface AFDayTableViewController ()
@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) NSArray* dayEntries;
@property (strong, nonatomic) AFDayEntry* todaysEntry;
@end

@implementation AFDayTableViewController
@synthesize context = _context;
@synthesize dayEntries = _dayEntries;
@synthesize todaysEntry = _todaysEntry;

static NSString* segueIdentifier = @"DayDetail";
static NSString *CellIdentifier = @"DayCell";


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupHeaderView];
    [self registerForNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [self setDayEntries:nil];
    [self.tableView reloadData];
    [self resetWordCount];
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

- (NSArray*)dayEntries
{
    if (!_dayEntries) {
        //Get dayEntries from store
        
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
        _dayEntries = fetchedObjects;
    }
    return _dayEntries;
}

- (AFDayEntry*)todaysEntry
{
    if (!_todaysEntry) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", [NSDate dateWithoutTime], [[NSDate dateWithoutTime] dateByAddingDays:1]];
        NSArray* todayArr = [self.dayEntries filteredArrayUsingPredicate:predicate];
        if (todayArr.count == 1) {
            NSLog(@"Found entry for today");
            _todaysEntry = [todayArr lastObject];
        } else if (todayArr.count > 1) {
            NSLog(@"More than one entry for today!");
            abort();
        } else {
            //No entry for today. Create one.
            NSLog(@"Create new day entry");
            _todaysEntry = [NSEntityDescription insertNewObjectForEntityForName:@"AFDayEntry" inManagedObjectContext:self.context];
            [_todaysEntry setDate:[NSDate dateWithoutTime]];
        }
    }
    return _todaysEntry;
}

#pragma mark - Header View Methods
- (void)setupHeaderView
{
    [[NSBundle mainBundle] loadNibNamed:@"DayTableHeaderView" owner:self options:nil];
    [self resetHeaderDate];
    [self resetWordCount];
    [self resetWriteButtonText];
    
    UIColor* background = [UIColor colorFromHexString:@"17304d"];
    [self.headerView setBackgroundColor:background];

    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    [grayView setBackgroundColor:background];
    [self.tableView addSubview:grayView];
    
    [self.navigationItem setTitle:@"Daily Words"];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:background];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.tableView setTableHeaderView:self.headerView];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}
- (void)resetHeaderDate
{
//    [self.headerTodayLabel setText:[NSString stringWithFormat:@"Today is %@", [[NSDate date] formattedStringUsingFormat:@"MMMM d, yyyy"]]];
}
- (void)resetWordCount
{
    [self.headerWordCountLabel setText:[NSString stringWithFormat:@"You have written %d words today", self.todaysEntry.wordCount.integerValue]];
}

- (void)resetWriteButtonText
{
    NSString* buttonText = @"Continue Writing";
    if (self.todaysEntry.wordCount.integerValue == 0) {
        buttonText = @"Start Writing";
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

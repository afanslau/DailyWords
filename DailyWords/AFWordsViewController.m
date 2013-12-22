//
//  AFWordsViewController.m
//  DailyWords
//
//  Created by Adam D. Fanslau on 12/21/13.
//  Copyright (c) 2013 Adam D. Fanslau. All rights reserved.
//

#import "AFWordsViewController.h"
#import "NSDate+Misc.h"
#import "AFAppDelegate.h"
@interface AFWordsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *wordCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) NSManagedObjectContext* context;
@end

@implementation AFWordsViewController
@synthesize context = _context;
@synthesize textView = _textView;
@synthesize dayEntry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)]];

    [self.textView setText:self.dayEntry.text];
    [self.navigationItem setTitle:[self.dayEntry.date formattedStringUsingFormat:@"MMMM d"]];
    [self.wordCountLabel setText:[NSString stringWithFormat:@"%ld words", (long)self.dayEntry.wordCount.integerValue]];
    
    [self registerForKeyboardNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSError* error;
    [self.context save:&error];
    if (error) {
        NSLog(@"Error saving context");
    }
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
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

#pragma mark - Keyboard Notifications

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    [self updateForKeyboardShowHide:note appearing:YES];
}
- (void)keyboardWillHide:(NSNotification *)note {
    [self updateForKeyboardShowHide:note appearing:NO];
}

- (void)updateForKeyboardShowHide:(NSNotification *)note appearing:(BOOL)isAppearing {
    // ignore notifications if our view isn't attached to the window
    if (self.view.window == nil)
        return;
    
    CGFloat directionalModifier = isAppearing?-1:1;
    CGRect keyboardBounds = [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat animationDuration = [[note.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // figure out table re-size based on keyboard
    CGFloat keyboardHeight;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation))
        keyboardHeight = keyboardBounds.size.height;
    else
        keyboardHeight = keyboardBounds.size.width;
    
    [UIView animateWithDuration:animationDuration animations:^{
        // resize table
        CGRect newFrame = self.textView.frame;
        newFrame.size.height += keyboardHeight * directionalModifier;
        self.textView.frame = newFrame;
    }  completion:^(BOOL finished){
        // scroll to selected cell
        if (isAppearing) {
            
            //scroll to the selected text. Does this happen automatically?
            //            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textFieldInEdit.tag inSection:0];
            //            [table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

- (void)preferredContentSizeChanged:(NSNotification*)notif
{
    [self.textView setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self.wordCountLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
}


#pragma mark - Text View Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self.dayEntry setText:textView.text];
    [self.wordCountLabel setText:[NSString stringWithFormat:@"%ld words", (long)self.dayEntry.wordCount.integerValue]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [textView scrollRangeToVisible:range];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)]];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
     [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)]];
    
    NSError* error;
    [self.context save:&error];
    if (error) {
        NSLog(@"Error saving context");
    }
}

- (IBAction)actionButtonPressed:(id)sender
{
    UIActivityViewController *activityvc = [[UIActivityViewController alloc] initWithActivityItems:@[self.dayEntry.text] applicationActivities:nil];
    [activityvc setExcludedActivityTypes:@[UIActivityTypePostToWeibo, UIActivityTypePostToVimeo, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToTwitter]];
    [self presentViewController:activityvc animated:YES completion:nil];
}

- (IBAction)donePressed:(id)sender
{
    [self.textView resignFirstResponder];
}

@end

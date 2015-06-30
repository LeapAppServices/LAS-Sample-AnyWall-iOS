//
//  WallPostCreateViewController.m
//  Anywall
//
//  Created by  on 7/31/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import "WallPostCreateViewController.h"

#import "AppDelegate.h"
#import <LAS/LAS.h>

@implementation WallPostCreateViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// Do any additional setup after loading the view from its nib.
	
	self.characterCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 154.0f, 21.0f)];
	self.characterCount.backgroundColor = [UIColor clearColor];
//	self.characterCount.textColor = [UIColor whiteColor];
//	self.characterCount.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
//	self.characterCount.shadowOffset = CGSizeMake(0.0f, -1.0f);
	self.characterCount.text = @"0/140";

	[self.textView setInputAccessoryView:self.characterCount];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextViewTextDidChangeNotification object:self.textView];
	[self updateCharacterCount:self.textView];
	[self checkCharacterCount:self.textView];

	// Show the keyboard/accept input.
	[self.textView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self.textView];
}

#pragma mark UINavigationBar-based actions

- (IBAction)cancelPost:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postPost:(id)sender {
	// Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
	[self.textView resignFirstResponder];

	// Capture current text field contents:
	[self updateCharacterCount:self.textView];
	BOOL isAcceptableAfterAutocorrect = [self checkCharacterCount:self.textView];

	if (!isAcceptableAfterAutocorrect) {
		[self.textView becomeFirstResponder];
		return;
	}

	// Data prep:
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;
	LASGeoPoint *currentPoint = [LASGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	LASUser *user = [LASUser currentUser];

	// Stitch together a postObject and send this async to LAS
	LASObject *postObject = [LASObject objectWithClassName:kLASPostsClassKey];
	[postObject setObject:self.textView.text forKey:kLASTextKey];
	[postObject setObject:user forKey:kLASUserKey];
	[postObject setObject:currentPoint forKey:kLASLocationKey];
	// Use LASACL to restrict future modifications to this object.
	LASACL *readOnlyACL = [LASACL ACL];
	[readOnlyACL setPublicReadAccess:YES];
	[readOnlyACL setPublicWriteAccess:NO];
	[postObject setACL:readOnlyACL];
	[LASDataManager saveObjectInBackground:postObject block:^(BOOL succeeded, NSError *error) {
		if (error) {
			NSLog(@"Couldn't save!");
			NSLog(@"%@", error);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
		if (succeeded) {
			NSLog(@"Successfully saved!");
			NSLog(@"%@", postObject);
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:kPostCreatedNotification object:nil];
			});
		} else {
			NSLog(@"Failed to save.");
		}
	}];

	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITextView notification methods

- (void)textInputChanged:(NSNotification *)note {
	// Listen to the current text field and count characters.
	UITextView *localTextView = [note object];
	[self updateCharacterCount:localTextView];
	[self checkCharacterCount:localTextView];
}

#pragma mark Private helper methods

- (void)updateCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	self.characterCount.text = [NSString stringWithFormat:@"%lu/140", (unsigned long)count];
	if (count > kWallPostMaximumCharacterCount || count == 0) {
		self.characterCount.font = [UIFont boldSystemFontOfSize:self.characterCount.font.pointSize];
	} else {
		self.characterCount.font = [UIFont systemFontOfSize:self.characterCount.font.pointSize];
	}
}

- (BOOL)checkCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	if (count > kWallPostMaximumCharacterCount || count == 0) {
		self.postButton.enabled = NO;
		return NO;
	} else {
		self.postButton.enabled = YES;
		return YES;
	}
}

@end

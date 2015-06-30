//
//  SettingsViewController.m
//  Anywall
//
//  Created by  on 7/30/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import "SettingsViewController.h"

#import "AppDelegate.h"
#import <LAS/LAS.h>
#import "RootViewController.h"



// UITableView enum-based configuration via Fraser Speirs: http://speirs.org/blog/2008/10/11/a-technique-for-using-uitableview-and-retaining-your-sanity.html
typedef enum {
	kSettingsTableViewDistance = 0,
	kSettingsTableViewLogout,
	kSettingsTableViewNumberOfSections
} kSettingsTableViewSections;

typedef enum {
	kSettingsLogoutDialogLogout = 0,
	kSettingsLogoutDialogCancel,
	kSettingsLogoutDialogNumberOfButtons
} kSettingsLogoutDialogButtons;

typedef enum {
	kSettingsTableViewDistanceSection250FeetRow = 0,
	kSettingsTableViewDistanceSection1000FeetRow,
	kSettingsTableViewDistanceSection4000FeetRow,
	kSettingsTableViewDistanceNumberOfRows
} kSettingsTableViewDistanceSectionRows;

static uint16_t const kSettingsTableViewLogoutNumberOfRows = 1;




@interface SettingsViewController ()

@property (nonatomic, assign) CLLocationAccuracy filterDistance;

@end


@implementation SettingsViewController

- (void)awakeFromNib {
	[super awakeFromNib];
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	self.filterDistance = appDelegate.filterDistance;
}

#pragma mark - Custom setters

// Always fault our filter distance through to the app delegate. We just cache it locally because it's used in the tableview's cells.
- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.filterDistance = aFilterDistance;
	_filterDistance = aFilterDistance;
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private helper methods

- (NSString *)distanceLabelForCell:(NSIndexPath *)indexPath {
	NSString *cellText = nil;
	switch (indexPath.row) {
		case kSettingsTableViewDistanceSection250FeetRow:
			cellText = @"250 feet";
			break;
		case kSettingsTableViewDistanceSection1000FeetRow:
			cellText = @"1000 feet";
			break;
		case kSettingsTableViewDistanceSection4000FeetRow:
			cellText = @"4000 feet";
			break;
		case kSettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			cellText = @"The universe";
			break;
	}
	return cellText;
}

- (LocationAccuracy)distanceForCell:(NSIndexPath *)indexPath {
	LocationAccuracy distance = 0.0;
	switch (indexPath.row) {
		case kSettingsTableViewDistanceSection250FeetRow:
			distance = 250;
			break;
		case kSettingsTableViewDistanceSection1000FeetRow:
			distance = 1000;
			break;
		case kSettingsTableViewDistanceSection4000FeetRow:
			distance = 4000;
			break;
		case kSettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			distance = 10000 * kFeetToMiles;
			break;
	}

	return distance;
}

#pragma mark - UINavigationBar-based actions

- (IBAction)done:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kSettingsTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch ((kSettingsTableViewSections)section) {
		case kSettingsTableViewDistance:
			return kSettingsTableViewDistanceNumberOfRows;
			break;
		case kSettingsTableViewLogout:
			return kSettingsTableViewLogoutNumberOfRows;
			break;
		case kSettingsTableViewNumberOfSections:
			return 0;
			break;
	};
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"SettingsTableView";
	if (indexPath.section == kSettingsTableViewDistance) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}

		// Configure the cell.
		cell.textLabel.text = [self distanceLabelForCell:indexPath];

		if (self.filterDistance == 0.0) {
			NSLog(@"We have a zero filter distance!");
		}

		LocationAccuracy filterDistanceInFeet = self.filterDistance * ( 1 / kFeetToMeters);
		LocationAccuracy distanceForCell = [self distanceForCell:indexPath];
		if (fabs(distanceForCell - filterDistanceInFeet) < 0.001 ) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}

		return cell;
	} else if (indexPath.section == kSettingsTableViewLogout) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}

		// Configure the cell.
		cell.textLabel.text = @"Log out of Anywall";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;

		return cell;
	}
	else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ((kSettingsTableViewSections)section) {
		case kSettingsTableViewDistance:
			return @"Search Distance";
			break;
		case kSettingsTableViewLogout:
			return @"";
			break;
		case kSettingsTableViewNumberOfSections:
			return @"";
			break;
	}
}

#pragma mark - UITableViewDelegate methods

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kSettingsTableViewDistance) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];

		// if we were already selected, bail and save some work.
		UITableViewCell *selectedCell = [aTableView cellForRowAtIndexPath:indexPath];
		if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
			return;
		}

		// uncheck all visible cells.
		for (UITableViewCell *cell in [aTableView visibleCells]) {
			if (cell.accessoryType != UITableViewCellAccessoryNone) {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

		LocationAccuracy distanceForCellInFeet = [self distanceForCell:indexPath];
		self.filterDistance = distanceForCellInFeet * kFeetToMeters;
	} else if (indexPath.section == kSettingsTableViewLogout) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out of Anywall?" message:nil delegate:self cancelButtonTitle:@"Log out" otherButtonTitles:@"Cancel", nil];
		[alertView show];
	}
}

#pragma mark - UIAlertViewDelegate methods

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == kSettingsLogoutDialogLogout) {
		// Log out.
		[LASUserManager logOut];
		
		[(RootViewController *)self.presentingViewController presentWelcomeViewController];
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
		
	} else if (buttonIndex == kSettingsLogoutDialogCancel) {
		return;
	}
}

// Nil implementation to avoid the default UIAlertViewDelegate method, which says:
// "Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button"
// Since we have "Log out" at the cancel index (to get it out from the normal "Ok whatever get this dialog outta my face"
// position, we need to deal with the consequences of that.
- (void)alertViewCancel:(UIAlertView *)alertView {
	return;
}

@end

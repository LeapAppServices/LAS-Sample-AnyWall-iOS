//
//  WallPostsTableViewController.m
//  Anywall
//
//  Created by  on 8/6/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

static CGFloat const kWallPostTableViewFontSize = 12.f;
static CGFloat const kWallPostTableViewCellWidth = 230.f; // subject to change.

// Cell dimension and positioning constants
static CGFloat const kCellPaddingTop = 5.0f;
static CGFloat const kCellPaddingBottom = 1.0f;
static CGFloat const kCellPaddingSides = 0.0f;
static CGFloat const kCellTextPaddingTop = 6.0f;
static CGFloat const kCellTextPaddingBottom = 5.0f;
static CGFloat const kCellTextPaddingSides = 5.0f;

static CGFloat const kCellUsernameHeight = 15.0f;
static CGFloat const kCellBkgdHeight = 32.0f;
static CGFloat const kCellBkgdOffset = kCellBkgdHeight - kCellUsernameHeight;

// TableViewCell ContentView tags
static NSInteger kCellBackgroundTag = 2;
static NSInteger kCellTextLabelTag = 3;
static NSInteger kCellNameLabelTag = 4;


static NSUInteger const kTableViewMainSection = 0;

#import "WallPostsTableViewController.h"

#import "AppDelegate.h"

@interface WallPostsTableViewController ()

@end

@implementation WallPostsTableViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPostCreatedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Customize the table:

		// The className to query on
		self.lasClassName = kLASPostsClassKey;

		// The key of the LASObject to display in the label of the default cell style
		self.textKey = kLASTextKey;
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPostCreatedNotification object:nil];
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self loadObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (LASQuery *)query {
	LASQuery *query = [LASQuery queryWithClassName:self.lasClassName];

	// Query for posts near our current location.

	// Get our current location:
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	CLLocation *currentLocation = appDelegate.currentLocation;
	CLLocationAccuracy filterDistance = appDelegate.filterDistance;

	// And set the query to look by location
	LASGeoPoint *point = [LASGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
	[query whereKey:kLASLocationKey nearGeoPoint:point withinKilometers:filterDistance / kMetersInAKilometer];
	[query includeKey:kLASUserKey];

	return query;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Reuse identifiers for left and right cells
	static NSString *RightCellIdentifier = @"RightCell";
	static NSString *LeftCellIdentifier = @"LeftCell";

	// Try to reuse a cell
	LASObject *object = self.objects[indexPath.row];
	BOOL cellIsRight = [[[object objectForKey:kLASUserKey] objectForKey:kLASUsernameKey] isEqualToString:[[LASUser currentUser] username]];
	UITableViewCell *cell;
	if (cellIsRight) { // User's post so create blue bubble
		cell = [tableView dequeueReusableCellWithIdentifier:RightCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RightCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"blueBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 16.0f, 11.0f)]];
			[backgroundImage setTag:kCellBackgroundTag];
			[cell.contentView addSubview:backgroundImage];

			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kCellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kCellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
		}
	} else { // Someone else's post so create gray bubble
		cell = [tableView dequeueReusableCellWithIdentifier:LeftCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LeftCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"grayBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 16.0f, 11.0f)]];
			[backgroundImage setTag:kCellBackgroundTag];
			[cell.contentView addSubview:backgroundImage];

			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kCellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kCellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
		}
	}
	
	// Configure the cell content
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kCellTextLabelTag];
	textLabel.text = [object objectForKey:kLASTextKey];
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.numberOfLines = 0;
	textLabel.font = [UIFont systemFontOfSize:kWallPostTableViewFontSize];
	textLabel.textColor = [UIColor whiteColor];
	textLabel.backgroundColor = [UIColor clearColor];
	
	NSString *username = [NSString stringWithFormat:@"- %@",[[object objectForKey:kLASUserKey] objectForKey:kLASUsernameKey]];
	UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:kCellNameLabelTag];
	nameLabel.text = username;
	nameLabel.font = [UIFont systemFontOfSize:kWallPostTableViewFontSize];
	nameLabel.backgroundColor = [UIColor clearColor];
	if (cellIsRight) {
		nameLabel.textColor = [UIColor colorWithRed:175.0f/255.0f green:172.0f/255.0f blue:172.0f/255.0f alpha:1.0f];
		nameLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.35f];
		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	} else {
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.shadowColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.35f];
		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	}
	
	UIImageView *backgroundImage = (UIImageView*) [cell.contentView viewWithTag:kCellBackgroundTag];
	
	// Move cell content to the right position
	// Calculate the size of the post's text and username
	// Calculate what the frame to fit the post text and the username
	CGSize maxSize = CGSizeMake(kWallPostTableViewCellWidth, FLT_MAX);
	
	UIFont *font = [UIFont systemFontOfSize:kWallPostTableViewFontSize];
	NSDictionary *attributes = @{NSFontAttributeName:font};
	
	CGSize textSize = [[object objectForKey:kLASTextKey] boundingRectWithSize:maxSize
																		   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
																		attributes:attributes
																		   context:nil].size;
	CGSize nameSize = [username boundingRectWithSize:maxSize
											 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
										  attributes:attributes
											 context:nil].size;
	
	CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath]; // Get the height of the cell
	CGFloat textWidth = textSize.width > nameSize.width ? textSize.width : nameSize.width; // Set the width to the largest (text of username)
	
	// Place the content in the correct position depending on the type
	if (cellIsRight) {
		[nameLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kCellTextPaddingSides-kCellPaddingSides, 
									   kCellPaddingTop+kCellTextPaddingTop+textSize.height, 
									   nameSize.width, 
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kCellTextPaddingSides-kCellPaddingSides, 
									   kCellPaddingTop+kCellTextPaddingTop, 
									   textSize.width, 
									   textSize.height)];		
		[backgroundImage setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kCellTextPaddingSides*2-kCellPaddingSides, 
											 kCellPaddingTop, 
											 textWidth+kCellTextPaddingSides*2, 
											 cellHeight-kCellPaddingTop-kCellPaddingBottom)];
		
	} else {
		[nameLabel setFrame:CGRectMake(kCellTextPaddingSides-kCellPaddingSides, 
									   kCellPaddingTop+kCellTextPaddingTop+textSize.height, 
									   nameSize.width, 
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(kCellPaddingSides+kCellTextPaddingSides, 
									   kCellPaddingTop+kCellTextPaddingTop, 
									   textSize.width, 
									   textSize.height)];
		[backgroundImage setFrame:CGRectMake(kCellPaddingSides, 
											 kCellPaddingTop, 
											 textWidth+kCellTextPaddingSides*2, 
											 cellHeight-kCellPaddingTop-kCellPaddingBottom)];
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Account for the load more cell at the bottom of the tableview if we hit the pagination limit:
	if ( (NSUInteger)indexPath.row >= [self.objects count]) {
		return [tableView rowHeight];
	}

	// Retrieve the text and username for this row:
	LASObject *object = [self.objects objectAtIndex:indexPath.row];
	Post *postFromObject = [[Post alloc] initWithLASObject:object];
	NSString *text = postFromObject.title;
	NSString *username = postFromObject.user.username;
	
	// Calculate what the frame to fit the post text and the username
	CGSize maxSize = CGSizeMake(kWallPostTableViewCellWidth, FLT_MAX);
	
	UIFont *font = [UIFont systemFontOfSize:kWallPostTableViewFontSize];
	NSDictionary *attributes = @{NSFontAttributeName:font};
	
	CGSize textSize = [text boundingRectWithSize:maxSize
										 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
									  attributes:attributes
										 context:nil].size;
	CGSize nameSize = [username boundingRectWithSize:maxSize
											 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
										  attributes:attributes
											 context:nil].size;

	// And return this height plus cell padding and the offset of the bubble image height (without taking into account the text height twice)
	CGFloat rowHeight = kCellPaddingTop + textSize.height + nameSize.height + kCellBkgdOffset;
	return rowHeight;
}


#pragma mark - WallViewControllerSelection

- (void)highlightCellForPost:(Post *)post {
	// Find the cell matching this object.
	for (LASObject *object in [self objects]) {
		Post *postFromObject = [[Post alloc] initWithLASObject:object];
		if ([post equalToPost:postFromObject]) {
			// We found the object, scroll to the cell position where this object is.
			NSUInteger index = [[self objects] indexOfObject:object];

			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kTableViewMainSection];
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

			return;
		}
	}

	// Don't scroll for posts outside the search radius.
	if ([post.title compare:kWallCantViewPost] != NSOrderedSame) {
		// We couldn't find the post, so scroll down to the load more cell.
		NSUInteger rows = [self.tableView numberOfRowsInSection:kTableViewMainSection];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(rows - 1) inSection:kTableViewMainSection];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)unhighlightCellForPost:(Post *)post {
	// Deselect the post's row.
	for (LASObject *object in [self objects]) {
		Post *postFromObject = [[Post alloc] initWithLASObject:object];
		if ([post equalToPost:postFromObject]) {
			NSUInteger index = [[self objects] indexOfObject:object];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

			return;
		}
	}
}


#pragma mark - ()

- (void)loadObjects {
	
	LASQuery *query = [self query];
	[LASQueryManager findObjectsInBackgroundWithQuery:query block:^(NSArray *objects, NSError *error) {
		if (nil == error) {
			self.objects = objects;
			[self.tableView reloadData];
			
			if (NSClassFromString(@"UIRefreshControl")) {
				[self.refreshControl endRefreshing];
			}
		}
	}];
}

- (void)distanceFilterDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)locationDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)postWasCreated:(NSNotification *)note {
	[self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

@end

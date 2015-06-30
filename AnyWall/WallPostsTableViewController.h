//
//  WallPostsTableViewController.h
//  Anywall
//
//  Created by  on 8/6/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallViewController.h"

@interface WallPostsTableViewController : UITableViewController <WallViewControllerHighlight>

@property (nonatomic, strong) NSString *lasClassName;
@property (nonatomic, strong) NSString *textKey;

@property (nonatomic, strong) NSArray *objects;

- (void)highlightCellForPost:(Post *)post;
- (void)unhighlightCellForPost:(Post *)post;

@end

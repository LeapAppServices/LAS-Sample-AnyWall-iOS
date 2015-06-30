//
//  WallPostCreateViewController.h
//  Anywall
//
//  Created by  on 7/31/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallPostCreateViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *characterCount;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *postButton;

- (IBAction)cancelPost:(id)sender;
- (IBAction)postPost:(id)sender;

@end

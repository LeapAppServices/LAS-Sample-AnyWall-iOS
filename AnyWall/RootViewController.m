//
//  RootViewController.m
//  AnyWall
//
//  Created by Sun Jin on 15/7/30.
//  Copyright (c) 2015年 leap app service. All rights reserved.
//

#import "RootViewController.h"
#import "WelcomeViewController.h"
#import <LAS/LAS.h>
#import "WallViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	if (![LASUser currentUser]) {
		[self presentWelcomeViewController];
	}
}

- (void)presentWelcomeViewController {
	
	// Go to the welcome screen and have them log in or create an account.
	WelcomeViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
	welcomeViewController.title = @"Welcome to Anywall";
	
	[self setViewControllers:@[welcomeViewController]];
}

- (void)presentViewController {
	WallViewController *wallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WallViewController"];
	[self setViewControllers:@[wallViewController]];
}

@end

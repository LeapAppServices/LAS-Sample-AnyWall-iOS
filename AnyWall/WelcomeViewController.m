//
//  ViewController.m
//  Anywall
//
//  Created by  on 7/30/14.
//  Copyright (c) 2013 ilegendsoft. All rights reserved.
//

#import "WelcomeViewController.h"

#import "WallViewController.h"
#import "LoginViewController.h"
#import "NewUserViewController.h"

@implementation WelcomeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Transition methods

- (IBAction)gotoLAS:(id)sender {
	UIApplication *ourApplication = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"https://console.appcube.io"];
    [ourApplication openURL:url];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

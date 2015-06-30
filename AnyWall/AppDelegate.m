//
//  AppDelegate.m
//  Anywall
//
//  Created by  on 7/30/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

static NSString * const defaultsFilterDistanceKey = @"filterDistance";
static NSString * const defaultsLocationKey = @"currentLocation";

#import "AppDelegate.h"

#import <LAS/LAS.h>

#import "WelcomeViewController.h"
#import "WallViewController.h"

@implementation AppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    // Override point for customization after application launch.
	
	// ****************************************************************************
    // LAS initialization
#warning Please fill in with your LAS credentials
	//	[LAS setApplicationId:@"APPLICATION_ID_HERE" clientKey:@"CLIENT_KEY_HERE"];
	// ****************************************************************************
	
	// Grab values from NSUserDefaults:
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	// Desired search radius:
	if ([userDefaults doubleForKey:defaultsFilterDistanceKey]) {
		// use the ivar instead of self.accuracy to avoid an unnecessary write to NAND on launch.
		self.filterDistance = [userDefaults doubleForKey:defaultsFilterDistanceKey];
	} else {
		// if we have no accuracy in defaults, set it to 1000 feet.
		self.filterDistance = 1000 * kFeetToMeters;
	}
	
    return YES;
}


#pragma mark - AppDelegate

- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance {
	_filterDistance = aFilterDistance;

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:_filterDistance forKey:defaultsFilterDistanceKey];
	[userDefaults synchronize];

	// Notify the app of the filterDistance change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:_filterDistance] forKey:kFilterDistanceKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kFilterDistanceChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)setCurrentLocation:(CLLocation *)aCurrentLocation {
	_currentLocation = aCurrentLocation;

	// Notify the app of the location change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_currentLocation forKey:kLocationKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)presentWelcomeViewController {
	// Go to the welcome screen and have them log in or create an account.
	WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
	welcomeViewController.title = @"Welcome to Anywall";
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
	navController.navigationBarHidden = YES;

	self.viewController = navController;
	self.window.rootViewController = self.viewController;
}

@end

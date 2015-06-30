//
//  AppDelegate.h
//  Anywall
//
//  Created by  on 7/30/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

static NSUInteger const kWallPostMaximumCharacterCount = 140;

static double const kFeetToMeters = 0.3048; // this is an exact value.
static double const kFeetToMiles = 5280.0; // this is an exact value.
static double const kWallPostMaximumSearchDistance = 100.0;
static double const kMetersInAKilometer = 1000.0; // this is an exact value.

static NSUInteger const kWallPostsSearch = 20; // query limit for pins and tableviewcells

// LAS API key constants:
static NSString * const kLASPostsClassKey = @"Posts";
static NSString * const kLASUserKey = @"user";
static NSString * const kLASUsernameKey = @"username";
static NSString * const kLASTextKey = @"text";
static NSString * const kLASLocationKey = @"location";

// NSNotification userInfo keys:
static NSString * const kFilterDistanceKey = @"filterDistance";
static NSString * const kLocationKey = @"location";

// Notification names:
static NSString * const kFilterDistanceChangeNotification = @"kFilterDistanceChangeNotification";
static NSString * const kLocationChangeNotification = @"kLocationChangeNotification";
static NSString * const kPostCreatedNotification = @"kPostCreatedNotification";

// UI strings:
static NSString * const kWallCantViewPost = @"Can’t view post! Get closer.";

#define LocationAccuracy double

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class WelcomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@property (nonatomic, strong) CLLocation *currentLocation;

- (void)presentWelcomeViewController;

@end

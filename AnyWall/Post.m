//
//  Post.m
//  Anywall
//
//  Created by  on 8/8/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import "Post.h"
#import "AppDelegate.h"

@interface Post ()

// Redefine these properties to make them read/write for internal class accesses and mutations.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) LASObject *object;
@property (nonatomic, strong) LASGeoPoint *geopoint;
@property (nonatomic, strong) LASUser *user;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation Post

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.title = aTitle;
		self.subtitle = aSubtitle;
		self.animatesDrop = NO;
	}
	return self;
}

- (id)initWithLASObject:(LASObject *)anObject {
	self.object = anObject;
	self.geopoint = [anObject objectForKey:kLASLocationKey];
	self.user = [anObject objectForKey:kLASUserKey];

//	[anObject fetchIfNeeded];
	
	CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
	NSString *aTitle = [anObject objectForKey:kLASTextKey];
	NSString *aSubtitle = [[anObject objectForKey:kLASUserKey] objectForKey:kLASUsernameKey];

	return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle];
}

- (BOOL)equalToPost:(Post *)aPost {
	if (aPost == nil) {
		return NO;
	}

	if (aPost.object && self.object) {
		// We have a LASObject inside the Post, use that instead.
		if ([aPost.object.objectId compare:self.object.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		// Fallback code:

		if ([aPost.title compare:self.title] != NSOrderedSame ||
			[aPost.subtitle compare:self.subtitle] != NSOrderedSame ||
			aPost.coordinate.latitude != self.coordinate.latitude ||
			aPost.coordinate.longitude != self.coordinate.longitude ) {
			return NO;
		}

		return YES;
	}
}

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
	if (outside) {
		self.subtitle = nil;
		self.title = kWallCantViewPost;
		self.pinColor = MKPinAnnotationColorRed;
	} else {
		self.title = [self.object objectForKey:kLASTextKey];
		self.subtitle = [[self.object objectForKey:kLASUserKey] objectForKey:kLASUsernameKey];
		self.pinColor = MKPinAnnotationColorGreen;
	}
}

@end

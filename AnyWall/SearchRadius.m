//
//  SearchRadius.m
//  Anywall
//
//  Created by  on 8/8/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import "SearchRadius.h"

@implementation SearchRadius

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.radius = aRadius;
	}
	return self;
}

- (MKMapRect)boundingMapRect {
	return MKMapRectWorld;
}

@end

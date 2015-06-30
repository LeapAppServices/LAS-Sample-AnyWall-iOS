//
//  SearchRadius.h
//  Anywall
//
//  Created by  on 8/8/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SearchRadius : NSObject <MKOverlay>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, assign) MKMapRect boundingMapRect;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius;

@end

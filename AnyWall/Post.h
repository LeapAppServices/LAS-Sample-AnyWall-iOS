//
//  Post.h
//  Anywall
//
//  Created by  on 8/8/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <LAS/LAS.h>

@interface Post : NSObject <MKAnnotation>

//@protocol MKAnnotation <NSObject>

// Center latitude and longitude of the annotion view.
// The implementation of this property must be KVO compliant.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// @optional
// Title and subtitle for use by selection UI.
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
// @end

// Other properties:
@property (nonatomic, readonly, strong) LASObject *object;
@property (nonatomic, readonly, strong) LASGeoPoint *geopoint;
@property (nonatomic, readonly, strong) LASUser *user;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, readonly) MKPinAnnotationColor pinColor;

// Designated initializer.
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubtitle:(NSString *)subtitle;
- (id)initWithLASObject:(LASObject *)object;
- (BOOL)equalToPost:(Post *)aPost;

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside;

@end

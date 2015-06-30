//
//  WallViewController.h
//  Anywall
//
//  Created by  on 7/30/14.
//  Copyright (c) 2013 leap app service. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <LAS/LAS.h>
#import "Post.h"

@interface WallViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end

@protocol WallViewControllerHighlight <NSObject>

- (void)highlightCellForPost:(Post *)post;
- (void)unhighlightCellForPost:(Post *)post;

@end

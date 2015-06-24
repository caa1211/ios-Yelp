//
//  MapViewController.h
//  Yelp
//
//  Created by Carter Chang on 6/25/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Business.h"

@interface MapViewController : UIViewController

-(id) initWithBusiness:(Business *)business;

@end

//
//  MyMKAnnotation.m
//  Yelp
//
//  Created by Carter Chang on 6/25/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MyMKAnnotation.h"


@implementation MyMKAnnotation 
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description{

    if (self = [super init])
    {
        coordinate = location;
        title = placeName;
        subtitle = description;
    }
    return self;

    
}

//- (MKAnnotationView *) annotationView {
//    MKAnnotationView *v = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MyCustomAnnotation"];
//    v.enabled = YES;
//    v.canShowCallout = YES;
//    v.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    return v;
//}


@end

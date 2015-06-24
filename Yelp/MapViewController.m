//
//  MapViewController.m
//  Yelp
//
//  Created by Carter Chang on 6/25/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapViewController.h"
#import "MyMKAnnotation.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (assign, nonatomic) CLLocationCoordinate2D zoomLocation;
@property (strong, nonatomic) Business *business;
@end

@implementation MapViewController


-(id) initWithBusiness:(Business *)business {
    
    if ((self = [super initWithNibName:@"MapViewController" bundle:nil]))
    {
        _business = business;
        self.title = _business.name;
        _zoomLocation.latitude = _business.latitude;
        _zoomLocation.longitude= _business.longitude;

    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];


    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.2;     // 0.0 is min value u van provide for zooming
    span.longitudeDelta= 0.2;
    
    CLLocationCoordinate2D location = _zoomLocation;
    region.span=span;
    region.center =location;     // to locate to the center

    // Add pin
    MyMKAnnotation *pin = [[MyMKAnnotation alloc] initWithCoordinates:location
                                                            placeName:_business.address
                                                            description:[NSString stringWithFormat:@"%.2f miles",_business.distance]];

    [_mapView addAnnotation:pin];
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

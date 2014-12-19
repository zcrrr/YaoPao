//
//  CNRunMapGoogleViewController.m
//  YaoPao
//
//  Created by zc on 14-12-16.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMapGoogleViewController.h"
#import "CNGPSPoint.h"

@interface CNRunMapGoogleViewController ()

@end

@implementation CNRunMapGoogleViewController
@synthesize mapView;
@synthesize lastDrawPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lastDrawPoint = [kApp.oneRunPointList lastObject];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.lastDrawPoint.lat
                                                            longitude:self.lastDrawPoint.lon
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.view = self.mapView;
    
    [self drawRunTrack];
}
- (void)drawRunTrack{
    int pointCount = [kApp.oneRunPointList count];
    GMSMutablePath *path = [GMSMutablePath path];
    for(int i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.oneRunPointList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        [path addCoordinate:wgs84Point];
    }
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    
    polyline.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    polyline.strokeWidth = 11.5;
    polyline.map = self.mapView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.mapView.myLocationEnabled = NO;
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

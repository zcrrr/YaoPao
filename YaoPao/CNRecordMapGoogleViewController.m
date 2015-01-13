//
//  CNRecordMapGoogleViewController.m
//  YaoPao
//
//  Created by zc on 15-1-3.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNRecordMapGoogleViewController.h"
#import "CNGPSPoint.h"

@interface CNRecordMapGoogleViewController ()

@end

@implementation CNRecordMapGoogleViewController
@synthesize mapView;
@synthesize oneRun;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:7.53
                                                            longitude:98.24
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.view = self.mapView;
    [self drawRunTrack];
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
- (void)drawRunTrack{
    int pointCount = [kApp.oneRunPointList count];
    int i = 0;
    GMSMutablePath* path = [GMSMutablePath path];
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.oneRunPointList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        [path addCoordinate:wgs84Point];
    }
    GMSPolyline* polyline = [GMSPolyline polylineWithPath:path];
    
    polyline.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    polyline.strokeWidth = 11.5;
    polyline.map = self.mapView;
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

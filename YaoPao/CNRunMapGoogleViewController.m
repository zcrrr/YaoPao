//
//  CNRunMapGoogleViewController.m
//  YaoPao
//
//  Created by zc on 14-12-16.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMapGoogleViewController.h"
#import "CNGPSPoint.h"
#define kIntervalMap 2

@interface CNRunMapGoogleViewController ()

@end

@implementation CNRunMapGoogleViewController
@synthesize mapView;
@synthesize lastDrawPoint;
@synthesize path;
@synthesize polyline;
@synthesize timer_map;

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
    self.timer_map = [NSTimer scheduledTimerWithTimeInterval:kIntervalMap target:self selector:@selector(drawIncrementLine) userInfo:nil repeats:YES];
//    [self testDraw];
}
- (void)drawRunTrack{
    int pointCount = [kApp.oneRunPointList count];
    self.path = [GMSMutablePath path];
    for(int i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.oneRunPointList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        [self.path addCoordinate:wgs84Point];
    }
    self.polyline = [GMSPolyline polylineWithPath:self.path];
    
    self.polyline.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    self.polyline.strokeWidth = 11.5;
    self.polyline.map = self.mapView;
}
- (void)testDraw{
    self.path = [GMSMutablePath path];
    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041, 116.395322)];
    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.005, 116.395322)];
    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.01, 116.395322)];
    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.015, 116.395322)];
    self.polyline = [GMSPolyline polylineWithPath:self.path];
    self.polyline.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    self.polyline.strokeWidth = 11.5;
    self.polyline.map = self.mapView;
    
    [path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.015, 116.395322+0.05)];
    polyline.path = path;
}
- (void)drawIncrementLine{
    //取数组最新值
    CNGPSPoint* newPoint = [kApp.oneRunPointList lastObject];
    if(newPoint.lon != lastDrawPoint.lon || newPoint.lat != lastDrawPoint.lat){//5秒后点的位置有移动
        [self.path addCoordinate:CLLocationCoordinate2DMake(newPoint.lat, newPoint.lon)];
        self.polyline.path = self.path;
    }
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
    [self.timer_map invalidate];
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

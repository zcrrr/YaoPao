//
//  CNRecordMapViewController.m
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRecordMapViewController.h"
#import "CNUtil.h"
#import "SBJson.h"
#import "CNGPSPoint.h"
#import "CNEncryption.h"
#import "CustomAnnotationView.h"
#import "CNMapImageAnnotationView.h"
#import "CNGPSPoint4Match.h"
#define kPopInterval 1000

@interface CNRecordMapViewController ()

@end

@implementation CNRecordMapViewController
@synthesize oneRun;
@synthesize mapView;
@synthesize polyline_back;
@synthesize polyline_forward;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 468)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    [self.view_map_container addSubview:self.mapView];
    [self.view_map_container sendSubviewToBack:self.mapView];
    [self.view sendSubviewToBack:self.view_map_container];
    [self initUI];
//    kApp.timer_secondplusplus = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(redrawPolyline) userInfo:nil repeats:YES];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)initUI{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.oneRun.stamp longLongValue]];
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = [componets weekday];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy年M月d日 周%@ HH:mm",[CNUtil weekday2chinese:weekday]]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    self.label_date.text = strDate;
    self.label_date1.text = strDate;
    self.label_date2.text = strDate;
    self.label_date3.text = strDate;
    self.label_date4.text = strDate;
    [dateFormatter setDateFormat:@"M月d日"];
    NSString* strDate2 = [dateFormatter stringFromDate:date];
    int type = [oneRun.runty intValue];
    NSString* typeDes = @"";
    switch (type) {
        case 0:
        {
            typeDes = @"步行";
            self.image_type.image = [UIImage imageNamed:@"runtype_walk.png"];
            break;
        }
        case 1:
        {
            typeDes = @"跑步";
            self.image_type.image = [UIImage imageNamed:@"runtype_run.png"];
            break;
        }
        case 2:
        {
            typeDes = @"自行车骑行";
            self.image_type.image = [UIImage imageNamed:@"runtype_ride.png"];
            break;
        }
        default:
            break;
    }
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,typeDes];
    self.label_dis.text = [NSString stringWithFormat:@"%0.2fkm",[oneRun.distance floatValue]/1000];
    self.label_during.text = [CNUtil duringTimeStringFromSecond:[oneRun.utime intValue]];
    self.label_pspeed.text = [CNUtil pspeedStringFromSecond:[oneRun.pspeed intValue]];
    self.label_aver_speed.text = [NSString stringWithFormat:@"+%i",[oneRun.score intValue]];
    //区分是否是比赛
    int ismatch = [self.oneRun.ismatch intValue];
    if(ismatch == 0){
        [self drawRunTrack];
    }else if(ismatch == 1){
        [self drawMatchTrack];
    }
    
//    [self testDrawOneByOne];
}
- (void)drawRunTrack{
    //测试代码
//    [CNAppDelegate makeTest];
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.oneRunPointList count];
    NSLog(@"pointCount is %i",pointCount);
    
    //画起点和终点
    CNGPSPoint* startPoint = [kApp.oneRunPointList firstObject];
    CNGPSPoint* endPoint = [kApp.oneRunPointList lastObject];
    CLLocationCoordinate2D wgs84Point_start = CLLocationCoordinate2DMake(startPoint.lat, startPoint.lon);
    CLLocationCoordinate2D encryptionPoint_start = [CNEncryption encrypt:wgs84Point_start];
    CLLocationCoordinate2D wgs84Point_end = CLLocationCoordinate2DMake(endPoint.lat, endPoint.lon);
    CLLocationCoordinate2D encryptionPoint_end = [CNEncryption encrypt:wgs84Point_end];
    MAPointAnnotation *annotation_start = [[MAPointAnnotation alloc] init];
    annotation_start.coordinate = CLLocationCoordinate2DMake(encryptionPoint_start.latitude, encryptionPoint_start.longitude);
    annotation_start.title = @"start";
    [self.mapView addAnnotation:annotation_start];
    
    MAPointAnnotation *annotation_end = [[MAPointAnnotation alloc] init];
    annotation_end.coordinate = CLLocationCoordinate2DMake(encryptionPoint_end.latitude, encryptionPoint_end.longitude);
    annotation_end.title = @"end";
    [self.mapView addAnnotation:annotation_end];
    
    
    double distance_add = 0;
    long long time_one_km = 0;
    int targetDis = kPopInterval;
    
    //先画底色：
    CLLocationCoordinate2D polylineCoords_backgound[pointCount];
    CLLocationCoordinate2D polylineCoords_encryption[pointCount];
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.oneRunPointList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        polylineCoords_backgound[i].latitude = encryptionPoint.latitude;
        polylineCoords_backgound[i].longitude = encryptionPoint.longitude;
        polylineCoords_encryption[i] = encryptionPoint;
        
        //画气泡
        if(i >= 1){
            if(gpsPoint.status == 1){//正常运动
                CNGPSPoint* gpsPoint_before = [kApp.oneRunPointList objectAtIndex:i-1];
                CLLocationCoordinate2D wgs84Point_before = CLLocationCoordinate2DMake(gpsPoint_before.lat, gpsPoint_before.lon);
                CLLocationCoordinate2D encryptionPoint_before = [CNEncryption encrypt:wgs84Point_before];
                CLLocation *current=[[CLLocation alloc] initWithLatitude:encryptionPoint.latitude longitude:encryptionPoint.longitude];
                CLLocation *before=[[CLLocation alloc] initWithLatitude:encryptionPoint_before.latitude longitude:encryptionPoint_before.longitude];
                CLLocationDistance meters=[current distanceFromLocation:before];
                distance_add += meters;
                long long during_time = gpsPoint.time - gpsPoint_before.time;
                time_one_km += during_time;
                if(distance_add > targetDis){
                    NSLog(@"大于1000的倍数");
                    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
                    annotation.coordinate = CLLocationCoordinate2DMake(encryptionPoint.latitude, encryptionPoint.longitude);
                    annotation.title = [NSString stringWithFormat:@"%i_%llu",(int)(distance_add/kPopInterval),time_one_km];
                    [self.mapView addAnnotation:annotation];
                    targetDis += kPopInterval;
                    time_one_km = 0;
                }
            }
        }
    }
    
    MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
    polyline.title = @"3";
    [self.mapView addOverlay:polyline];
    //再画灰色：
    MAPolyline* polyline_pause = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
    polyline_pause.title = @"1";
    [self.mapView addOverlay:polyline_pause];
    double min_lon = polylineCoords_encryption[0].longitude;
    double min_lat = polylineCoords_encryption[0].latitude;
    double max_lon = polylineCoords_encryption[0].longitude;
    double max_lat = polylineCoords_encryption[0].latitude;
    
    [kApp.runStatusChangeIndex addObject:[NSNumber numberWithInt:pointCount-1]];
    NSLog(@"changeIndex is %@",kApp.runStatusChangeIndex);
    int linesCount = [kApp.runStatusChangeIndex count];
    for(j = 0;j<linesCount-1;j++){
        int startIndex = [[kApp.runStatusChangeIndex objectAtIndex:j]intValue];
        int endIndex = [[kApp.runStatusChangeIndex objectAtIndex:j+1]intValue];
        NSLog(@"startIndex:%i,endIndex:%i",startIndex,endIndex);
        CLLocationCoordinate2D polylineCoords[endIndex-startIndex+1];
        if(endIndex-startIndex+1<2)continue;
        for(i = startIndex,n = 0;i <= endIndex;i++,n++){
            polylineCoords[n] = polylineCoords_encryption[i];
            if(polylineCoords_encryption[i].longitude < min_lon){
                min_lon = polylineCoords_encryption[i].longitude;
            }
            if(polylineCoords_encryption[i].latitude < min_lat){
                min_lat = polylineCoords_encryption[i].latitude;
            }
            if(polylineCoords_encryption[i].longitude > max_lon){
                max_lon = polylineCoords_encryption[i].longitude;
            }
            if(polylineCoords_encryption[i].latitude > max_lat){
                max_lat = polylineCoords_encryption[i].latitude;
            }
        }
        MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:endIndex-startIndex+1];
        CNGPSPoint* gpsPoint_end = [kApp.oneRunPointList objectAtIndex:endIndex];
        if(gpsPoint_end.status == 1){
            polyline.title = @"1";
            [self.mapView addOverlay:polyline];
        }
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.005, max_lon-min_lon+0.005);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
}
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolyline* polyline = (MAPolyline*)overlay;
        MAPolylineView *polylineView = [[MAPolylineView alloc]initWithOverlay:overlay];
        if([polyline.title isEqualToString:@"1"]){//前景运动状态
            polylineView.lineWidth   = 11.5;  //线宽，必须设置
            polylineView.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
        }else if([polyline.title isEqualToString:@"2"]){//前景暂停状态
            polylineView.lineWidth   = 11.5;  //线宽，必须设置
            polylineView.strokeColor = [UIColor lightGrayColor];
        }else if([polyline.title isEqualToString:@"3"]){//背景
            polylineView.lineWidth   = 15.5;  //线宽，必须设置
            polylineView.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }
        polylineView.lineJoin = kCGLineJoinRound;
        polylineView.lineCap = kCGLineCapRound;
        return polylineView;
    }
    return nil;
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        static NSString *mapImageIndetifier = @"mapImageIndetifier";
        
        NSString* title = ((MAPointAnnotation*)annotation).title;
        if([title hasPrefix:@"start"]||[title hasPrefix:@"end"]){
            CNMapImageAnnotationView *annotationView = (CNMapImageAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:mapImageIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[CNMapImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:mapImageIndetifier];
                // must set to NO, so we can show the custom callout view.
                annotationView.draggable = YES;
                annotationView.centerOffset = CGPointMake(0,-15);
            }
            NSLog(@"title is %@",title);
            annotationView.type = title;
            return annotationView;
        }else{
            CustomAnnotationView *annotationView = (CustomAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
                // must set to NO, so we can show the custom callout view.
                annotationView.draggable = YES;
                annotationView.centerOffset = CGPointMake(0, -15);
            }
            NSLog(@"title is %@",title);
            annotationView.paraminfo = title;
            return annotationView;
        }
        
    }
    return nil;
}
- (void)testDrawOneByOne{
//    [CNAppDelegate makeTest];
    int pointCount = [kApp.oneRunPointList count];
    for(int i=0;i<pointCount-1;i++){
        CNGPSPoint* point1 = [kApp.oneRunPointList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point1 = CLLocationCoordinate2DMake(point1.lat, point1.lon);
        CLLocationCoordinate2D encryptionPoint1 = [CNEncryption encrypt:wgs84Point1];
        CNGPSPoint* point2 = [kApp.oneRunPointList objectAtIndex:i+1];
        CLLocationCoordinate2D wgs84Point2 = CLLocationCoordinate2DMake(point2.lat, point2.lon);
        CLLocationCoordinate2D encryptionPoint2 = [CNEncryption encrypt:wgs84Point2];
        CLLocationCoordinate2D polylineCoords[2];
        polylineCoords[0] = encryptionPoint1;
        polylineCoords[1] = encryptionPoint2;
        MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:2];
        polyline.title = @"3";
        [self.mapView addOverlay:polyline];
//        if(i>0){
//            CNGPSPoint* point0 = [kApp.oneRunPointList objectAtIndex:i-1];
//            CLLocationCoordinate2D wgs84Point0 = CLLocationCoordinate2DMake(point0.lat, point0.lon);
//            CLLocationCoordinate2D encryptionPoint0 = [CNEncryption encrypt:wgs84Point0];
//            CLLocationCoordinate2D polylineCoords[3];
//            polylineCoords[0] = encryptionPoint0;
//            polylineCoords[1] = encryptionPoint1;
//            polylineCoords[2] = encryptionPoint2;
//            MAPolyline* polyline2 = [MAPolyline polylineWithCoordinates:polylineCoords count:3];
//            polyline2.title = @"1";
//            [self.mapView addOverlay:polyline2];
//        }
        
        MAPolyline* polyline2 = [MAPolyline polylineWithCoordinates:polylineCoords count:2];
        polyline2.title = @"1";
        [self.mapView addOverlay:polyline2];
    }
}
- (void)redrawPolyline{
    [self.mapView removeOverlay:polyline_forward];
    [self.mapView removeOverlay:polyline_back];
    [self drawRunTrack];
}
//比赛：
- (void)drawMatchTrack{
    CNGPSPoint4Match* startPoint = [kApp.match_pointList firstObject];
    CNGPSPoint4Match* endPoint = [kApp.match_pointList lastObject];
    MAPointAnnotation *annotation_start = [[MAPointAnnotation alloc] init];
    annotation_start.coordinate = CLLocationCoordinate2DMake(startPoint.lat, startPoint.lon);
    annotation_start.title = @"start";
    [self.mapView addAnnotation:annotation_start];
    
    MAPointAnnotation *annotation_end = [[MAPointAnnotation alloc] init];
    annotation_end.coordinate = CLLocationCoordinate2DMake(endPoint.lat, endPoint.lon);
    annotation_end.title = @"end";
    [self.mapView addAnnotation:annotation_end];
    
    
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.match_pointList count];
    
    for(i=0;i<pointCount;i++){
        CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:i];

        if (gpsPoint.lon < 0.01 || i == pointCount-1) {
            CLLocationCoordinate2D polylineCoord[i-n];
            for(j=0;j<i-n;j++){
                CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:n+j];
                polylineCoord[j].latitude = gpsPoint.lat;
                polylineCoord[j].longitude = gpsPoint.lon;
            }
            MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoord count:i-n];
            polyline.title = @"3";
            [self.mapView addOverlay:polyline];
            n = i+1;//n为下一个起点
        }
    }
    
    
    
    n = 0;
    CNGPSPoint4Match* gpsPoint_first = [kApp.match_pointList objectAtIndex:0];
    double min_lon = gpsPoint_first.lon;
    double min_lat = gpsPoint_first.lat;
    double max_lon = gpsPoint_first.lon;
    double max_lat = gpsPoint_first.lat;
    for(i=0;i<pointCount;i++){
        CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:i];
        if (gpsPoint.lon < 0.01 || i == pointCount-1) {
            CLLocationCoordinate2D polylineCoord[i-n];
            for(j=0;j<i-n;j++){
                CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:n+j];
                polylineCoord[j].latitude = gpsPoint.lat;
                polylineCoord[j].longitude = gpsPoint.lon;
                
                if(gpsPoint.lon < min_lon){
                    min_lon = gpsPoint.lon;
                }
                if(gpsPoint.lat < min_lat){
                    min_lat = gpsPoint.lat;
                }
                if(gpsPoint.lon > max_lon){
                    max_lon = gpsPoint.lon;
                }
                if(gpsPoint.lat > max_lat){
                    max_lat = gpsPoint.lat;
                }
            }
            MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoord count:i-n];
            polyline.title = @"1";
            [self.mapView addOverlay:polyline];
            n = i+1;//n为下一个起点
        }
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.005, max_lon-min_lon+0.005);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
}
@end

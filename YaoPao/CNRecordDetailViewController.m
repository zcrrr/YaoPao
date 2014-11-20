//
//  CNRecordDetailViewController.m
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRecordDetailViewController.h"
#import "CNUtil.h"
#import "SBJson.h"
#import "CNGPSPoint.h"
#import "CNShareViewController.h"
#import "CNRecordMapViewController.h"
#import "CNEncryption.h"
#import "CNDistanceImageView.h"
#import "CNMapImageAnnotationView.h"
#import "CNGPSPoint4Match.h"

@interface CNRecordDetailViewController ()

@end

@implementation CNRecordDetailViewController
@synthesize oneRun;
@synthesize mapView;

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
    [self.button_share addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    [self.view_map_container addSubview:self.mapView];
    [self.view_map_container sendSubviewToBack:self.mapView];
    [self initUI];
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

- (IBAction)button_share_clicked:(id)sender {
    self.button_share.backgroundColor = [UIColor clearColor];
    CNShareViewController* shareVC = [[CNShareViewController alloc]init];
    shareVC.dataSource = @"list";
    shareVC.oneRun = self.oneRun;
    [self.navigationController pushViewController:shareVC animated:YES];
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
    int type = [self.oneRun.runty intValue];
    NSString* typeDes = @"";
    switch (type) {
        case 0:
        {
            typeDes = @"步行";
            self.imageview_type.image = [UIImage imageNamed:@"runtype_walk.png"];
            break;
        }
        case 1:
        {
            typeDes = @"跑步";
            self.imageview_type.image = [UIImage imageNamed:@"runtype_run.png"];
            break;
        }
        case 2:
        {
            typeDes = @"自行车骑行";
            self.imageview_type.image = [UIImage imageNamed:@"runtype_ride.png"];
            break;
        }
        default:
            break;
    }
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,typeDes];
//    self.label_dis.text = [NSString stringWithFormat:@"%0.2fkm",[self.oneRun.distance floatValue]/1000];
    CNDistanceImageView* div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(5, 255+IOS7OFFSIZE, 130, 32)];
    div.distance = [self.oneRun.distance floatValue]/1000;
    div.color = @"red";
    [div fitToSizeLeft];
    [self.view addSubview:div];
    UIImageView* image_km = [[UIImageView alloc]initWithFrame:CGRectMake(div.frame.origin.x+div.frame.size.width, 255+IOS7OFFSIZE,26, 32)];
    image_km.image = [UIImage imageNamed:@"redkm.png"];
    [self.view addSubview:image_km];
    
    self.label_during.text = [CNUtil duringTimeStringFromSecond:[self.oneRun.utime intValue]];
    self.label_pspeed.text = [CNUtil pspeedStringFromSecond:[self.oneRun.pspeed intValue]];
    self.label_aver_speed.text = [NSString stringWithFormat:@"+%i",[self.oneRun.score intValue]];
    self.label_feel.text = self.oneRun.remarks;
    int mood = [self.oneRun.mind intValue];
    NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_h.png",mood];
    self.image_mood.image = [UIImage imageNamed:img_name_mood];
    
    int way = [self.oneRun.runway intValue];
    NSString* img_name_way = [NSString stringWithFormat:@"way%i_h.png",way];
    self.image_way.image = [UIImage imageNamed:img_name_way];
    //判断是否有图片
    int imagecount = [self.oneRun.image_count intValue];
    if(imagecount!=0){
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_big.jpg",self.oneRun.rid]];
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (blHave) {//图片存在
            [self.scrollview setContentSize:CGSizeMake(640, 150)];
            self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
            self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
            self.scrollview.pagingEnabled=YES;
            UIImageView* photo = [[UIImageView alloc]initWithFrame:CGRectMake(320, 0, 320, 250)];
            [self.scrollview addSubview:photo];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            photo.image = [[UIImage alloc] initWithData:data];
        }
    }
    
    //区分是否是比赛
    int ismatch = [self.oneRun.ismatch intValue];
    if(ismatch == 0){
        //加载轨迹
        kApp.oneRunPointList = [[NSMutableArray alloc]init];
        SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
        NSArray* pointDicList = [jsonParser objectWithString:self.oneRun.runtra];
        int i = 0;
        NSDictionary* firstPointDic = [pointDicList objectAtIndex:0];
        int before_lon = [[firstPointDic objectForKey:@"slon"]intValue];
        int before_lat = [[firstPointDic objectForKey:@"slat"]intValue];
        long long before_time = [[firstPointDic objectForKey:@"addtime"]longLongValue];
        NSLog(@"before_lon is %i",before_lon);
        CNGPSPoint* firstPoint = [[CNGPSPoint alloc]init];
        firstPoint.lon = (double)before_lon/1000000.0;
        firstPoint.lat = (double)before_lat/1000000.0;
        firstPoint.time = before_time/1000;
        NSLog(@"firstPoint.lon is %f",firstPoint.lon);
        firstPoint.status = [[firstPointDic objectForKey:@"state"]intValue];
        [kApp.oneRunPointList addObject:firstPoint];
        for(i = 1;i<[pointDicList count];i++){
            NSDictionary* pointDic = [pointDicList objectAtIndex:i];
            before_lon += [[pointDic objectForKey:@"slon"]intValue];
            before_lat += [[pointDic objectForKey:@"slat"]intValue];
            before_time += [[pointDic objectForKey:@"addtime"]longLongValue];
            CNGPSPoint* point = [[CNGPSPoint alloc]init];
            point.lon = (double)before_lon/1000000.0;
            point.lat = (double)before_lat/1000000.0;
            point.time = before_time/1000;
            point.status = [[pointDic objectForKey:@"state"]intValue];
            [kApp.oneRunPointList addObject:point];
        }
        kApp.runStatusChangeIndex = [jsonParser objectWithString:self.oneRun.statusIndex];
        NSLog(@"runStatusChangeIndex is %@",kApp.runStatusChangeIndex);
        [self drawRunTrack];
    }else if(ismatch == 1){
        kApp.match_pointList = [[NSMutableArray alloc]init];
        NSArray* pointDicList = [self.oneRun.runtra componentsSeparatedByString:@","];
        for(int i=0;i<[pointDicList count];i++){
            CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
            NSArray* lonlat = [[pointDicList objectAtIndex:i]componentsSeparatedByString:@" "];
            point.lon = [[lonlat objectAtIndex:0]doubleValue];
            point.lat = [[lonlat objectAtIndex:1]doubleValue];
            [kApp.match_pointList addObject:point];
        }
        [self drawMatchTrack];
    }
    
    
}
- (void)drawRunTrack{
    //测试代码
//    [CNAppDelegate makeTest];
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.oneRunPointList count];
    
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
    }
    MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
    polyline.title = @"3";
    [self.mapView addOverlay:polyline];
    
    //再画灰色：
    MAPolyline* polyline_pause = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
    polyline_pause.title = @"2";
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
        }
    }
    return nil;
}
- (IBAction)button_gotoMap_clicked:(id)sender {
    CNRecordMapViewController* recordMapVC = [[CNRecordMapViewController alloc]init];
    recordMapVC.oneRun = self.oneRun;
    [self.navigationController pushViewController:recordMapVC animated:YES];
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

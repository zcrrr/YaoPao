//
//  CNRunMapViewController.m
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMapViewController.h"
#import "CNGPSPoint.h"
#import "CNRunMoodViewController.h"
#import "CNEncryption.h"
#import "CNMainViewController.h"
#import "Toast+UIView.h"
#import "CNUtil.h"
#import "CNVoiceHandler.h"
#define kIntervalMap 2

@interface CNRunMapViewController ()

@end

@implementation CNRunMapViewController
@synthesize mapView;
@synthesize timer_map;
@synthesize lastDrawPoint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.button_reset addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_complete addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    int map_height;
    if(iPhone5){
        map_height = 568-IOS7OFFSIZE-50;
    }else{
        map_height = 568-IOS7OFFSIZE-50;
    }
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, IOS7OFFSIZE, 320, map_height)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    self.sliderview.delegate = self;
    [self.sliderview setBackgroundColor:[UIColor clearColor]];
    [self.sliderview setText:@"滑动暂停"];
    //将当前数组中的数据画到地图上
    self.lastDrawPoint = [kApp.oneRunPointList lastObject];
    [self drawRunTrack];
    [self setGPSImage];
    self.timer_map = [NSTimer scheduledTimerWithTimeInterval:kIntervalMap target:self selector:@selector(drawIncrementLine) userInfo:nil repeats:YES];
    
//    [self performSelector:@selector(setFollow) withObject:nil afterDelay:1];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_map invalidate];
    self.mapView.delegate = nil;
}
- (void)setFollow{
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}
- (void)drawIncrementLine{
    //取数组最新值
    CNGPSPoint* newPoint = [kApp.oneRunPointList lastObject];
    if(newPoint.lon != lastDrawPoint.lon || newPoint.lat != lastDrawPoint.lat){//5秒后点的位置有移动
        int count = 2;
        CLLocationCoordinate2D polylineCoords[count];
        CLLocationCoordinate2D wgs84Point1 = CLLocationCoordinate2DMake(lastDrawPoint.lat, lastDrawPoint.lon);
        CLLocationCoordinate2D encryptionPoint1 = [CNEncryption encrypt:wgs84Point1];
        CLLocationCoordinate2D wgs84Point2 = CLLocationCoordinate2DMake(newPoint.lat, newPoint.lon);
        CLLocationCoordinate2D encryptionPoint2 = [CNEncryption encrypt:wgs84Point2];
        polylineCoords[0].latitude = encryptionPoint1.latitude;
        polylineCoords[0].longitude = encryptionPoint1.longitude;
        polylineCoords[1].latitude = encryptionPoint2.latitude;
        polylineCoords[1].longitude = encryptionPoint2.longitude;
        MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:count];
        polyline.title = newPoint.status == 1?@"1":@"2";
        [self.mapView addOverlay:polyline];
        lastDrawPoint = newPoint;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    switch (kApp.runStatus) {
        case 1:
        {
            self.view_bottom_slider.hidden = NO;
            break;
        }
        case 2:
        {
            self.view_bottom_slider.hidden = YES;
            break;
        }
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
            //测试完成整个运动
//            [self finishRun];
            self.mapView.userTrackingMode = MAUserTrackingModeFollow;
            break;
        case 1:
        {
            self.mapView.showsUserLocation = NO;
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)button_control_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"完成");
            self.button_complete.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
//            UIAlertView* alert =[[UIAlertView alloc] initWithTitle:nil message:@"你已经完成这次的运动了吗" delegate:self cancelButtonTitle:@"是的，完成了" otherButtonTitles:@"不，还没完成", nil];
//            [alert show];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"你已经完成这次的运动了吗?" delegate:self cancelButtonTitle:@"不，还没完成" destructiveButtonTitle:nil otherButtonTitles:@"是的，完成了", nil];
            [actionSheet showInView:self.view];
            break;
        }
        case 1:
        {
            self.button_reset.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
            [kApp.voiceHandler voiceOfapp:@"run_continue" :nil];
            kApp.runStatus = 1;
            int hascount = [kApp.oneRunPointList count];
            [kApp.runStatusChangeIndex addObject:[NSNumber numberWithInt:hascount-1]];
            self.view_bottom_slider.hidden = NO;
            NSLog(@"恢复");
            kApp.timer_secondplusplus = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeaddadd) userInfo:nil repeats:YES];
            kApp.startTime = [CNUtil getNowTime];
            break;
        }
        default:
            break;
    }
}
- (void)timeaddadd{
    kApp.run_second++;
}
- (void)drawRunTrack{
    //测试代码
//    [CNAppDelegate makeTest];
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.oneRunPointList count];
    
    
    CLLocationCoordinate2D polylineCoords_backgound[pointCount];
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.oneRunPointList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        polylineCoords_backgound[i].latitude = encryptionPoint.latitude;
        polylineCoords_backgound[i].longitude = encryptionPoint.longitude;
    }
    //先画底色：
//    MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
//    polyline.title = @"3";
//    [self.mapView addOverlay:polyline];
    
    //先画灰色：
    MAPolyline* polyline_pause = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
    polyline_pause.title = @"2";
    [self.mapView addOverlay:polyline_pause];
    
    
    
    CNGPSPoint* firstPoint = [kApp.oneRunPointList objectAtIndex:0];
    CLLocationCoordinate2D wgs84Point_first = CLLocationCoordinate2DMake(firstPoint.lat, firstPoint.lon);
    CLLocationCoordinate2D encryptionPoint_first = [CNEncryption encrypt:wgs84Point_first];
    double min_lon = encryptionPoint_first.longitude;
    double min_lat = encryptionPoint_first.latitude;
    double max_lon = encryptionPoint_first.longitude;
    double max_lat = encryptionPoint_first.latitude;
    
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
            CNGPSPoint* gpsPoint = [kApp.oneRunPointList objectAtIndex:i];
            CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
            CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
            polylineCoords[n].latitude = encryptionPoint.latitude;
            polylineCoords[n].longitude = encryptionPoint.longitude;
            if(encryptionPoint.longitude < min_lon){
                min_lon = encryptionPoint.longitude;
            }
            if(encryptionPoint.latitude < min_lat){
                min_lat = encryptionPoint.latitude;
            }
            if(encryptionPoint.longitude > max_lon){
                max_lon = encryptionPoint.longitude;
            }
            if(encryptionPoint.latitude > max_lat){
                max_lat = encryptionPoint.latitude;
            }
        }
        MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:endIndex-startIndex+1];
        CNGPSPoint* gpsPoint_end = [kApp.oneRunPointList objectAtIndex:endIndex];
        //        polyline.title = gpsPoint_end.status == 1?@"1":@"2";
        NSLog(@"这一段状态是%@",polyline.title);
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
- (void)testDraw{
    CLLocationCoordinate2D polylineCoords[4];
    polylineCoords[0].latitude = 39.743951;
    polylineCoords[0].longitude = 116.309555;
    polylineCoords[1].latitude = 39.743948;
    polylineCoords[1].longitude = 116.309467;
    polylineCoords[2].latitude = 39.743938;
    polylineCoords[2].longitude = 116.309398;
    polylineCoords[3].latitude = 39.743962;
    polylineCoords[3].longitude = 116.309316;
    MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:4];
    [self.mapView addOverlay:polyline];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(39.743951, 116.309555)];
    [self.mapView setZoomLevel:17];
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

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"regionDidChangeAnimated");
//    self.mapView.userTrackingMode = MAUserTrackingModeNone;
}
-(void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation
updatingLocation:(BOOL)updatingLocation
{
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)finishRun{
    [kApp.timer_one_point invalidate];
    
    int count = [kApp.oneRunPointList count];
    NSMutableArray* arraytest = [[NSMutableArray alloc]init];
    int i = 0;
    for(i = 0;i<count;i++){
        CNGPSPoint* gpsPoint = [kApp.oneRunPointList objectAtIndex:i];
        NSString* lonlat = [NSString stringWithFormat:@"%f,%f,%i,%i,%i,%lli",gpsPoint.lon,gpsPoint.lat,gpsPoint.speed,gpsPoint.course,gpsPoint.altitude,gpsPoint.time];
        [arraytest addObject:lonlat];
    }
    NSString* filePath = [CNPersistenceHandler getDocument:@"runTrack.plist"];
    [arraytest writeToFile:filePath atomically:YES];
}
// MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)slideView {
    [kApp.voiceHandler voiceOfapp:@"run_pause" :nil];
    // Customization example
    kApp.pauseCount = [kApp.oneRunPointList count];
    NSLog(@"滑动");
    kApp.runStatus = 2;
    kApp.alreadySecond = kApp.totalSecond;
    int hascount = [kApp.oneRunPointList count];
    [kApp.runStatusChangeIndex addObject:[NSNumber numberWithInt:hascount-1]];
    self.view_bottom_slider.hidden = YES;
    [kApp.timer_secondplusplus invalidate];
}

- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"是的，完成了");
            int count = [kApp.oneRunPointList count];
            if(count > kApp.pauseCount){//去掉最后一小段从暂停到完成的距离
                for(int i=kApp.pauseCount;i<count;i++){
                    [kApp.oneRunPointList removeLastObject];
                }
            }
            kApp.runStatus = 0;
            [kApp.timer_one_point invalidate];
            if(kApp.distance < 50){
                kApp.isRunning = 0;
                kApp.gpsLevel = 1;
                //弹出框，距离小于50
                [kApp.window makeToast:@"您运动距离也太短啦！这次就不给您记录了，下次一定要加油！"];
                [CNAppDelegate initRun];
                CNMainViewController* mainVC = [[CNMainViewController alloc]init];
                [self.navigationController pushViewController:mainVC animated:YES];
            }else{
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [kApp.voiceHandler voiceOfapp:@"run_complete" :voice_params];
                CNRunMoodViewController* moodVC = [[CNRunMoodViewController alloc]init];
                [self.navigationController pushViewController:moodVC animated:YES];
            }
            break;
        }
        default:
            break;
    }
    
    
}
@end

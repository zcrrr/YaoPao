//
//  CNShareViewController.m
//  YaoPao
//
//  Created by zc on 14-8-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNShareViewController.h"
#import "CNMainViewController.h"
#import "CNGPSPoint.h"
#import "CNUtil.h"
#import "CNEncryption.h"
#import "CNRunRecordViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImage+Rescale.h"

@interface CNShareViewController ()

@end

@implementation CNShareViewController
@synthesize mapView;
@synthesize oneRun;

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
    [self.button_jump addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_share addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    [self.view_map_container addSubview:self.mapView];
//    [self.view_map_container sendSubviewToBack:self.mapView];
    
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.imageview_avatar.image = [[UIImage alloc] initWithData:imageData];
    }
    if([self.dataSource isEqualToString:@"this"]){
        NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
        NSMutableDictionary* runSettingDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        int type = [[runSettingDic objectForKey:@"type"]intValue];
        NSString* typeDes = @"";
        switch (type) {
            case 0:
            {
                typeDes = @"步行";
                break;
            }
            case 1:
            {
                typeDes = @"跑";
                break;
            }
            case 2:
            {
                typeDes = @"骑行";
                break;
            }
            default:
                break;
        }
        self.label_distance.text = [NSString stringWithFormat:@"我刚刚%@了%0.2f公里",typeDes,kApp.distance/1000.0];
        self.label_feel.text = kApp.feel;
        self.label_time.text = [CNUtil duringTimeStringFromSecond:kApp.totalSecond];
        self.label_pspeed.text = [CNUtil pspeedStringFromSecond:kApp.perMileSecond];
        self.label_hspeed.text = [NSString stringWithFormat:@"+%i",kApp.score];
        int mood = kApp.mood;
        NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_h.png",mood];
        self.image_mood.image = [UIImage imageNamed:img_name_mood];
        
        int way = kApp.way;
        NSString* img_name_way = [NSString stringWithFormat:@"way%i_h.png",way];
        self.image_way.image = [UIImage imageNamed:img_name_way];
        
    }else{
        int type = [self.oneRun.runty intValue];
        NSString* typeDes = @"";
        switch (type) {
            case 0:
            {
                typeDes = @"步行";
                break;
            }
            case 1:
            {
                typeDes = @"跑";
                break;
            }
            case 2:
            {
                typeDes = @"骑行";
                break;
            }
            default:
                break;
        }
        self.label_distance.text = [NSString stringWithFormat:@"我刚刚%@了%0.2f公里",typeDes, [oneRun.distance doubleValue]/1000.0];
        self.label_feel.text = oneRun.remarks;
        self.label_time.text = [CNUtil duringTimeStringFromSecond:[oneRun.utime intValue]];
        self.label_pspeed.text = [CNUtil pspeedStringFromSecond:[oneRun.pspeed intValue]];
        self.label_hspeed.text = [NSString stringWithFormat:@"+%i",[oneRun.score intValue]];
        int mood = [oneRun.mind intValue];
        NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_h.png",mood];
        self.image_mood.image = [UIImage imageNamed:img_name_mood];
        
        int way = [oneRun.runway intValue];
        NSString* img_name_way = [NSString stringWithFormat:@"way%i_h.png",way];
        self.image_way.image = [UIImage imageNamed:img_name_way];
    }
    //画轨迹
    [self drawRunTrack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (IBAction)button_jump_clicked:(id)sender {
    self.button_jump.backgroundColor = [UIColor clearColor];
    [CNAppDelegate initRun];
    CNRunRecordViewController* recordVC = [[CNRunRecordViewController alloc]init];
    [self.navigationController pushViewController:recordVC animated:YES];
}
- (IBAction)button_share_clicked:(id)sender {
    NSLog(@"share");
    self.button_share.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
    [self sharetest];
}
- (void)drawRunTrack{
    //测试代码
//    [CNAppDelegate makeTest];
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.oneRunPointList count];
    
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
    
    //先画灰色：
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
- (void)sharetest{
    id<ISSContent> publishContent = [ShareSDK content:@"test"
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK pngImageWithImage:[self getWeiboImage]]
                                                title:@"要跑"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeImage];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}
- (UIImage *)getWeiboImage{
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(self.view_shareview.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(self.view_shareview.frame.size);
    }
    [self.view_shareview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image_temp = UIGraphicsGetImageFromCurrentImageContext();
    NSData* imageData = UIImagePNGRepresentation(image_temp);
    UIImage* image_compressed = [UIImage imageWithData:imageData];
    return image_compressed;
}

@end

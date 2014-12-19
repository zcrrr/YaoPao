//
//  CNRunMainViewController.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMainViewController.h"
#import "CNLocationHandler.h"
#import "CNGPSPoint.h"
#import "CNUtil.h"
#import "CNRunMapViewController.h"
#import "CNRunMoodViewController.h"
#import "CNDistanceImageView.h"
#import "CNTimeImageView.h"
#import "CNSpeedImageView.h"
#import "CNMainViewController.h"
#import "Toast+UIView.h"
#import "CNVoiceHandler.h"
#import "CNRunMapGoogleViewController.h"
#define kInterval 3

@interface CNRunMainViewController ()

@end

@implementation CNRunMainViewController
@synthesize runSettingDic;
@synthesize distance_add;
@synthesize second_add;
@synthesize div;
@synthesize tiv;
@synthesize siv;
@synthesize big_div;
@synthesize big_tiv;
@synthesize timer_dispalyTime;
@synthesize pass_km;
@synthesize playkm;
@synthesize reachTarget;
@synthesize playTarget;
@synthesize reachHalf;
@synthesize playHalf;
@synthesize closeToTarget;
@synthesize pass_5munite;
@synthesize play5munite;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    switch (kApp.runStatus) {
        case 1:
        {
            self.view_bottom_slider.hidden = NO;
            self.timer_dispalyTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
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
    
    
    [kApp.voiceHandler voiceOfapp:@"run_start" :nil];
    // Do any additional setup after loading the view from its nib.
    
    if(kApp.oneRunPointList == nil){
        kApp.oneRunPointList = [[NSMutableArray alloc]init];
    }
    if(kApp.runStatusChangeIndex == nil){
        kApp.runStatusChangeIndex = [[NSMutableArray alloc]init];
    }
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    [self startTimer];
    self.sliderview.delegate = self;
    [self.sliderview setBackgroundColor:[UIColor clearColor]];
    [self.sliderview setText:@"滑动暂停"];
    
    [self setGPSImage];
    
    self.big_div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(-2.5, 100+IOS7OFFSIZE, 325, 80)];
    self.big_div.distance = 0;
    self.big_div.color = @"white";
    [self.big_div fitToSize];
    [self.view addSubview:self.big_div];
    
    self.big_tiv = [[CNTimeImageView alloc]initWithFrame:CGRectMake(20, 108+IOS7OFFSIZE, 280, 64)];
    self.big_tiv.time = 0;
    self.big_tiv.color = @"white";
    [self.big_tiv fitToSize];
    [self.view addSubview:self.big_tiv];
    
    self.div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(15, 226+IOS7OFFSIZE, 130, 32)];
    self.div.distance = 0;
    self.div.color = @"white";
    [self.div fitToSize];
    [self.view addSubview:self.div];
    
    self.tiv = [[CNTimeImageView alloc]initWithFrame:CGRectMake(10, 226+IOS7OFFSIZE, 140, 32)];
    self.tiv.time = 0;
    self.tiv.color = @"white";
    [self.tiv fitToSize];
    [self.view addSubview:self.tiv];
    
    self.siv = [[CNSpeedImageView alloc]initWithFrame:CGRectMake(190, 226+IOS7OFFSIZE, 100, 32)];
    self.siv.time = 0;
    self.siv.color = @"white";
    [self.siv fitToSize];
    [self.view addSubview:self.siv];
    
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    self.runSettingDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(self.runSettingDic == nil){
        self.runSettingDic = [[NSMutableDictionary alloc]init];
        [self.runSettingDic setObject:@"1" forKey:@"target"];
        [self.runSettingDic setObject:@"5" forKey:@"distance"];
        [self.runSettingDic setObject:@"30" forKey:@"time"];
        [self.runSettingDic setObject:@"1" forKey:@"type"];
        [self.runSettingDic setObject:@"1" forKey:@"countdown"];
        [self.runSettingDic setObject:@"1" forKey:@"voice"];
    }
    int target = [[self.runSettingDic objectForKey:@"target"]intValue];
    if(target == 1 || target == 0){//目标是距离
        self.label_dis.text = @"距离（公里）";
        self.label_time.text = @"时间";
        self.big_div.hidden = NO;
        self.big_tiv.hidden = YES;
        self.div.hidden = YES;
        self.tiv.hidden = NO;
    }else if(target == 2){
        self.label_dis.text = @"时间";
        self.label_time.text = @"距离（公里）";
        self.big_div.hidden = YES;
        self.big_tiv.hidden = NO;
        self.div.hidden = NO;
        self.tiv.hidden = YES;
    }
    if(target == 0){
        self.label_target.text = @"自由运动";
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CNGPSPoint*)getOnePoint{
    CNGPSPoint* gpsPoint = [[CNGPSPoint alloc]init];
    gpsPoint.status = kApp.runStatus;
    gpsPoint.lon = kApp.locationHandler.userLocation_lon;
    gpsPoint.lat = kApp.locationHandler.userLocation_lat;
    gpsPoint.speed = kApp.locationHandler.speed;
    gpsPoint.course = kApp.locationHandler.course;
    gpsPoint.altitude = kApp.locationHandler.altitude;
    gpsPoint.time = [CNUtil getNowTime];
    return gpsPoint;
}
- (void)pushOnePoint{
    //记录下数组中最后一个点
    CNGPSPoint* lastPoint = [kApp.oneRunPointList lastObject];
    NSLog(@"上一个点：%@",[NSString stringWithFormat:@"lon:%f,lat:%f",lastPoint.lon,lastPoint.lat]);
    //得到新的一个点压入数组
    CNGPSPoint* gpsPoint = [self getOnePoint];
    //判断是否离的特别近
    CLLocation *current=[[CLLocation alloc] initWithLatitude:gpsPoint.lat longitude:gpsPoint.lon];
    CLLocation *before=[[CLLocation alloc] initWithLatitude:lastPoint.lat longitude:lastPoint.lon];
    CLLocationDistance meters=[current distanceFromLocation:before];
    if(meters < 5){//离得特别近
        if(gpsPoint.status == lastPoint.status){//两点状态一样
            //不保存这个点，算一下配速和进度条
            if(gpsPoint.status == 1){//运动中，计算
                kApp.totalSecond = kApp.alreadySecond + (int)([CNUtil getNowTime] - kApp.startTime);
                //计算一下平均配速：
                kApp.perMileSecond = 1000.0/kApp.distance*kApp.totalSecond;
                
            }
            lastPoint.time = gpsPoint.time;//就不入数组了，而是更新时间
        }else{//两点状态不一样，要计算配速、进度条和距离
            if(gpsPoint.status == 1){//运动中，计算
                kApp.totalSecond = kApp.alreadySecond + (int)([CNUtil getNowTime] - kApp.startTime);
                //计算一下平均配速：
                kApp.perMileSecond = 1000.0/kApp.distance*kApp.totalSecond;
                kApp.distance += meters;
            }
            [kApp.oneRunPointList addObject:gpsPoint];
        }
    }else{
        if(gpsPoint.status == 1){
            kApp.totalSecond = kApp.alreadySecond + (int)([CNUtil getNowTime] - kApp.startTime);
            //计算一下平均配速：
            kApp.perMileSecond = 1000.0/kApp.distance*kApp.totalSecond;
            kApp.distance += meters;
        }
        [kApp.oneRunPointList addObject:gpsPoint];
    }
    if(kApp.totalSecond < 0){
        kApp.totalSecond = 0;
    }
    if(kApp.perMileSecond < 0){
        kApp.perMileSecond = 0;
    }
    if(kApp.distance < 0){
        kApp.distance = 0;
    }
    //显示到ui上
    if(gpsPoint.status == 1){
        int target = [[self.runSettingDic objectForKey:@"target"]intValue];
        if(target == 1 || target == 0){//目标是距离
            if(target == 1){
                int targetDetail = [[self.runSettingDic objectForKey:@"distance"]intValue]*1000;
                if(self.playTarget == NO && kApp.distance > targetDetail){
                    self.reachTarget = YES;//达到目标了
                }
                if(self.playHalf == NO && kApp.distance > targetDetail/2){//达到目标一半
                    self.reachHalf = YES;
                }
                if(kApp.distance > targetDetail - 2000){//快达到目标
                    self.closeToTarget = YES;
                }
                float width = (float)(kApp.distance)/(float)targetDetail*300.0;
                if(width > 300){
                    width = 300;
                }
                CGRect newFrame = self.view_progress.frame;
                newFrame.size = CGSizeMake(width, 3);
                self.view_progress.frame = newFrame;
            }
            self.big_div.distance = (kApp.distance+5)/1000.0;
            [self.big_div fitToSize];
            if(kApp.perMileSecond < 0){
                kApp.perMileSecond = 0;
            }
            self.siv.time = kApp.perMileSecond;
            [self.siv fitToSize];
        }else if(target == 2){
            int targetDetail = [[self.runSettingDic objectForKey:@"time"]intValue]*60;
            if(self.playTarget == NO && kApp.totalSecond > targetDetail){
                self.reachTarget = YES;//达到目标了
            }
            if(self.playHalf == NO && kApp.totalSecond > targetDetail/2){//达到目标一半
                self.reachHalf = YES;
            }
            if(kApp.totalSecond > targetDetail - 10*60){//快达到目标
                self.closeToTarget = YES;
            }
            float width = (float)(kApp.totalSecond)/(float)targetDetail*300.0;
            if(width > 300)width = 300;
            CGRect newFrame = self.view_progress.frame;
            newFrame.size = CGSizeMake(width, 3);
            self.view_progress.frame = newFrame;
            
            self.div.distance = (kApp.distance+5)/1000.0;
            [self.div fitToSize];
            if(kApp.perMileSecond <= 0){
                kApp.perMileSecond = 0;
            }
            self.siv.time = kApp.perMileSecond;
            [self.siv fitToSize];
        }
    }
    //算一下积分：
    if(gpsPoint.status == 1){
        self.second_add = kApp.totalSecond-kApp.kmstartTime;
        if(kApp.distance > (self.pass_km+1)*1000){
            int minute = self.second_add/60;
            kApp.score += [self score4speed:minute];
            kApp.kmstartTime = kApp.totalSecond;
            self.pass_km++;
            self.playkm = YES;
        }
        if(kApp.totalSecond > (self.pass_5munite + 1)*kVoiceTimeInterval*60){//过了5分钟
            self.pass_5munite++;
            self.play5munite = YES;
        }
        [self playVoice];
    }
}
- (int)score4speed:(int)minute{
    if(minute < 5){
        return 12;
    }
    if(minute < 6){
        return 10;
    }
    if(minute < 7){
        return 9;
    }
    if(minute < 8){
        return 8;
    }
    if(minute < 9){
        return 7;
    }
    if(minute < 10){
        return 6;
    }
    if(minute < 11){
        return 5;
    }
    if(minute < 12){
        return 4;
    }
    if(minute < 13){
        return 3;
    }
    return 0;
}

- (void)startTimer{
    kApp.runStatus = 1;
    [kApp.runStatusChangeIndex addObject:[NSNumber numberWithInt:0]];
    //先往数组里放一个点
    CNGPSPoint* gpsPoint = [self getOnePoint];
    [kApp.oneRunPointList addObject:gpsPoint];
    kApp.startTime = gpsPoint.time;
    kApp.kmstartTime = 0;
    //然后每5秒放一个点
    kApp.timer_one_point = [NSTimer scheduledTimerWithTimeInterval:kInterval target:self selector:@selector(pushOnePoint) userInfo:nil repeats:YES];
    //启动显示时间的timer
    kApp.timer_secondplusplus = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeaddadd) userInfo:nil repeats:YES];
}
- (void)stopTimer{
    [kApp.timer_one_point invalidate];
}
- (void)timeaddadd{
    kApp.run_second = kApp.alreadySecond + (int)([CNUtil getNowTime] - kApp.startTime);
}
- (void)displayTime{
    int target = [[self.runSettingDic objectForKey:@"target"]intValue];
    if(target == 1 || target == 0){//目标是距离
        self.tiv.time = kApp.run_second;
        [self.tiv fitToSize];
    }else if(target == 2){
        self.big_tiv.time = kApp.run_second;
        [self.big_tiv fitToSize];
    }
}
- (IBAction)button_map_clicked:(id)sender {
    BOOL inChina = YES;
    if(inChina){
        CNRunMapViewController* mapVC = [[CNRunMapViewController alloc]init];
        [self.navigationController pushViewController:mapVC animated:YES];
    }else{
        CNRunMapGoogleViewController* mapVC = [[CNRunMapGoogleViewController alloc]init];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_dispalyTime invalidate];
}

- (IBAction)button_control_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"完成");
            self.button_complete.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
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
            kApp.timer_secondplusplus = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeaddadd) userInfo:nil repeats:YES];
            self.timer_dispalyTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
            NSLog(@"恢复");
            kApp.startTime = [CNUtil getNowTime];
            break;
        }
        default:
            break;
    }
}
// MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)slideView {
    [kApp.voiceHandler voiceOfapp:@"run_pause" :nil];
    kApp.pauseCount = [kApp.oneRunPointList count];
    // Customization example
    NSLog(@"滑动");
    kApp.runStatus = 2;
    kApp.alreadySecond = kApp.totalSecond;
    int hascount = [kApp.oneRunPointList count];
    [kApp.runStatusChangeIndex addObject:[NSNumber numberWithInt:hascount-1]];
    self.view_bottom_slider.hidden = YES;
    [self.timer_dispalyTime invalidate];
    [kApp.timer_secondplusplus invalidate];
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
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            int count = [kApp.oneRunPointList count];
            if(count > kApp.pauseCount){//去掉最后一小段从暂停到完成的距离
                for(int i=kApp.pauseCount;i<count;i++){
                    [kApp.oneRunPointList removeLastObject];
                }
            }
            [self stopTimer];
            kApp.runStatus = 0;
            if(kApp.distance < 50){
                kApp.isRunning = 0;
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
- (void)playVoice{
    int target = [[self.runSettingDic objectForKey:@"target"]intValue];
    if(target == 0){//自由
        if(self.playkm){//整公里了
            self.playkm = NO;
            NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
            [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
            [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
            [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
            [kApp.voiceHandler voiceOfapp:@"every_km" :voice_params];
            return;
        }
    }else if(target == 1){//目标是距离
        int targetDetail = [[self.runSettingDic objectForKey:@"distance"]intValue]*1000;//目标
        if(targetDetail > 4000){//目标大于4000
            if(self.playTarget == NO&&self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.playkm){//如果正好是整公里则告诉不需要播报整公里了
                    self.playkm = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_distance" :voice_params];
                return;
            }
            if(self.playkm && self.reachTarget){//整公里且大于目标
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km_and_pass_target" :voice_params];
                return;
            }
            if(self.playHalf == NO && self.reachHalf){//达到目标一半
                self.playHalf = YES;
                if(self.playkm){//如果正好是整公里则告诉不需要播报整公里了
                    self.playkm = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [kApp.voiceHandler voiceOfapp:@"half_target_dis" :voice_params];
                return;
            }
            if(self.playkm && self.closeToTarget){//整公里且接近目标
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km_and_close_to_target" :voice_params];
                return;
            }
            if(self.playkm){
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km" :voice_params];
                return;
            }
        }else{//目标小于4000
            if(self.playTarget == NO&&self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.playkm){//如果正好是整公里则告诉不需要播报整公里了
                    self.playkm = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_distance" :voice_params];
                return;
            }
            if(self.playkm && self.reachTarget){//整公里且大于目标
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km_and_pass_target" :voice_params];
                return;
            }
            if(self.playkm){
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km" :voice_params];
                return;
            }
        }
    }else if(target == 2){
        int targetDetail = [[self.runSettingDic objectForKey:@"time"]intValue]*60;//时间目标
        if(targetDetail > 1200){//目标大于1200
            if(self.playTarget == NO && self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.play5munite){//如果正好是5n分钟就不播了
                    self.play5munite = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_time" :voice_params];
                return;
            }
            if(self.play5munite && self.reachTarget){//5n分钟且大于目标
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite_and_pass_target" :voice_params];
                return;
            }
            if(self.playHalf == NO && self.reachHalf){//达到目标一半
                self.playHalf = YES;
                if(self.play5munite){//如果正好是整公里则告诉不需要播报整公里了
                    self.play5munite = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [kApp.voiceHandler voiceOfapp:@"half_target_time" :voice_params];
                return;
            }
            if(self.play5munite && self.closeToTarget){//5n分钟且接近目标
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite_and_close_to_target" :voice_params];
                return;
            }
            if(self.play5munite){
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite" :voice_params];
                return;
            }
        }else{
            if(self.playTarget == NO && self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.play5munite){//如果正好是5n分钟就不播了
                    self.play5munite = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_time" :voice_params];
                return;
            }
            if(self.play5munite && self.reachTarget){//5n分钟且大于目标
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite_and_pass_target" :voice_params];
                return;
            }
            if(self.play5munite){
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.totalSecond] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite" :voice_params];
                return;
            }
        }
    }
}
@end

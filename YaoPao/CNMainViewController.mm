//
//  CNMainViewController.m
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNMainViewController.h"
#import "CNNetworkHandler.h"
#import "CNLoginPhoneViewController.h"
#import "CNUserinfoViewController.h"
#import "CNStartRunViewController.h"
#import "ASIHTTPRequest.h"
#import "CNRunRecordViewController.h"
#import "CNMatchCountDownViewController.h"
#import "CNMessageViewController.h"
#import "MobClick.h"
#import "CNSettingViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CNDistanceImageView.h"
#import "CNTimeImageView.h"
#import "CNSpeedImageView.h"
#import "CNNumImageView.h"
#import "Toast+UIView.h"
#import "SBJson.h"
#import "CNGroupInfoViewController.h"
#import "CNTestGEOS.h"
#import "CNBeforeMatchViewController.h"
#import "CNVoiceHandler.h"
#import "CNLocationHandler.h"
#import "CNUtil.h"
#import "CNVCodeViewController.h"
#import "CNRunMapGoogleViewController.h"

@interface CNMainViewController ()

@end

@implementation CNMainViewController
@synthesize div;
@synthesize image_km;
@synthesize niv_count;
@synthesize siv;
@synthesize niv;
@synthesize bannerView_;

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
    
    NSArray* array = [kApp.showad componentsSeparatedByString:@","];
    //广告：
    if([array count] == 2){
        if([[array objectAtIndex:0] isEqualToString:ClIENT_VERSION]){
            if([[array objectAtIndex:1] isEqualToString:@"1"]){
                [self addAd];
            }
        }
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginDone) name:@"loginDone" object:nil];
    [self.button_setting addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_record addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_message addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_match addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    
    self.div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(4, 140+IOS7OFFSIZE, 260, 64)];
    [self.self.view addSubview:div];
    self.image_km = [[UIImageView alloc]initWithFrame:CGRectMake(div.frame.origin.x+div.frame.size.width, 140+IOS7OFFSIZE,52, 64)];
    self.image_km.image = [UIImage imageNamed:@"redkm.png"];
    [self.view addSubview:self.image_km];
    
    self.niv_count = [[CNNumImageView alloc]initWithFrame:CGRectMake(25, 5, 50, 16)];
    [self.view_total_count addSubview:self.niv_count];
    
    
    
    self.siv = [[CNSpeedImageView alloc]initWithFrame:CGRectMake(35, 5, 50, 16)];
    [self.view_total_speed addSubview:self.siv];
    
    self.niv = [[CNNumImageView alloc]initWithFrame:CGRectMake(25, 5, 50, 16)];
    [self.view_total_score addSubview:self.niv];
    
    if(kApp.isLogin == 2){//正在登录
        [self displayLoading];
    }else{
        if(kApp.isLogin == 11){//老用户需要自动登录
            CNVCodeViewController* vcodeVC = [[CNVCodeViewController alloc]init];
            [self.navigationController pushViewController:vcodeVC animated:YES];
        }
    }
}
- (void)loginDone{
    [self hideLoading];
    //加载用户信息
    [self initUI];
}
- (void)initData{
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
    }
    float totaldistance = [[record_dic objectForKey:@"total_distance"]floatValue]/1000;
    self.div.distance = totaldistance;
    self.div.color = @"red";
    [self.div fitToSize];
    self.image_km.frame = CGRectMake(self.div.frame.origin.x+div.frame.size.width, 140+IOS7OFFSIZE,52, 64);
    self.niv_count.num = [[record_dic objectForKey:@"total_count"]intValue];
    self.niv_count.color = @"white";
    [self.niv_count fitToSize];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    
    int average_pspeed = 1.0/totaldistance*total_time;
    self.siv.time = average_pspeed;
    self.siv.color = @"white";
    [self.siv fitToSize];
    self.niv.num = [[record_dic objectForKey:@"total_score"]intValue];
    self.niv.color = @"white";
    [self.niv fitToSize];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)button_white_down:(id)sender{
    switch ([sender tag]) {
        case 3:
            self.view_record.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 4:
            self.view_message.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 5:
            self.view_match.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
            
        default:
            break;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"mainPage"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self initUI];
    [self initData];
}
- (void)initUI{
    if(kApp.userInfoDic != nil){//已经登录状态
        if(kApp.hasMessage){
            self.imageview_dot.hidden = NO;
        }else{
            self.imageview_dot.hidden = YES;
        }
        NSString* nickname = [kApp.userInfoDic objectForKey:@"nickname"];
        nickname = (nickname == nil ? [kApp.userInfoDic objectForKey:@"phone"] : nickname);
        self.label_username.text = nickname;
        NSString* signature = [kApp.userInfoDic objectForKey:@"signature"];
        signature = ((signature == nil || [signature isEqualToString:@""])? @"什么都没写" : signature);
        self.label_des.text = signature;
        self.button_goLogin.hidden = YES;
        NSString* imgpath = [kApp.userInfoDic objectForKey:@"imgpath"];
        if(imgpath != nil){
            //显示头像
            NSData* imageData = kApp.imageData;
            if(imageData){
                self.image_avatar.image = [[UIImage alloc] initWithData:imageData];
            }else{
                NSString *avatar = imgpath;
                NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,avatar];
                NSLog(@"avatar is %@",imageURL);
                NSURL *url = [NSURL URLWithString:imageURL];
                ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
                Imagerequest.tag = 1;
                Imagerequest.timeOutSeconds = 15;
                [Imagerequest setDelegate:self];
                [Imagerequest startAsynchronous];
            }
        }
    }else{//未登录状态
        self.image_avatar.image = [UIImage imageNamed:@"avatar_default.png"];
        self.label_username.text = @"未登录";
        self.label_des.text = @"轻触以登录要跑";
        self.button_goLogin.hidden = NO;
    }
}
#pragma -mark ASIHttpRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    UIImage *image = [[UIImage alloc] initWithData:[request responseData]];
    if(image){
        self.image_avatar.image = image;
        kApp.imageData = [request responseData];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    kApp.isLogin = 0;
    kApp.userInfoDic = nil;
    kApp.imageData = nil;
    NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
    [self initUI];
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            self.button_setting.backgroundColor = [UIColor clearColor];
            CNSettingViewController* settingVC = [[CNSettingViewController alloc]init];
            [self.navigationController pushViewController:settingVC animated:YES];
            
//            CNRunMapGoogleViewController* testVC = [[CNRunMapGoogleViewController alloc]init];
//            [self.navigationController pushViewController:testVC animated:YES];
            break;
        }
        case 1:
        {
            CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
            [self.navigationController pushViewController:loginVC animated:YES];
            break;
        }
        case 2:
        {
            CNStartRunViewController* startRunVC = [[CNStartRunViewController alloc]init];
            [self.navigationController pushViewController:startRunVC animated:YES];
            break;
        }
        case 3:
        {
            self.view_record.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNRunRecordViewController* recordVC = [[CNRunRecordViewController alloc]init];
            [self.navigationController pushViewController:recordVC animated:YES];
            break;
        }
        case 4:
        {
            self.view_message.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            NSLog(@"消息");
            if(kApp.isLogin == 0){
                [kApp.window makeToast:@"您必须注册并登录，才会收到系统消息，所以现在没有系统消息哦"];
                CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
                [self.navigationController pushViewController:loginVC animated:YES];
            }else{
                kApp.hasMessage = NO;
                CNMessageViewController* messageVC = [[CNMessageViewController alloc]init];
                [self.navigationController pushViewController:messageVC animated:YES];
            }
            break;
        }
        case 5:
        {
            self.view_match.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            NSURL* url = [[ NSURL alloc ] initWithString :@"http://image.yaopao.net/html/redirect.html"];
            [[UIApplication sharedApplication ] openURL: url];
//            if(kApp.match_isLogin == 0){//如果没登录，进宣宇界面
//                [self gotoJSPage];
//            }else{//登录了
//                NSString* matchstage = [CNUtil getMatchStage];
//                if([matchstage isEqualToString:@"beforeMatch"]){//赛前5分钟还要之前
//                    [self gotoJSPage];
//                }else if([matchstage isEqualToString:@"closeToMatch"]){//赛前5分钟到比赛正式开始
//                    if(kApp.isMatch == 1){//参赛
//                        [self shouldStartButNot];
//                    }else{
//                        [self gotoJSPage];
//                    }
//                }else if([matchstage isEqualToString:@"isMatching"]){//正式比赛时间
//                    if(kApp.isMatch == 1){//参赛
//                        if(kApp.hasFinishTeamMatch){//提前结束比赛了
//                            [self gotoScorePage];
//                        }else{
//                            [self shouldStartButNot];
//                        }
//                    }else{
//                        [self gotoJSPage];
//                    }
//                }else{//赛后
//                    if(kApp.isMatch == 1){//参赛
//                        [self gotoScorePage];
//                    }else{
//                        [self gotoJSPage];
//                    }
//                }
//            }
//            CNStartRunViewController* startRunVC = [[CNStartRunViewController alloc]init];
//            [self.navigationController pushViewController:startRunVC animated:YES];
            break;
        }
        case 6:{
            CNUserinfoViewController* userInfoVC = [[CNUserinfoViewController alloc]init];
            userInfoVC.from = @"setting";
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
        default:
            break;
    }
}
- (void)gotoJSPage{
    CNBeforeMatchViewController* beforeVC = [[CNBeforeMatchViewController alloc]init];
    [self.navigationController pushViewController:beforeVC animated:YES];
}
- (void)gotoScorePage{
    CNGroupInfoViewController* groupInfoVC = [[CNGroupInfoViewController alloc]init];
    groupInfoVC.from = @"main";
    [self.navigationController pushViewController:groupInfoVC animated:YES];
}
- (void)shouldStartButNot{
    [kApp.window makeToast:@"你未能正常开始比赛，请重新登录"];
    kApp.isLogin = 0;
    kApp.match_isLogin = 0;
    kApp.userInfoDic = nil;
    kApp.matchDic = nil;
    kApp.imageData = nil;
    NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
    [self initUI];
    CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"mainPage"];
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![CLLocationManager locationServicesEnabled]){//这里判断系统设置的定位打开没有
        NSLog(@"异常提示：系统没有打开gps");
        [CNAppDelegate popupWarningGPSOpen];
    }
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable){
        NSLog(@"异常提示：系统没有打开后台刷新");
        [CNAppDelegate popupWarningBackground];
    }
}

- (void)addAd{
    //广告
    self.bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    if(iPhone5){
        self.bannerView_.frame = CGRectMake(0, 518, 320, 50);
    }else{
        self.bannerView_.frame = CGRectMake(0, 430, 320, 50);
    }
    // 指定广告单元ID。
    self.bannerView_.adUnitID = @"ca-app-pub-2147750945893708/7542258473";
    self.bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];    
    [bannerView_ loadRequest:[GADRequest request]];
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
    [self disableAllButton];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    [self enableAllButton];
}
- (void)disableAllButton{
    self.button_goLogin.enabled = NO;
    self.button_match.enabled = NO;
    self.button_message.enabled = NO;
    self.button_record.enabled = NO;
    self.button_setting.enabled = NO;
}
- (void)enableAllButton{
    self.button_goLogin.enabled = YES;
    self.button_match.enabled = YES;
    self.button_message.enabled = YES;
    self.button_record.enabled = YES;
    self.button_setting.enabled = YES;
}

@end

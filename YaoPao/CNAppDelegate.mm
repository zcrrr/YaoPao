//
//  CNAppDelegate.m
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNAppDelegate.h"
#import "CNMainViewController.h"
#import "CNNetworkHandler.h"
#import <AdSupport/AdSupport.h>
#import "CNLocationHandler.h"
#import <MAMapKit/MAMapKit.h>
#import "RunClass.h"
#import "CNGPSPoint.h"
#import "CNMatchCountDownViewController.h"
#import "CNMatchMainViewController.h"
#import "MobClick.h"
#import "CNWarningGPSOpenViewController.h"
#import "CNWarningGPSWeakViewController.h"
#import "CNWarningBackGroundViewController.h"
#import "CNGPSPoint4Match.h"
#import "CNUtil.h"
#import "CNGroupInfoViewController.h"
#import "CNMatchMainViewController.h"
#import "CNMatchMainRecomeViewController.h"
#import "CNFinishViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "CNVoiceHandler.h"
#import "CNTestGEOS.h"
#import "CNEncryption.h"
#import "Toast+UIView.h"
#import "CNFinishTeamMatchViewController.h"
#import "CNWarningNotInStartZoneViewController.h"
#import "CNWarningCheckTimeViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import <GoogleMaps/GoogleMaps.h>


@implementation CNAppDelegate
@synthesize navigationController;
@synthesize networkHandler;
@synthesize voiceHandler;
@synthesize runManager;
@synthesize isLogin;
@synthesize pid;
@synthesize userInfoDic;
@synthesize imageData;
@synthesize vcodeSecond;
@synthesize vcodeTimer;
@synthesize locationHandler;
@synthesize oneRunPointList;
@synthesize runStatusChangeIndex;
@synthesize isRunning;
@synthesize timer_one_point;
@synthesize timer_secondplusplus;
@synthesize distance;
@synthesize perMileSecond;
@synthesize totalSecond;
@synthesize startTime;
@synthesize kmstartTime;
@synthesize alreadySecond;
@synthesize runStatus;
@synthesize mood;
@synthesize way;
@synthesize gpsLevel;
@synthesize perHeart;
@synthesize maxHeart;
@synthesize weather;
@synthesize temp;
@synthesize hspeed;
@synthesize feel;
@synthesize isGroup;
@synthesize isMatch;
@synthesize isbaton;
@synthesize run_second;
@synthesize match_startdis;
@synthesize match_currentLapDis;
@synthesize match_countPass;
@synthesize geosHandler;
@synthesize match_historydis;
@synthesize match_historySecond;
@synthesize gpsSignal;
@synthesize pauseCount;
@synthesize score;
@synthesize mainurl;
@synthesize imageurl;
@synthesize showad;
@synthesize showgame;
@synthesize array4Test;
@synthesize hasMessage;
@synthesize match_time_last_in_track;
//@synthesize match_pointsString;
@synthesize match_pointList;
@synthesize match_timer_report;
@synthesize uid;
@synthesize gid;
@synthesize mid;
@synthesize testIndex;
@synthesize match_totaldis;
@synthesize matchDic;
@synthesize match_targetkm;
@synthesize match_totalDisTeam;
@synthesize avatarDic;
@synthesize match_score;
@synthesize match_km_target_personal;
@synthesize match_km_start_time;
@synthesize matchtestdatalength;
@synthesize deltaTime;
@synthesize match_stringTrackZone;

@synthesize match_start_time;
@synthesize match_start_timestamp;
@synthesize match_end_timestamp;
@synthesize match_before5min_timestamp;
@synthesize match_isLogin;
@synthesize match_timer_check_countdown;
@synthesize canStartButNotInStartZone;
@synthesize hasFinishTeamMatch;
@synthesize match_inMatch;
@synthesize match_takeover_zone;
@synthesize match_stringStartZone;
@synthesize match_track_line;
@synthesize voiceOn;
@synthesize hasCheckTimeFromServer;
@synthesize isInChina;
@synthesize isKnowCountry;

@synthesize managedObjectModel=_managedObjectModel;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.gpsLevel = 1;
    //google map
    [GMSServices provideAPIKey:@"AIzaSyCyYR5Ih3xP0rpYMaF1qAsInxFyqvaCJIY"];
    
    //设置时区
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    
    //友盟
    [MobClick startWithAppkey:@"53fd6e13fd98c561b903e002" reportPolicy:BATCH   channelId:@""];
    [MobClick updateOnlineConfig];
    [MobClick setLogEnabled:YES];
    self.mainurl = [MobClick getConfigParams:@"mainurl"];
    NSLog(@"self.mainurl is %@",self.mainurl);
    if (self.mainurl == nil || ([NSNull null] == (NSNull *)self.mainurl)) {
        self.mainurl = @"http://appservice.yaopao.net/";
    }
    self.imageurl = [MobClick getConfigParams:@"imgurl"];
    NSLog(@"self.imageurl is %@",self.imageurl);
    if (self.imageurl == nil || ([NSNull null] == (NSNull *)self.imageurl)) {
        self.imageurl = @"http://image.yaopao.net/";
    }
//    self.imageurl = @"http://yaopaotest.oss-cn-beijing.aliyuncs.com/";
    self.showad = [MobClick getConfigParams:@"showad"];
    NSLog(@"self.showad is %@",self.showad);
    if (self.showad == nil || ([NSNull null] == (NSNull *)self.showad)) {
        self.showad = @"1.0.5,1";
    }
//#ifdef SIMULATORTEST
//
//#else
//    self.match_start_time = [MobClick getConfigParams:@"gamestarttime"];
//# endif
//    NSLog(@"self.match_start_time is %@",self.match_start_time);
//    if (self.match_start_time == nil || ([NSNull null] == (NSNull *)self.match_start_time)) {
//        self.match_start_time = kStartTime;
//    }
    //mob
    [SMS_SDK registerApp:@"3289fdd0ca3b" withSecret:@"78b2977ac2193fe84a48b76595e1267d"];
    
    self.match_start_time = kStartTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* startDate = [dateFormatter dateFromString:self.match_start_time];
    self.match_start_timestamp = [startDate timeIntervalSince1970];
    self.match_before5min_timestamp = match_start_timestamp-5*60;
    self.match_end_timestamp = match_start_timestamp+kDuringMinute*60;
    
    //sharesdk
    [ShareSDK registerApp:@"3289fdd0ca3b"];
    //添加新浪微博应用
//    [ShareSDK connectSinaWeiboWithAppKey:@"3132648285"
//                               appSecret:@"85c67e84287899794cb7d907b2fc78ce"
//                             redirectUri:@"http://www.yaopao.net"];
    [ShareSDK importWeChatClass:[WXApi class]];
    [ShareSDK importQQClass:[QQApiInterface class]
            tencentOAuthCls:[TencentOAuth class]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self initVar];
    //自动登录一下
    NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(userInfo){//需要自动登录
        NSString* filePath2 = [CNPersistenceHandler getDocument:@"newVersionLogin.plist"];
        NSMutableDictionary* dic2 = [NSMutableDictionary dictionaryWithContentsOfFile:filePath2];
        if(dic2){
            NSString* code = [dic2 objectForKey:@"isLogin"];
            if([code isEqualToString:@"11"]){//新版本的登陆
                NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                [params setObject:[userInfo objectForKey:@"uid"] forKey:@"uid"];
                [kApp.networkHandler doRequest_autoLogin:params];
                kApp.isLogin = 2;
            }
        }else{//旧版本的自动登陆
            kApp.isLogin = 11;
        }
    }
    CNMainViewController* mainVC = [[CNMainViewController alloc]init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    //屏幕长亮
    [[ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
//    [self lookup];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"退到后台");
    if(kApp.isRunning == 0){
        if(kApp.locationHandler.isStart == 1){
            [self.locationHandler stopLocation];
        }
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"回到前台");
    if(kApp.locationHandler.isStart == 0){
        [self.locationHandler startGetLocation];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//托管对象
-(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel!=nil) {
        return _managedObjectModel;
    }
    NSURL* modelURL=[[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel=[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _managedObjectModel=[NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}
//托管对象上下文
-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext!=nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator=[self persistentStoreCoordinator];
    if (coordinator!=nil) {
        _managedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
//持久化存储协调器
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         */
        abort();
    }
    return _persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)initVar{
    self.networkHandler = [[CNNetworkHandler alloc]init];
    [self.networkHandler startQueue];//开启队列
    NSLog(@"test------------");
    self.locationHandler = [[CNLocationHandler alloc]init];
    self.voiceHandler = [[CNVoiceHandler alloc]init];
    [self.voiceHandler initPlayer];
    self.pid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSLog(@"pid is %@",pid);
    self.ua = [NSString stringWithFormat:@"I_%@,i_%@",[[UIDevice currentDevice] systemVersion],ClIENT_VERSION];
    NSLog(@"ua is %@",self.ua);
    kApp.geosHandler = [[CNTestGEOS alloc]init];
    [kApp.geosHandler initFromFile:kTrackName];
    self.avatarDic = [[NSMutableDictionary alloc]init];
    [MAMapServices sharedServices].apiKey =@"0f3dad31deac3acd29ce27c3c2a265f2";
}
+ (CNAppDelegate*)getApplicationDelegate{
    return (CNAppDelegate*)[[UIApplication sharedApplication] delegate];
}
+ (void)initRun{
    kApp.oneRunPointList = [[NSMutableArray alloc]init];
    kApp.runStatusChangeIndex = [[NSMutableArray alloc]init];
    kApp.distance = 0;
    kApp.totalSecond = 0;
    kApp.startTime = 0;
    kApp.kmstartTime = 0;
    kApp.alreadySecond = 0;
    kApp.perMileSecond = 0;
    kApp.runStatus = 0;
    kApp.mood = 0;
    kApp.way = 0;
    kApp.perHeart = 0;
    kApp.maxHeart = 0;
    kApp.weather = 1;
    kApp.temp = 0;
    kApp.feel = @"";
    kApp.run_second = 0;
    kApp.score = 0;
}
+ (void)match_save2plist{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_historydis] forKey:@"match_historydis"];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_totalDisTeam] forKey:@"match_totalDisTeam"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_targetkm] forKey:@"match_targetkm"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_historySecond] forKey:@"match_historySecond"];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_startdis] forKey:@"match_startdis"];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_currentLapDis] forKey:@"match_currentLapDis"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_countPass] forKey:@"match_countPass"];
    if(kApp.match_time_last_in_track < 1){
        kApp.match_time_last_in_track = [CNUtil getNowTimeDelta];
    }
    [dic setObject:[NSString stringWithFormat:@"%llu",kApp.match_time_last_in_track] forKey:@"match_time_last_in_track"];
//    [dic setObject:kApp.match_pointsString forKey:@"match_pointsString"];
    
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_score] forKey:@"match_score"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_km_target_personal] forKey:@"match_km_target_personal"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_km_start_time] forKey:@"match_km_start_time"];
    NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
    [dic writeToFile:filePath atomically:YES];
}

-(void)addARecord:(RunClass*)aRecord{
    RunClass * runClass  = [NSEntityDescription insertNewObjectForEntityForName:@"RunClass"
                                                         inManagedObjectContext:self.managedObjectContext];
    runClass.rid = @"12345678";
    runClass.runtar = [NSNumber numberWithInt:1];
    runClass.runty = [NSNumber numberWithInt:1];
    runClass.runtra = @"轨迹点字符串";
    runClass.mind = [NSNumber numberWithInt:1];
    runClass.runway = [NSNumber numberWithInt:1];
    runClass.aheart = [NSNumber numberWithInt:60];
    runClass.mheart = [NSNumber numberWithInt:100];
    runClass.weather = [NSNumber numberWithInt:2];
    runClass.temp = [NSNumber numberWithInt:27];
    runClass.distance = [NSNumber numberWithFloat:213.33];
    runClass.utime = [NSNumber numberWithInt:1700];
    runClass.pspeed = [NSNumber numberWithFloat:34.34];
    runClass.hspeed = [NSNumber numberWithFloat:14.33];
    runClass.heat = [NSNumber numberWithInt:100];
    runClass.remarks = @"说点什么吧";
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@", error);
        abort();
    }
    NSLog(@"add success");
}
- (void)lookup{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunClass" inManagedObjectContext:self.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rid" ascending:YES];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    for (RunClass *runClass in mutableFetchResult) {
        NSLog(@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",runClass.rid,runClass.runtar,runClass.runty,runClass.runtra,runClass.mind,runClass.runway,runClass.aheart,runClass.mheart,runClass.weather,runClass.temp,runClass.distance,runClass.utime,runClass.pspeed,runClass.hspeed,runClass.heat,runClass.remarks);
    }
}

+ (void)makeTest{
    NSMutableArray *testArray = [[NSMutableArray alloc]initWithObjects:@"116.380854,39.836082,1",
                                 @"116.380854,39.836082,1",
                                 @"116.380720,39.836167,1",
                                 @"116.380703,39.836469,1",
                                 @"116.380665,39.836841,1",
                                 @"116.380669,39.837214,1",
                                 @"116.380640,39.837549,1",
                                 @"116.380667,39.837918,1",
                                 @"116.380658,39.838256,1",
                                 @"116.380639,39.838438,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,1",
                                 @"116.380624,39.838485,2",
                                 @"116.380626,39.838596,2",
                                 @"116.380498,39.838757,2",
                                 @"116.380019,39.838824,2",
                                 @"116.379644,39.838834,2",
                                 @"116.379644,39.838834,2",
                                 @"116.379644,39.838834,2",
                                 @"116.379585,39.838838,2",
                                 @"116.379219,39.838848,2",
                                 @"116.378769,39.838883,2",
                                 @"116.378246,39.838906,2",
                                 @"116.377642,39.838916,2",
                                 @"116.377075,39.838910,2",
                                 @"116.376507,39.838883,2",
                                 @"116.375910,39.838883,2",
                                 @"116.375447,39.838871,2",
                                 @"116.375070,39.838851,2",
                                 @"116.375043,39.838849,2",
                                 @"116.375043,39.838849,2",
                                 @"116.375043,39.838849,2",
                                 @"116.374933,39.838849,2",
                                 @"116.374726,39.838843,2",
                                 @"116.374209,39.838816,2",
                                 @"116.373646,39.838819,2",
                                 @"116.373172,39.838841,2",
                                 @"116.373001,39.838844,2",
                                 @"116.373001,39.838844,2",
                                 @"116.373001,39.838844,1",
                                 @"116.373001,39.838844,1",
                                 @"116.373001,39.838844,1",
                                 @"116.373001,39.838844,1",
                                 @"116.373001,39.838844,1",
                                 @"116.373001,39.838844,1",
                                 @"116.373001,39.838844,1",
                                 @"116.373001,39.838844,1",
                                 @"116.372719,39.838788,1",
                                 @"116.372513,39.838699,1",
                                 @"116.372452,39.838401,1",
                                 @"116.372486,39.837967,1",
                                 @"116.372543,39.837509,1",
                                 @"116.372566,39.837015,1",
                                 @"116.372601,39.836493,1",
                                 @"116.372631,39.836063,1",
                                 @"116.372626,39.835836,1",
                                 @"116.372626,39.835836,1",
                                 @"116.372587,39.835774,1",
                                 @"116.372602,39.835725,1",
                                 @"116.372621,39.835557,1",
                                 @"116.372643,39.835301,1",
                                 @"116.372580,39.834980,1",
                                 @"116.372589,39.834702,1",
                                 @"116.372592,39.834528,1",
                                 @"116.372465,39.834439,1",
                                 @"116.372310,39.834420,1",
                                 @"116.372035,39.834421,1",
                                 @"116.371655,39.834413,1",
                                 @"116.370943,39.834446,1",
                                 @"116.370387,39.834463,1",
                                 nil];
    kApp.oneRunPointList = [[NSMutableArray alloc]init];
    int i = 0;
    for(i = 0;i<[testArray count];i++){
        CNGPSPoint* point = [[CNGPSPoint alloc]init];
        NSString* lonlat = [testArray objectAtIndex:i];
        NSArray* lonlats = [lonlat componentsSeparatedByString:@","];
        double lon = [[lonlats objectAtIndex:0]doubleValue];
        double lat = [[lonlats objectAtIndex:1]doubleValue];
        int status = [[lonlats objectAtIndex:2]intValue];
        point.lon = lon;
        point.lat = lat;
        point.status = status;
        point.time = 1407490264+i*5;
        [kApp.oneRunPointList addObject:point];
    }
    kApp.runStatusChangeIndex = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:25],[NSNumber numberWithInt:52],[NSNumber numberWithInt:83],nil];
}
+ (void)makeMatchTest{
//    NSString* testString = @"116.390053 39.968191, 116.390114 39.96743, 116.390148 39.966718, 116.390167 39.966443, 116.390167 39.966385, 116.390171 39.966344, 116.390171 39.966321, 116.390167 39.966306, 116.390163 39.966298, 116.390156 39.966288, 116.390148 39.966281, 116.390141 39.966276, 116.390129 39.966273, 116.390118 39.96627, 116.390038 39.96626, 116.389919 39.966245, 116.389721 39.966227, 116.389687 39.966222, 116.389656 39.966217, 116.38961 39.966207, 116.389553 39.966192, 116.389462 39.966164, 116.389221 39.966085, 116.388733 39.965965, 116.388462 39.965925, 116.388195 39.965899, 116.388195 39.965899, 116.388268 39.966054, 116.388275 39.96727, 116.388271 39.968147, 116.389381 39.968168, 116.389481 39.968173, 116.390053 39.968191";
    NSString* testString = @"116.390053 39.968191, 116.390114 39.96743, 116.390148 39.966718, 116.390167 39.966443, 116.390167 39.966385, 116.390171 39.966344, 116.390171 39.966321, 116.390167 39.966306, 116.390163 39.966298, 116.390156 39.966288, 116.390148 39.966281, 116.390141 39.966276, 0 0, 116.389687 39.966222, 116.389656 39.966217, 116.38961 39.966207, 116.389553 39.966192, 116.389462 39.966164, 116.389221 39.966085, 116.388733 39.965965, 116.388462 39.965925, 0 0, 116.388275 39.96727, 116.388271 39.968147, 116.389381 39.968168";
    kApp.match_pointList = [[NSMutableArray alloc]init];
    NSArray* pointlist = [testString componentsSeparatedByString:@", "];
    int i=0;
    for(i=0;i<[pointlist count];i++){
        CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
        NSArray* lonlats = [[pointlist objectAtIndex:i] componentsSeparatedByString:@" "];
        point.lon = [[lonlats objectAtIndex:0]doubleValue];
        point.lat = [[lonlats objectAtIndex:1]doubleValue];
        [kApp.match_pointList addObject:point];
    }
}
+ (void)finishThisRun{
    kApp.isbaton = 0;
    [CNAppDelegate saveMatchToRecord];
    [kApp.timer_one_point invalidate];
    [kApp.timer_secondplusplus invalidate];
    [kApp.match_timer_report invalidate];
    NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
}
+ (void)popupWarningGPSOpen{
    CNWarningGPSOpenViewController* warningVC = [[CNWarningGPSOpenViewController alloc]init];
    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
}
+ (void)popupWarningGPSWeak{
    CNWarningGPSWeakViewController* warningVC = [[CNWarningGPSWeakViewController alloc]init];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:warningVC animated:YES completion:^(void){NSLog(@"pop");}];
}
+ (void)popupWarningBackground{
    CNWarningBackGroundViewController* warningVC = [[CNWarningBackGroundViewController alloc]init];
    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
}
+ (void)popupWarningNotInStartZone{
    CNWarningNotInStartZoneViewController* warningVC = [[CNWarningNotInStartZoneViewController alloc]init];
    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
}
+ (void)popupWarningCheckTime{
    CNWarningCheckTimeViewController* warningVC = [[CNWarningCheckTimeViewController alloc]init];
    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:navVC animated:NO completion:^(void){NSLog(@"pop");}];
}

+ (CNGPSPoint4Match*)test_getOnePoint{
    NSMutableArray* testlist = [[NSMutableArray alloc]init];
    NSArray* pointlist = [kApp.match_track_line componentsSeparatedByString:@", "];
    kApp.matchtestdatalength = [pointlist count];
    int i=0;
    for(i=0;i<[pointlist count];i++){
        CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
        NSArray* lonlats = [[pointlist objectAtIndex:i] componentsSeparatedByString:@" "];
        point.lon = [[lonlats objectAtIndex:0]doubleValue];
        point.lat = [[lonlats objectAtIndex:1]doubleValue];
        point.time = [CNUtil getNowTimeDelta];
        [testlist addObject:point];
    }
    CNGPSPoint4Match* testpoint = [testlist objectAtIndex:kApp.testIndex];
    return testpoint;
}
+ (void)whatShouldIdo{
    kApp.voiceOn = 1;//开启语音
    //先判断时间
    NSString* matchstage = [CNUtil getMatchStage];
    if([matchstage isEqualToString:@"beforeMatch"]){//赛前5分钟还要之前
        kApp.match_timer_check_countdown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check_start_match) userInfo:nil repeats:YES];
    }else if([matchstage isEqualToString:@"closeToMatch"]){//赛前5分钟到比赛正式开始
        if(kApp.isbaton == 1){//第一棒
            [CNAppDelegate ForceGoMatchPage:@"countdown"];
        }else{//不是第一棒
            [CNAppDelegate ForceGoMatchPage:@"matchWatch"];
        }
    }else if([matchstage isEqualToString:@"isMatching"]){//正式比赛时间
        if(kApp.isbaton == 1){//正在跑
            //通过plist文件判断是否是崩溃重进
            NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
            NSDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
            if(dic == nil){//没有这个文件，则说明上次不是比赛中闪退的
                if(kApp.isbaton == 1 && kApp.match_totalDisTeam < 1){//如果是第一棒有个特殊条件才能启动，就是必须在出发区
                    if([CNAppDelegate isInStartZone]){
                        [CNAppDelegate ForceGoMatchPage:@"matchRun_normal"];
                    }else{
                        kApp.canStartButNotInStartZone = YES;
                        [CNAppDelegate popupWarningNotInStartZone];
                    }
                }else{
                    [CNAppDelegate ForceGoMatchPage:@"matchRun_normal"];
                }
            }else{
                [CNAppDelegate ForceGoMatchPage:@"matchRun_crash"];
            }
        }else{//没再跑
            [CNAppDelegate ForceGoMatchPage:@"matchWatch"];
        }
    }else{//赛后
        
    }
}
+ (BOOL)isInStartZone{
    CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(kApp.locationHandler.userLocation_lat, kApp.locationHandler.userLocation_lon);
    CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
#ifdef SIMULATORTEST
    return YES;
//    return [kApp.geosHandler isInTheStartZone:kApp.locationHandler.userLocation_lon :kApp.locationHandler.userLocation_lat];
#else
    return [kApp.geosHandler isInTheStartZone:encryptionPoint.longitude :encryptionPoint.latitude];
# endif
    
}
+ (void)check_start_match{
    if([CNUtil getNowTimeDelta] >= kApp.match_before5min_timestamp){//进入了赛前5分钟
        [kApp.match_timer_check_countdown invalidate];
        if(kApp.isbaton == 1){//第一棒
            [CNAppDelegate ForceGoMatchPage:@"countdown"];
        }else{//不是第一棒
            [CNAppDelegate ForceGoMatchPage:@"matchWatch"];
        }
    }
}
+ (void)ForceGoMatchPage:(NSString*)target{
    if([target isEqualToString:@"countdown"]){//倒计时
        CNMatchCountDownViewController* matchCountdownVC = [[CNMatchCountDownViewController alloc]init];
        long long nowTimeSecond = [CNUtil getNowTimeDelta];
        matchCountdownVC.startSecond = (int)(kApp.match_start_timestamp - nowTimeSecond);
        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:matchCountdownVC];
        kApp.window.rootViewController = kApp.navigationController;
    }else if([target isEqualToString:@"matchWatch"]){//看比赛
        CNGroupInfoViewController* groupInfoVC = [[CNGroupInfoViewController alloc]init];
        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:groupInfoVC];
        kApp.window.rootViewController = kApp.navigationController;
    }else if([target isEqualToString:@"matchRun_normal"]){//比赛跑步，正常进
        CNMatchMainViewController* matchMainVC = [[CNMatchMainViewController alloc]init];
        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:matchMainVC];
        kApp.window.rootViewController = kApp.navigationController;
    }else if([target isEqualToString:@"matchRun_crash"]){//比赛跑步，崩溃进入
        CNMatchMainRecomeViewController* matchMainVC = [[CNMatchMainRecomeViewController alloc]init];
        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:matchMainVC];
        kApp.window.rootViewController = kApp.navigationController;
    }else if([target isEqualToString:@"finish"]){//结束比赛
        CNFinishViewController* finishVC = [[CNFinishViewController alloc]init];
        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:finishVC];
        kApp.window.rootViewController = kApp.navigationController;
    }else if([target isEqualToString:@"finishTeam"]){//结束整队比赛
        kApp.isbaton = 0;
        CNFinishTeamMatchViewController* finishVC = [[CNFinishTeamMatchViewController alloc]init];
        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:finishVC];
        kApp.window.rootViewController = kApp.navigationController;
    }
}
+ (void)saveMatchToRecord{
    //计算一下获得的积分：
    if(kApp.match_totaldis < 1000){
        kApp.match_score = 2;
    }else{
        int meter = (int)kApp.match_totaldis % 1000;
        if(meter > 500){
            kApp.match_score += 4;
        }
    }
    //计算点序列
    NSMutableString* pointString = [[NSMutableString alloc]initWithString:@""];
    for(int i=0;i<[kApp.match_pointList count];i++){
        CNGPSPoint4Match* point = [kApp.match_pointList objectAtIndex:i];
        [pointString appendString:[NSString stringWithFormat:@"%f %f,",point.lon,point.lat]];
    }
    if([pointString hasSuffix:@","]){
        [pointString setString:[pointString substringToIndex:([pointString length]-1)]];
    }
    RunClass * runClass  = [NSEntityDescription insertNewObjectForEntityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    runClass.rid = [NSString stringWithFormat:@"%lli",[CNUtil getNowTime]];
    runClass.runtar = [NSNumber numberWithInt:0];//自由
    runClass.runty = [NSNumber numberWithInt:1];//跑步
    runClass.runtra = pointString;
    runClass.mind = [NSNumber numberWithInt:0];
    runClass.runway = [NSNumber numberWithInt:0];
    runClass.distance = [NSNumber numberWithFloat:kApp.match_totaldis];
    runClass.utime = [NSNumber numberWithInt:kApp.match_historySecond];
    int speed_second = 1000*(kApp.match_historySecond/kApp.match_totaldis);
    runClass.pspeed = [NSNumber numberWithFloat:speed_second];
    runClass.ismatch = [NSNumber numberWithInt:1];
    CNGPSPoint4Match* firstPoint = [kApp.match_pointList objectAtIndex:0];
    long long stamp = firstPoint.time;
    runClass.stamp = [NSNumber numberWithLongLong:stamp];
    runClass.score = [NSNumber numberWithInt:kApp.match_score];
    
    NSError *error = nil;
    if (![kApp.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@", error);
        abort();
    }
    NSLog(@"add success");
    
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
    }
    double total_distance = [[record_dic objectForKey:@"total_distance"]doubleValue];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    int total_score = [[record_dic objectForKey:@"total_score"]intValue];
    total_distance += kApp.match_totaldis;
    total_count++;
    total_time += kApp.match_historySecond;
    total_score += kApp.match_score;
    [record_dic setObject:[NSString stringWithFormat:@"%f",total_distance] forKey:@"total_distance"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_count] forKey:@"total_count"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_time] forKey:@"total_time"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_score] forKey:@"total_score"];
    [record_dic writeToFile:filePath_record atomically:YES];
}

+ (void)saveRun{
    //存储到数据库
    RunClass * runClass  = [NSEntityDescription insertNewObjectForEntityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    runClass.rid = @"1411531117";
    runClass.runtar = [NSNumber numberWithInt:1];
    runClass.runty = [NSNumber numberWithInt:0];
    runClass.runtra = @"[{\"slon\":\"116096358\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"1411527691000\",\"orient\":\"342\",\"height\":\"494\",\"slat\":\"40507194\"},{\"slon\":\"-12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"0\",\"height\":\"494\",\"slat\":\"61\"},{\"slon\":\"-19\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"324\",\"height\":\"495\",\"slat\":\"44\"},{\"slon\":\"0\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"343\",\"height\":\"497\",\"slat\":\"48\"},{\"slon\":\"0\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"356\",\"height\":\"494\",\"slat\":\"45\"},{\"slon\":\"-2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"357\",\"height\":\"492\",\"slat\":\"62\"},{\"slon\":\"7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"26000\",\"orient\":\"341\",\"height\":\"493\",\"slat\":\"51\"},{\"slon\":\"37\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"324\",\"height\":\"498\",\"slat\":\"40\"},{\"slon\":\"-25\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"339\",\"height\":\"502\",\"slat\":\"56\"},{\"slon\":\"-58\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"301\",\"height\":\"501\",\"slat\":\"40\"},{\"slon\":\"11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"339\",\"height\":\"504\",\"slat\":\"53\"},{\"slon\":\"81\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"47\",\"height\":\"503\",\"slat\":\"26\"},{\"slon\":\"38\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"22\",\"height\":\"502\",\"slat\":\"36\"},{\"slon\":\"-13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"358\",\"height\":\"495\",\"slat\":\"48\"},{\"slon\":\"-4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"8\",\"height\":\"496\",\"slat\":\"62\"},{\"slon\":\"-33\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"351\",\"height\":\"493\",\"slat\":\"71\"},{\"slon\":\"-20\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"357\",\"height\":\"492\",\"slat\":\"72\"},{\"slon\":\"-22\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"351\",\"height\":\"492\",\"slat\":\"48\"},{\"slon\":\"-13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"360\",\"height\":\"492\",\"slat\":\"49\"},{\"slon\":\"-5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"347\",\"height\":\"491\",\"slat\":\"68\"},{\"slon\":\"-15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"8\",\"height\":\"494\",\"slat\":\"55\"},{\"slon\":\"9\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"352\",\"height\":\"495\",\"slat\":\"56\"},{\"slon\":\"2\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"12000\",\"orient\":\"351\",\"height\":\"494\",\"slat\":\"46\"},{\"slon\":\"-22\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"2000\",\"orient\":\"332\",\"height\":\"495\",\"slat\":\"70\"},{\"slon\":\"-28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"320\",\"height\":\"492\",\"slat\":\"53\"},{\"slon\":\"-63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"285\",\"height\":\"492\",\"slat\":\"41\"},{\"slon\":\"-14\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"12000\",\"orient\":\"11\",\"height\":\"493\",\"slat\":\"61\"},{\"slon\":\"-75\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"264\",\"height\":\"502\",\"slat\":\"-18\"},{\"slon\":\"-54\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"266\",\"height\":\"498\",\"slat\":\"-22\"},{\"slon\":\"57\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"34000\",\"orient\":\"52\",\"height\":\"492\",\"slat\":\"20\"},{\"slon\":\"-92\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"247\",\"height\":\"502\",\"slat\":\"-10\"},{\"slon\":\"-79\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"261\",\"height\":\"503\",\"slat\":\"-21\"},{\"slon\":\"-57\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"256\",\"height\":\"502\",\"slat\":\"-14\"},{\"slon\":\"-70\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"253\",\"height\":\"502\",\"slat\":\"-12\"},{\"slon\":\"-67\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"262\",\"height\":\"501\",\"slat\":\"-12\"},{\"slon\":\"-62\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"246\",\"height\":\"502\",\"slat\":\"-37\"},{\"slon\":\"-67\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"256\",\"height\":\"503\",\"slat\":\"-21\"},{\"slon\":\"-64\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"250\",\"height\":\"502\",\"slat\":\"-19\"},{\"slon\":\"-60\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"245\",\"height\":\"501\",\"slat\":\"-7\"},{\"slon\":\"-60\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"237\",\"height\":\"498\",\"slat\":\"-23\"},{\"slon\":\"-80\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"251\",\"height\":\"506\",\"slat\":\"-7\"},{\"slon\":\"-55\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"237\",\"height\":\"500\",\"slat\":\"-28\"},{\"slon\":\"-73\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"225\",\"height\":\"505\",\"slat\":\"-47\"},{\"slon\":\"-53\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"238\",\"height\":\"501\",\"slat\":\"-28\"},{\"slon\":\"-72\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"240\",\"height\":\"496\",\"slat\":\"-26\"},{\"slon\":\"-69\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"238\",\"height\":\"501\",\"slat\":\"-27\"},{\"slon\":\"-51\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"215\",\"height\":\"494\",\"slat\":\"-40\"},{\"slon\":\"-66\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"229\",\"height\":\"495\",\"slat\":\"-36\"},{\"slon\":\"-68\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"225\",\"height\":\"500\",\"slat\":\"-25\"},{\"slon\":\"-35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"213\",\"height\":\"500\",\"slat\":\"-53\"},{\"slon\":\"-52\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"217\",\"height\":\"504\",\"slat\":\"-44\"},{\"slon\":\"-53\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"207\",\"height\":\"502\",\"slat\":\"-52\"},{\"slon\":\"-63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"230\",\"height\":\"500\",\"slat\":\"-20\"},{\"slon\":\"-35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"18\",\"height\":\"495\",\"slat\":\"46\"},{\"slon\":\"15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"14\",\"height\":\"493\",\"slat\":\"59\"},{\"slon\":\"-5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"4\",\"height\":\"493\",\"slat\":\"55\"},{\"slon\":\"-23\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"316\",\"height\":\"493\",\"slat\":\"49\"},{\"slon\":\"-6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"7\",\"height\":\"493\",\"slat\":\"58\"},{\"slon\":\"42\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"50\",\"height\":\"489\",\"slat\":\"46\"},{\"slon\":\"27\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"25\",\"height\":\"487\",\"slat\":\"41\"},{\"slon\":\"26\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"14\",\"height\":\"485\",\"slat\":\"87\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"355\",\"height\":\"485\",\"slat\":\"83\"},{\"slon\":\"-12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"352\",\"height\":\"488\",\"slat\":\"71\"},{\"slon\":\"-6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"355\",\"height\":\"491\",\"slat\":\"56\"},{\"slon\":\"39\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"36\",\"height\":\"488\",\"slat\":\"47\"},{\"slon\":\"29\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"11\",\"height\":\"488\",\"slat\":\"41\"},{\"slon\":\"40\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"30\",\"height\":\"492\",\"slat\":\"36\"},{\"slon\":\"6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"354\",\"height\":\"492\",\"slat\":\"55\"},{\"slon\":\"6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"4\",\"height\":\"497\",\"slat\":\"65\"},{\"slon\":\"-12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"355\",\"height\":\"494\",\"slat\":\"59\"},{\"slon\":\"-13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"358\",\"height\":\"490\",\"slat\":\"54\"},{\"slon\":\"-27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"341\",\"height\":\"486\",\"slat\":\"43\"},{\"slon\":\"-13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"355\",\"height\":\"489\",\"slat\":\"49\"},{\"slon\":\"10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"4\",\"height\":\"487\",\"slat\":\"51\"},{\"slon\":\"4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"2\",\"height\":\"483\",\"slat\":\"45\"},{\"slon\":\"1\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"22000\",\"orient\":\"5\",\"height\":\"483\",\"slat\":\"64\"},{\"slon\":\"-78\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"263\",\"height\":\"495\",\"slat\":\"3\"},{\"slon\":\"-47\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"305\",\"height\":\"491\",\"slat\":\"31\"},{\"slon\":\"70\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"165\",\"height\":\"491\",\"slat\":\"-17\"},{\"slon\":\"86\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"166\",\"height\":\"486\",\"slat\":\"9\"},{\"slon\":\"-36\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"32000\",\"orient\":\"166\",\"height\":\"485\",\"slat\":\"38\"},{\"slon\":\"-28\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"16000\",\"orient\":\"166\",\"height\":\"491\",\"slat\":\"-46\"},{\"slon\":\"-92\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"166\",\"height\":\"488\",\"slat\":\"-9\"},{\"slon\":\"-59\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"166\",\"height\":\"484\",\"slat\":\"-4\"},{\"slon\":\"-76\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"166\",\"height\":\"484\",\"slat\":\"-24\"},{\"slon\":\"-82\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"166\",\"height\":\"484\",\"slat\":\"2\"},{\"slon\":\"-61\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"263\",\"height\":\"488\",\"slat\":\"-14\"},{\"slon\":\"-58\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"270\",\"height\":\"487\",\"slat\":\"-11\"},{\"slon\":\"-82\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"263\",\"height\":\"487\",\"slat\":\"-2\"},{\"slon\":\"-62\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"270\",\"height\":\"490\",\"slat\":\"-3\"},{\"slon\":\"-61\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"290\",\"height\":\"489\",\"slat\":\"4\"},{\"slon\":\"-72\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"266\",\"height\":\"494\",\"slat\":\"-11\"},{\"slon\":\"-60\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"268\",\"height\":\"492\",\"slat\":\"-13\"},{\"slon\":\"-66\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"278\",\"height\":\"495\",\"slat\":\"-8\"},{\"slon\":\"-59\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"243\",\"height\":\"498\",\"slat\":\"-23\"},{\"slon\":\"-61\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"244\",\"height\":\"499\",\"slat\":\"-26\"},{\"slon\":\"-73\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"263\",\"height\":\"503\",\"slat\":\"-11\"},{\"slon\":\"-71\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"281\",\"height\":\"500\",\"slat\":\"23\"},{\"slon\":\"-63\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"290\",\"height\":\"494\",\"slat\":\"38\"},{\"slon\":\"-79\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"266\",\"height\":\"494\",\"slat\":\"10\"},{\"slon\":\"-88\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"291\",\"height\":\"496\",\"slat\":\"2\"},{\"slon\":\"-71\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"289\",\"height\":\"496\",\"slat\":\"18\"},{\"slon\":\"-66\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"302\",\"height\":\"495\",\"slat\":\"24\"},{\"slon\":\"-54\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"312\",\"height\":\"495\",\"slat\":\"19\"},{\"slon\":\"-35\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"338\",\"height\":\"493\",\"slat\":\"37\"},{\"slon\":\"-25\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"347\",\"height\":\"494\",\"slat\":\"43\"},{\"slon\":\"4\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"356\",\"height\":\"496\",\"slat\":\"55\"},{\"slon\":\"20\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"23\",\"height\":\"497\",\"slat\":\"46\"},{\"slon\":\"-9\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"352\",\"height\":\"494\",\"slat\":\"50\"},{\"slon\":\"19\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"15\",\"height\":\"499\",\"slat\":\"46\"},{\"slon\":\"3\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"12000\",\"orient\":\"13\",\"height\":\"492\",\"slat\":\"60\"},{\"slon\":\"-18\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"320\",\"height\":\"490\",\"slat\":\"61\"},{\"slon\":\"-72\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"284\",\"height\":\"487\",\"slat\":\"44\"},{\"slon\":\"-70\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"275\",\"height\":\"490\",\"slat\":\"27\"},{\"slon\":\"-58\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"272\",\"height\":\"489\",\"slat\":\"23\"},{\"slon\":\"-66\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"266\",\"height\":\"489\",\"slat\":\"20\"},{\"slon\":\"-66\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"264\",\"height\":\"491\",\"slat\":\"-6\"},{\"slon\":\"-80\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"243\",\"height\":\"493\",\"slat\":\"-16\"},{\"slon\":\"-78\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"317\",\"height\":\"494\",\"slat\":\"18\"},{\"slon\":\"4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"21\",\"height\":\"497\",\"slat\":\"56\"},{\"slon\":\"16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"358\",\"height\":\"493\",\"slat\":\"55\"},{\"slon\":\"12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"14\",\"height\":\"495\",\"slat\":\"53\"},{\"slon\":\"6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"5\",\"height\":\"494\",\"slat\":\"53\"},{\"slon\":\"15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"7\",\"height\":\"492\",\"slat\":\"49\"},{\"slon\":\"13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"18\",\"height\":\"494\",\"slat\":\"44\"},{\"slon\":\"-36\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"312\",\"height\":\"494\",\"slat\":\"40\"},{\"slon\":\"17\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"13\",\"height\":\"490\",\"slat\":\"52\"},{\"slon\":\"-5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"2000\",\"orient\":\"335\",\"height\":\"493\",\"slat\":\"85\"},{\"slon\":\"-8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"348\",\"height\":\"492\",\"slat\":\"45\"},{\"slon\":\"10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"11\",\"height\":\"494\",\"slat\":\"62\"},{\"slon\":\"1\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"358\",\"height\":\"495\",\"slat\":\"70\"},{\"slon\":\"-15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"346\",\"height\":\"495\",\"slat\":\"51\"},{\"slon\":\"-16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"338\",\"height\":\"495\",\"slat\":\"56\"},{\"slon\":\"-16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"338\",\"height\":\"494\",\"slat\":\"51\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"349\",\"height\":\"494\",\"slat\":\"46\"},{\"slon\":\"-23\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"353\",\"height\":\"497\",\"slat\":\"57\"},{\"slon\":\"28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"5\",\"height\":\"494\",\"slat\":\"46\"},{\"slon\":\"10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"353\",\"height\":\"491\",\"slat\":\"52\"},{\"slon\":\"-31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"342\",\"height\":\"487\",\"slat\":\"39\"},{\"slon\":\"-56\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"332\",\"height\":\"490\",\"slat\":\"54\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"8\",\"height\":\"493\",\"slat\":\"54\"},{\"slon\":\"14\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"358\",\"height\":\"495\",\"slat\":\"49\"},{\"slon\":\"28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"3\",\"height\":\"489\",\"slat\":\"70\"},{\"slon\":\"-6\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"355\",\"height\":\"489\",\"slat\":\"63\"},{\"slon\":\"7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"0\",\"height\":\"488\",\"slat\":\"47\"},{\"slon\":\"-6\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"352\",\"height\":\"491\",\"slat\":\"46\"},{\"slon\":\"-22\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"351\",\"height\":\"489\",\"slat\":\"46\"},{\"slon\":\"-18\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"347\",\"height\":\"489\",\"slat\":\"57\"},{\"slon\":\"-10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"346\",\"height\":\"490\",\"slat\":\"59\"},{\"slon\":\"-4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"40000\",\"orient\":\"358\",\"height\":\"491\",\"slat\":\"59\"},{\"slon\":\"-27\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"275\",\"height\":\"493\",\"slat\":\"58\"},{\"slon\":\"0\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"359\",\"height\":\"495\",\"slat\":\"65\"},{\"slon\":\"-11\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"350\",\"height\":\"496\",\"slat\":\"62\"},{\"slon\":\"-23\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"346\",\"height\":\"494\",\"slat\":\"67\"},{\"slon\":\"-20\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"341\",\"height\":\"494\",\"slat\":\"43\"},{\"slon\":\"-10\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"342\",\"height\":\"494\",\"slat\":\"57\"},{\"slon\":\"-24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"326\",\"height\":\"489\",\"slat\":\"48\"},{\"slon\":\"-25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"344\",\"height\":\"492\",\"slat\":\"55\"},{\"slon\":\"-11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"346\",\"height\":\"492\",\"slat\":\"56\"},{\"slon\":\"-56\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"320\",\"height\":\"493\",\"slat\":\"51\"},{\"slon\":\"-32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"340\",\"height\":\"495\",\"slat\":\"47\"},{\"slon\":\"-63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"302\",\"height\":\"498\",\"slat\":\"35\"},{\"slon\":\"-77\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"289\",\"height\":\"498\",\"slat\":\"-13\"},{\"slon\":\"-74\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"273\",\"height\":\"499\",\"slat\":\"12\"},{\"slon\":\"-63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"291\",\"height\":\"500\",\"slat\":\"-1\"},{\"slon\":\"-71\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"293\",\"height\":\"500\",\"slat\":\"29\"},{\"slon\":\"-57\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"306\",\"height\":\"500\",\"slat\":\"30\"},{\"slon\":\"-74\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"78000\",\"orient\":\"297\",\"height\":\"500\",\"slat\":\"25\"},{\"slon\":\"-40\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"324\",\"height\":\"492\",\"slat\":\"45\"},{\"slon\":\"-79\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"303\",\"height\":\"493\",\"slat\":\"30\"},{\"slon\":\"-61\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"281\",\"height\":\"492\",\"slat\":\"4\"},{\"slon\":\"-57\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"294\",\"height\":\"491\",\"slat\":\"30\"},{\"slon\":\"-73\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"264\",\"height\":\"493\",\"slat\":\"-5\"},{\"slon\":\"-67\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"264\",\"height\":\"493\",\"slat\":\"-11\"},{\"slon\":\"-69\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"267\",\"height\":\"496\",\"slat\":\"-15\"},{\"slon\":\"-63\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"263\",\"height\":\"495\",\"slat\":\"-3\"},{\"slon\":\"-74\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"266\",\"height\":\"495\",\"slat\":\"5\"},{\"slon\":\"-75\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"260\",\"height\":\"497\",\"slat\":\"-6\"},{\"slon\":\"-79\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"18000\",\"orient\":\"265\",\"height\":\"493\",\"slat\":\"-17\"},{\"slon\":\"-61\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"195\",\"height\":\"491\",\"slat\":\"27\"},{\"slon\":\"-64\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"254\",\"height\":\"490\",\"slat\":\"-23\"},{\"slon\":\"-64\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"286\",\"height\":\"487\",\"slat\":\"-12\"},{\"slon\":\"-67\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"255\",\"height\":\"488\",\"slat\":\"20\"},{\"slon\":\"-85\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"278\",\"height\":\"486\",\"slat\":\"2\"},{\"slon\":\"-63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"283\",\"height\":\"487\",\"slat\":\"6\"},{\"slon\":\"-82\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"285\",\"height\":\"485\",\"slat\":\"8\"},{\"slon\":\"-48\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"225\",\"height\":\"486\",\"slat\":\"-27\"},{\"slon\":\"-28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"202\",\"height\":\"488\",\"slat\":\"-51\"},{\"slon\":\"2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"177\",\"height\":\"490\",\"slat\":\"-47\"},{\"slon\":\"5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"183\",\"height\":\"493\",\"slat\":\"-46\"},{\"slon\":\"7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"167\",\"height\":\"495\",\"slat\":\"-46\"},{\"slon\":\"38\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"139\",\"height\":\"497\",\"slat\":\"-35\"},{\"slon\":\"54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"138\",\"height\":\"500\",\"slat\":\"-46\"},{\"slon\":\"56\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"126\",\"height\":\"501\",\"slat\":\"-48\"},{\"slon\":\"52\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"128\",\"height\":\"502\",\"slat\":\"-42\"},{\"slon\":\"62\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"116\",\"height\":\"499\",\"slat\":\"-26\"},{\"slon\":\"67\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"116\",\"height\":\"497\",\"slat\":\"-22\"},{\"slon\":\"51\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"125\",\"height\":\"497\",\"slat\":\"-27\"},{\"slon\":\"67\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"118\",\"height\":\"499\",\"slat\":\"-28\"},{\"slon\":\"61\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"125\",\"height\":\"496\",\"slat\":\"-38\"},{\"slon\":\"60\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"104\",\"height\":\"495\",\"slat\":\"-33\"},{\"slon\":\"56\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"129\",\"height\":\"495\",\"slat\":\"-21\"},{\"slon\":\"46\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"126\",\"height\":\"496\",\"slat\":\"-35\"},{\"slon\":\"32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"157\",\"height\":\"499\",\"slat\":\"-45\"},{\"slon\":\"18\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"152\",\"height\":\"497\",\"slat\":\"-53\"},{\"slon\":\"22\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"164\",\"height\":\"498\",\"slat\":\"-45\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"151\",\"height\":\"499\",\"slat\":\"-52\"},{\"slon\":\"58\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"150\",\"height\":\"499\",\"slat\":\"-51\"},{\"slon\":\"31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"145\",\"height\":\"499\",\"slat\":\"-49\"},{\"slon\":\"38\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"166\",\"height\":\"504\",\"slat\":\"-35\"},{\"slon\":\"-10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"190\",\"height\":\"504\",\"slat\":\"-48\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"12000\",\"orient\":\"169\",\"height\":\"505\",\"slat\":\"-45\"},{\"slon\":\"29\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"169\",\"height\":\"500\",\"slat\":\"-62\"},{\"slon\":\"32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"165\",\"height\":\"502\",\"slat\":\"-49\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"164\",\"height\":\"502\",\"slat\":\"-58\"},{\"slon\":\"11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"164\",\"height\":\"501\",\"slat\":\"-48\"},{\"slon\":\"44\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"146\",\"height\":\"501\",\"slat\":\"-48\"},{\"slon\":\"14\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"151\",\"height\":\"497\",\"slat\":\"-57\"},{\"slon\":\"20\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"148\",\"height\":\"497\",\"slat\":\"-51\"},{\"slon\":\"16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"160\",\"height\":\"494\",\"slat\":\"-48\"},{\"slon\":\"23\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"151\",\"height\":\"494\",\"slat\":\"-52\"},{\"slon\":\"33\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"154\",\"height\":\"493\",\"slat\":\"-54\"},{\"slon\":\"2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"161\",\"height\":\"491\",\"slat\":\"-50\"},{\"slon\":\"28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"156\",\"height\":\"493\",\"slat\":\"-58\"},{\"slon\":\"-8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"182\",\"height\":\"495\",\"slat\":\"-59\"},{\"slon\":\"-11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"180\",\"height\":\"494\",\"slat\":\"-51\"},{\"slon\":\"22\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"160\",\"height\":\"498\",\"slat\":\"-51\"},{\"slon\":\"21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"165\",\"height\":\"497\",\"slat\":\"-47\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"159\",\"height\":\"498\",\"slat\":\"-47\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"180\",\"height\":\"499\",\"slat\":\"-67\"},{\"slon\":\"-6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"178\",\"height\":\"497\",\"slat\":\"-54\"},{\"slon\":\"27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"161\",\"height\":\"496\",\"slat\":\"-67\"},{\"slon\":\"36\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"138\",\"height\":\"495\",\"slat\":\"-37\"},{\"slon\":\"19\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"188\",\"height\":\"494\",\"slat\":\"-55\"},{\"slon\":\"9\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"166\",\"height\":\"495\",\"slat\":\"-61\"},{\"slon\":\"-42\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"200\",\"height\":\"498\",\"slat\":\"-47\"},{\"slon\":\"-27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"193\",\"height\":\"499\",\"slat\":\"-51\"},{\"slon\":\"-7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"193\",\"height\":\"500\",\"slat\":\"-55\"},{\"slon\":\"20\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"167\",\"height\":\"502\",\"slat\":\"-62\"},{\"slon\":\"-9\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"183\",\"height\":\"502\",\"slat\":\"-58\"},{\"slon\":\"-10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"209\",\"height\":\"503\",\"slat\":\"-48\"},{\"slon\":\"-81\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"240\",\"height\":\"497\",\"slat\":\"-24\"},{\"slon\":\"-52\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"220\",\"height\":\"500\",\"slat\":\"-35\"},{\"slon\":\"22\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"198\",\"height\":\"503\",\"slat\":\"-54\"},{\"slon\":\"-55\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"232\",\"height\":\"498\",\"slat\":\"-19\"},{\"slon\":\"-54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"217\",\"height\":\"501\",\"slat\":\"-42\"},{\"slon\":\"-27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"215\",\"height\":\"501\",\"slat\":\"-53\"},{\"slon\":\"-30\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"226\",\"height\":\"499\",\"slat\":\"-41\"},{\"slon\":\"-51\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"234\",\"height\":\"500\",\"slat\":\"-30\"},{\"slon\":\"-54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"225\",\"height\":\"497\",\"slat\":\"-37\"},{\"slon\":\"-55\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"226\",\"height\":\"500\",\"slat\":\"-43\"},{\"slon\":\"-56\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"202\",\"height\":\"498\",\"slat\":\"-43\"},{\"slon\":\"-2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"199\",\"height\":\"496\",\"slat\":\"-47\"},{\"slon\":\"-61\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"235\",\"height\":\"497\",\"slat\":\"0\"},{\"slon\":\"-66\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"221\",\"height\":\"500\",\"slat\":\"-31\"},{\"slon\":\"-44\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"209\",\"height\":\"505\",\"slat\":\"-52\"},{\"slon\":\"-72\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"242\",\"height\":\"503\",\"slat\":\"-48\"},{\"slon\":\"-31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"220\",\"height\":\"508\",\"slat\":\"-44\"},{\"slon\":\"-45\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"226\",\"height\":\"512\",\"slat\":\"-45\"},{\"slon\":\"-65\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"244\",\"height\":\"517\",\"slat\":\"-25\"},{\"slon\":\"-55\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"228\",\"height\":\"513\",\"slat\":\"-33\"},{\"slon\":\"-19\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"207\",\"height\":\"509\",\"slat\":\"-50\"},{\"slon\":\"-33\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"207\",\"height\":\"506\",\"slat\":\"-38\"},{\"slon\":\"-21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"229\",\"height\":\"507\",\"slat\":\"-50\"},{\"slon\":\"-15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"180\",\"height\":\"505\",\"slat\":\"-56\"},{\"slon\":\"-20\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"197\",\"height\":\"502\",\"slat\":\"-55\"},{\"slon\":\"-60\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"194\",\"height\":\"498\",\"slat\":\"-44\"},{\"slon\":\"-6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"170\",\"height\":\"496\",\"slat\":\"-46\"},{\"slon\":\"-25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"175\",\"height\":\"490\",\"slat\":\"-48\"},{\"slon\":\"8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"166\",\"height\":\"490\",\"slat\":\"-50\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"179\",\"height\":\"491\",\"slat\":\"-58\"},{\"slon\":\"20\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"121\",\"height\":\"491\",\"slat\":\"-52\"},{\"slon\":\"26\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"168\",\"height\":\"490\",\"slat\":\"-45\"},{\"slon\":\"-5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"180\",\"height\":\"490\",\"slat\":\"-49\"},{\"slon\":\"-74\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"12000\",\"orient\":\"209\",\"height\":\"492\",\"slat\":\"-60\"},{\"slon\":\"-28\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"209\",\"height\":\"494\",\"slat\":\"-46\"},{\"slon\":\"-10\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"185\",\"height\":\"491\",\"slat\":\"-61\"},{\"slon\":\"-5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"165\",\"height\":\"488\",\"slat\":\"-51\"},{\"slon\":\"-8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"193\",\"height\":\"490\",\"slat\":\"-49\"},{\"slon\":\"-6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"16000\",\"orient\":\"192\",\"height\":\"492\",\"slat\":\"-52\"},{\"slon\":\"-32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"203\",\"height\":\"496\",\"slat\":\"-44\"},{\"slon\":\"3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"189\",\"height\":\"500\",\"slat\":\"-55\"},{\"slon\":\"-12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"198\",\"height\":\"498\",\"slat\":\"-63\"},{\"slon\":\"-47\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"196\",\"height\":\"502\",\"slat\":\"-55\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"177\",\"height\":\"499\",\"slat\":\"-45\"},{\"slon\":\"7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"182\",\"height\":\"495\",\"slat\":\"-62\"},{\"slon\":\"3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"181\",\"height\":\"495\",\"slat\":\"-47\"},{\"slon\":\"-1\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"186\",\"height\":\"496\",\"slat\":\"-56\"},{\"slon\":\"2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"181\",\"height\":\"496\",\"slat\":\"-83\"},{\"slon\":\"16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"180\",\"height\":\"499\",\"slat\":\"-53\"},{\"slon\":\"28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"162\",\"height\":\"501\",\"slat\":\"-50\"},{\"slon\":\"44\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"155\",\"height\":\"506\",\"slat\":\"-36\"},{\"slon\":\"15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"172\",\"height\":\"506\",\"slat\":\"-46\"},{\"slon\":\"14\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"159\",\"height\":\"509\",\"slat\":\"-57\"},{\"slon\":\"52\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"157\",\"height\":\"513\",\"slat\":\"-68\"},{\"slon\":\"33\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"159\",\"height\":\"512\",\"slat\":\"-60\"},{\"slon\":\"21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"151\",\"height\":\"510\",\"slat\":\"-45\"},{\"slon\":\"11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"159\",\"height\":\"506\",\"slat\":\"-58\"},{\"slon\":\"27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"151\",\"height\":\"506\",\"slat\":\"-50\"},{\"slon\":\"60\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"130\",\"height\":\"503\",\"slat\":\"-38\"},{\"slon\":\"49\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"131\",\"height\":\"501\",\"slat\":\"-31\"},{\"slon\":\"51\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"141\",\"height\":\"501\",\"slat\":\"-36\"},{\"slon\":\"35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"152\",\"height\":\"502\",\"slat\":\"-56\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"157\",\"height\":\"504\",\"slat\":\"-57\"},{\"slon\":\"-26\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"189\",\"height\":\"506\",\"slat\":\"-53\"},{\"slon\":\"19\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"173\",\"height\":\"508\",\"slat\":\"-67\"},{\"slon\":\"30\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"155\",\"height\":\"502\",\"slat\":\"-44\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"163\",\"height\":\"499\",\"slat\":\"-53\"},{\"slon\":\"32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"166\",\"height\":\"502\",\"slat\":\"-43\"},{\"slon\":\"31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"168\",\"height\":\"500\",\"slat\":\"-42\"},{\"slon\":\"24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"159\",\"height\":\"497\",\"slat\":\"-47\"},{\"slon\":\"29\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"165\",\"height\":\"495\",\"slat\":\"-45\"},{\"slon\":\"16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"155\",\"height\":\"495\",\"slat\":\"-60\"},{\"slon\":\"41\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"142\",\"height\":\"497\",\"slat\":\"-37\"},{\"slon\":\"45\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"159\",\"height\":\"496\",\"slat\":\"-37\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"154\",\"height\":\"498\",\"slat\":\"-61\"},{\"slon\":\"3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"176\",\"height\":\"496\",\"slat\":\"-51\"},{\"slon\":\"11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"166\",\"height\":\"495\",\"slat\":\"-57\"},{\"slon\":\"10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"174\",\"height\":\"494\",\"slat\":\"-63\"},{\"slon\":\"-17\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"178\",\"height\":\"493\",\"slat\":\"-60\"},{\"slon\":\"35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"120\",\"height\":\"489\",\"slat\":\"-38\"},{\"slon\":\"70\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"103\",\"height\":\"484\",\"slat\":\"10\"},{\"slon\":\"79\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"66\",\"height\":\"485\",\"slat\":\"-1\"},{\"slon\":\"48\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"161\",\"height\":\"488\",\"slat\":\"-51\"},{\"slon\":\"34\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"167\",\"height\":\"490\",\"slat\":\"-45\"},{\"slon\":\"31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"169\",\"height\":\"490\",\"slat\":\"-56\"},{\"slon\":\"24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"169\",\"height\":\"490\",\"slat\":\"-57\"},{\"slon\":\"21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"168\",\"height\":\"491\",\"slat\":\"-43\"},{\"slon\":\"24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"168\",\"height\":\"491\",\"slat\":\"-53\"},{\"slon\":\"14\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"168\",\"height\":\"491\",\"slat\":\"-58\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"164\",\"height\":\"493\",\"slat\":\"-58\"},{\"slon\":\"11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"169\",\"height\":\"492\",\"slat\":\"-56\"},{\"slon\":\"11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"181\",\"height\":\"494\",\"slat\":\"-56\"},{\"slon\":\"27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"155\",\"height\":\"494\",\"slat\":\"-58\"},{\"slon\":\"16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"180\",\"height\":\"489\",\"slat\":\"-65\"},{\"slon\":\"15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"162\",\"height\":\"492\",\"slat\":\"-67\"},{\"slon\":\"0\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"182\",\"height\":\"493\",\"slat\":\"-47\"},{\"slon\":\"29\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"156\",\"height\":\"494\",\"slat\":\"-40\"},{\"slon\":\"42\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"166\",\"height\":\"496\",\"slat\":\"-48\"},{\"slon\":\"8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"170\",\"height\":\"496\",\"slat\":\"-60\"},{\"slon\":\"-13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"181\",\"height\":\"496\",\"slat\":\"-57\"},{\"slon\":\"8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"174\",\"height\":\"502\",\"slat\":\"-61\"},{\"slon\":\"8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"174\",\"height\":\"504\",\"slat\":\"-48\"},{\"slon\":\"35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"170\",\"height\":\"502\",\"slat\":\"-67\"},{\"slon\":\"-2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"170\",\"height\":\"503\",\"slat\":\"-63\"},{\"slon\":\"24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"14000\",\"orient\":\"148\",\"height\":\"499\",\"slat\":\"-60\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"164\",\"height\":\"491\",\"slat\":\"-65\"},{\"slon\":\"48\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"148\",\"height\":\"490\",\"slat\":\"-57\"},{\"slon\":\"17\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"175\",\"height\":\"490\",\"slat\":\"-49\"},{\"slon\":\"12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"173\",\"height\":\"487\",\"slat\":\"-55\"},{\"slon\":\"37\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"162\",\"height\":\"490\",\"slat\":\"-51\"},{\"slon\":\"21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"161\",\"height\":\"491\",\"slat\":\"-47\"},{\"slon\":\"19\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"157\",\"height\":\"489\",\"slat\":\"-55\"},{\"slon\":\"-21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"197\",\"height\":\"493\",\"slat\":\"-55\"},{\"slon\":\"35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"164\",\"height\":\"493\",\"slat\":\"-62\"},{\"slon\":\"12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"174\",\"height\":\"493\",\"slat\":\"-55\"},{\"slon\":\"21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"160\",\"height\":\"493\",\"slat\":\"-55\"},{\"slon\":\"24\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"16000\",\"orient\":\"142\",\"height\":\"495\",\"slat\":\"-44\"},{\"slon\":\"79\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"91\",\"height\":\"489\",\"slat\":\"-2\"},{\"slon\":\"71\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"108\",\"height\":\"490\",\"slat\":\"-25\"},{\"slon\":\"71\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"92\",\"height\":\"491\",\"slat\":\"-25\"},{\"slon\":\"70\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"91\",\"height\":\"491\",\"slat\":\"-8\"},{\"slon\":\"75\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"95\",\"height\":\"491\",\"slat\":\"-8\"},{\"slon\":\"69\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"94\",\"height\":\"489\",\"slat\":\"-18\"},{\"slon\":\"69\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"96\",\"height\":\"489\",\"slat\":\"12\"},{\"slon\":\"78\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"92\",\"height\":\"492\",\"slat\":\"1\"},{\"slon\":\"44\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"68\",\"height\":\"492\",\"slat\":\"35\"},{\"slon\":\"15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"17\",\"height\":\"488\",\"slat\":\"47\"},{\"slon\":\"23\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"35\",\"height\":\"488\",\"slat\":\"42\"},{\"slon\":\"48\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"12000\",\"orient\":\"27\",\"height\":\"490\",\"slat\":\"45\"},{\"slon\":\"22\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"12000\",\"orient\":\"9\",\"height\":\"492\",\"slat\":\"47\"},{\"slon\":\"58\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"82\",\"height\":\"491\",\"slat\":\"21\"},{\"slon\":\"57\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"63\",\"height\":\"492\",\"slat\":\"23\"},{\"slon\":\"61\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"76\",\"height\":\"491\",\"slat\":\"31\"},{\"slon\":\"65\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"72\",\"height\":\"489\",\"slat\":\"26\"},{\"slon\":\"65\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"62\",\"height\":\"489\",\"slat\":\"9\"},{\"slon\":\"48\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"32\",\"height\":\"490\",\"slat\":\"41\"},{\"slon\":\"22\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"21\",\"height\":\"490\",\"slat\":\"61\"},{\"slon\":\"19\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"14\",\"height\":\"490\",\"slat\":\"51\"},{\"slon\":\"53\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"45\",\"height\":\"490\",\"slat\":\"43\"},{\"slon\":\"2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"18\",\"height\":\"487\",\"slat\":\"62\"},{\"slon\":\"-8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"16\",\"height\":\"490\",\"slat\":\"48\"},{\"slon\":\"23\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"25\",\"height\":\"493\",\"slat\":\"56\"},{\"slon\":\"33\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"23\",\"height\":\"489\",\"slat\":\"48\"},{\"slon\":\"62\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"27\",\"height\":\"492\",\"slat\":\"37\"},{\"slon\":\"33\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"13\",\"height\":\"490\",\"slat\":\"48\"},{\"slon\":\"-5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"358\",\"height\":\"484\",\"slat\":\"47\"},{\"slon\":\"14\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"15\",\"height\":\"485\",\"slat\":\"62\"},{\"slon\":\"34\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"17\",\"height\":\"487\",\"slat\":\"57\"},{\"slon\":\"26\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"18\",\"height\":\"490\",\"slat\":\"48\"},{\"slon\":\"17\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"13\",\"height\":\"495\",\"slat\":\"53\"},{\"slon\":\"31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"31\",\"height\":\"494\",\"slat\":\"40\"},{\"slon\":\"36\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"30\",\"height\":\"496\",\"slat\":\"39\"},{\"slon\":\"24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"28\",\"height\":\"497\",\"slat\":\"51\"},{\"slon\":\"47\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"28\",\"height\":\"498\",\"slat\":\"37\"},{\"slon\":\"44\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"31\",\"height\":\"497\",\"slat\":\"43\"},{\"slon\":\"27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"33\",\"height\":\"496\",\"slat\":\"42\"},{\"slon\":\"53\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"34\",\"height\":\"498\",\"slat\":\"48\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"19\",\"height\":\"497\",\"slat\":\"47\"},{\"slon\":\"27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"23\",\"height\":\"494\",\"slat\":\"62\"},{\"slon\":\"46\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"30\",\"height\":\"496\",\"slat\":\"51\"},{\"slon\":\"34\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"23\",\"height\":\"492\",\"slat\":\"45\"},{\"slon\":\"71\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"51\",\"height\":\"496\",\"slat\":\"39\"},{\"slon\":\"32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"36\",\"height\":\"494\",\"slat\":\"56\"},{\"slon\":\"38\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"34\",\"height\":\"493\",\"slat\":\"40\"},{\"slon\":\"58\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"34\",\"height\":\"492\",\"slat\":\"49\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"16\",\"height\":\"492\",\"slat\":\"49\"},{\"slon\":\"26\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"20\",\"height\":\"492\",\"slat\":\"43\"},{\"slon\":\"75\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"32\",\"height\":\"493\",\"slat\":\"30\"},{\"slon\":\"4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"6\",\"height\":\"488\",\"slat\":\"55\"},{\"slon\":\"-37\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"355\",\"height\":\"487\",\"slat\":\"71\"},{\"slon\":\"-12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"354\",\"height\":\"488\",\"slat\":\"53\"},{\"slon\":\"59\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"14000\",\"orient\":\"113\",\"height\":\"487\",\"slat\":\"-26\"},{\"slon\":\"19\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"348\",\"height\":\"485\",\"slat\":\"55\"},{\"slon\":\"-16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"351\",\"height\":\"487\",\"slat\":\"59\"},{\"slon\":\"-17\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"10000\",\"orient\":\"352\",\"height\":\"490\",\"slat\":\"56\"},{\"slon\":\"33\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"354\",\"height\":\"498\",\"slat\":\"40\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"9\",\"height\":\"502\",\"slat\":\"51\"},{\"slon\":\"-24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"351\",\"height\":\"502\",\"slat\":\"56\"},{\"slon\":\"-35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"338\",\"height\":\"499\",\"slat\":\"60\"},{\"slon\":\"-29\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"351\",\"height\":\"499\",\"slat\":\"63\"},{\"slon\":\"-19\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"348\",\"height\":\"498\",\"slat\":\"50\"},{\"slon\":\"-38\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"329\",\"height\":\"497\",\"slat\":\"41\"},{\"slon\":\"-48\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"320\",\"height\":\"497\",\"slat\":\"42\"},{\"slon\":\"-42\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"340\",\"height\":\"492\",\"slat\":\"66\"},{\"slon\":\"-28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"333\",\"height\":\"493\",\"slat\":\"41\"},{\"slon\":\"-25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"348\",\"height\":\"493\",\"slat\":\"48\"},{\"slon\":\"12\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"351\",\"height\":\"494\",\"slat\":\"47\"},{\"slon\":\"-4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"350\",\"height\":\"488\",\"slat\":\"53\"},{\"slon\":\"24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"19\",\"height\":\"489\",\"slat\":\"58\"},{\"slon\":\"29\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"151\",\"height\":\"489\",\"slat\":\"-39\"},{\"slon\":\"36\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"16000\",\"orient\":\"148\",\"height\":\"492\",\"slat\":\"-36\"},{\"slon\":\"33\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"60\",\"height\":\"494\",\"slat\":\"52\"},{\"slon\":\"49\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"2000\",\"orient\":\"19\",\"height\":\"488\",\"slat\":\"62\"},{\"slon\":\"26\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"25\",\"height\":\"487\",\"slat\":\"42\"},{\"slon\":\"50\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"61\",\"height\":\"489\",\"slat\":\"29\"},{\"slon\":\"59\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"82\",\"height\":\"487\",\"slat\":\"7\"},{\"slon\":\"46\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"75\",\"height\":\"489\",\"slat\":\"28\"},{\"slon\":\"30\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"28\",\"height\":\"493\",\"slat\":\"70\"},{\"slon\":\"-1\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"8\",\"height\":\"493\",\"slat\":\"52\"},{\"slon\":\"-5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"11\",\"height\":\"494\",\"slat\":\"68\"},{\"slon\":\"-30\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"342\",\"height\":\"496\",\"slat\":\"50\"},{\"slon\":\"39\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"35\",\"height\":\"492\",\"slat\":\"53\"},{\"slon\":\"84\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"69\",\"height\":\"492\",\"slat\":\"-1\"},{\"slon\":\"43\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"61\",\"height\":\"493\",\"slat\":\"36\"},{\"slon\":\"80\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"106\",\"height\":\"492\",\"slat\":\"-15\"},{\"slon\":\"63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"115\",\"height\":\"490\",\"slat\":\"-22\"},{\"slon\":\"6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"156\",\"height\":\"489\",\"slat\":\"-53\"},{\"slon\":\"6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"177\",\"height\":\"493\",\"slat\":\"-53\"},{\"slon\":\"2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"172\",\"height\":\"493\",\"slat\":\"-48\"},{\"slon\":\"0\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"188\",\"height\":\"493\",\"slat\":\"-64\"},{\"slon\":\"-23\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"191\",\"height\":\"492\",\"slat\":\"-47\"},{\"slon\":\"7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"194\",\"height\":\"492\",\"slat\":\"-67\"},{\"slon\":\"-8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"184\",\"height\":\"494\",\"slat\":\"-55\"},{\"slon\":\"-4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"186\",\"height\":\"490\",\"slat\":\"-60\"},{\"slon\":\"6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"181\",\"height\":\"495\",\"slat\":\"-57\"},{\"slon\":\"-7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"197\",\"height\":\"492\",\"slat\":\"-45\"},{\"slon\":\"-21\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"192\",\"height\":\"490\",\"slat\":\"-45\"},{\"slon\":\"-4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"186\",\"height\":\"489\",\"slat\":\"-60\"},{\"slon\":\"27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"161\",\"height\":\"494\",\"slat\":\"-49\"},{\"slon\":\"18\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"178\",\"height\":\"497\",\"slat\":\"-59\"},{\"slon\":\"-2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"199\",\"height\":\"493\",\"slat\":\"-54\"},{\"slon\":\"-17\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"190\",\"height\":\"495\",\"slat\":\"-48\"},{\"slon\":\"-10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"202\",\"height\":\"496\",\"slat\":\"-60\"},{\"slon\":\"2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"174\",\"height\":\"497\",\"slat\":\"-53\"},{\"slon\":\"2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"175\",\"height\":\"498\",\"slat\":\"-54\"},{\"slon\":\"-26\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"201\",\"height\":\"498\",\"slat\":\"-45\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"188\",\"height\":\"496\",\"slat\":\"-58\"},{\"slon\":\"-44\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"243\",\"height\":\"497\",\"slat\":\"-39\"},{\"slon\":\"-22\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"212\",\"height\":\"496\",\"slat\":\"-42\"},{\"slon\":\"-46\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"261\",\"height\":\"490\",\"slat\":\"-34\"},{\"slon\":\"-16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"217\",\"height\":\"487\",\"slat\":\"-60\"},{\"slon\":\"-15\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"221\",\"height\":\"490\",\"slat\":\"-54\"},{\"slon\":\"-20\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"215\",\"height\":\"493\",\"slat\":\"-52\"},{\"slon\":\"-22\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"225\",\"height\":\"491\",\"slat\":\"-52\"},{\"slon\":\"-38\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"218\",\"height\":\"491\",\"slat\":\"-35\"},{\"slon\":\"7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"194\",\"height\":\"494\",\"slat\":\"-54\"},{\"slon\":\"-39\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"208\",\"height\":\"492\",\"slat\":\"-69\"},{\"slon\":\"5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"178\",\"height\":\"498\",\"slat\":\"-63\"},{\"slon\":\"-35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"204\",\"height\":\"499\",\"slat\":\"-46\"},{\"slon\":\"-11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"180\",\"height\":\"503\",\"slat\":\"-64\"},{\"slon\":\"-20\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"194\",\"height\":\"503\",\"slat\":\"-60\"},{\"slon\":\"-66\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"239\",\"height\":\"502\",\"slat\":\"-21\"},{\"slon\":\"-7\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"199\",\"height\":\"506\",\"slat\":\"-62\"},{\"slon\":\"1\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"192\",\"height\":\"504\",\"slat\":\"-58\"},{\"slon\":\"-11\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"188\",\"height\":\"501\",\"slat\":\"-56\"},{\"slon\":\"-18\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"194\",\"height\":\"500\",\"slat\":\"-50\"},{\"slon\":\"-31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"196\",\"height\":\"501\",\"slat\":\"-63\"},{\"slon\":\"-77\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"240\",\"height\":\"496\",\"slat\":\"-10\"},{\"slon\":\"-32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"217\",\"height\":\"498\",\"slat\":\"-51\"},{\"slon\":\"-16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"204\",\"height\":\"500\",\"slat\":\"-54\"},{\"slon\":\"-23\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"215\",\"height\":\"495\",\"slat\":\"-46\"},{\"slon\":\"16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"181\",\"height\":\"497\",\"slat\":\"-63\"},{\"slon\":\"1\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"2000\",\"orient\":\"189\",\"height\":\"503\",\"slat\":\"-69\"},{\"slon\":\"28\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"176\",\"height\":\"500\",\"slat\":\"-50\"},{\"slon\":\"29\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"174\",\"height\":\"501\",\"slat\":\"-95\"},{\"slon\":\"27\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"162\",\"height\":\"502\",\"slat\":\"-55\"},{\"slon\":\"58\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"122\",\"height\":\"498\",\"slat\":\"-17\"},{\"slon\":\"72\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"112\",\"height\":\"500\",\"slat\":\"-10\"},{\"slon\":\"69\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"102\",\"height\":\"498\",\"slat\":\"-5\"},{\"slon\":\"74\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"89\",\"height\":\"489\",\"slat\":\"-3\"},{\"slon\":\"67\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"94\",\"height\":\"493\",\"slat\":\"-20\"},{\"slon\":\"92\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"88\",\"height\":\"493\",\"slat\":\"-20\"},{\"slon\":\"63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"80\",\"height\":\"492\",\"slat\":\"2\"},{\"slon\":\"35\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"3\",\"height\":\"494\",\"slat\":\"37\"},{\"slon\":\"-25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"2\",\"height\":\"497\",\"slat\":\"44\"},{\"slon\":\"79\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"95\",\"height\":\"498\",\"slat\":\"-4\"},{\"slon\":\"57\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"97\",\"height\":\"496\",\"slat\":\"-22\"},{\"slon\":\"78\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"63\",\"height\":\"493\",\"slat\":\"23\"},{\"slon\":\"64\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"64\",\"height\":\"493\",\"slat\":\"17\"},{\"slon\":\"50\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"52\",\"height\":\"488\",\"slat\":\"36\"},{\"slon\":\"72\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"56\",\"height\":\"495\",\"slat\":\"-5\"},{\"slon\":\"57\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"55\",\"height\":\"495\",\"slat\":\"42\"},{\"slon\":\"86\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"68\",\"height\":\"496\",\"slat\":\"8\"},{\"slon\":\"76\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"59\",\"height\":\"499\",\"slat\":\"35\"},{\"slon\":\"43\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"55\",\"height\":\"499\",\"slat\":\"31\"},{\"slon\":\"54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"44\",\"height\":\"500\",\"slat\":\"25\"},{\"slon\":\"54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"68\",\"height\":\"500\",\"slat\":\"32\"},{\"slon\":\"83\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"81\",\"height\":\"505\",\"slat\":\"12\"},{\"slon\":\"54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"45\",\"height\":\"506\",\"slat\":\"19\"},{\"slon\":\"46\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"50\",\"height\":\"502\",\"slat\":\"52\"},{\"slon\":\"48\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"46\",\"height\":\"502\",\"slat\":\"44\"},{\"slon\":\"65\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"53\",\"height\":\"504\",\"slat\":\"24\"},{\"slon\":\"69\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"73\",\"height\":\"507\",\"slat\":\"-6\"},{\"slon\":\"63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"78\",\"height\":\"508\",\"slat\":\"6\"},{\"slon\":\"54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"54\",\"height\":\"505\",\"slat\":\"40\"},{\"slon\":\"42\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"68\",\"height\":\"506\",\"slat\":\"31\"},{\"slon\":\"48\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"24000\",\"orient\":\"75\",\"height\":\"505\",\"slat\":\"30\"},{\"slon\":\"38\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"57\",\"height\":\"505\",\"slat\":\"43\"},{\"slon\":\"53\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"61\",\"height\":\"501\",\"slat\":\"34\"},{\"slon\":\"40\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"48\",\"height\":\"501\",\"slat\":\"35\"},{\"slon\":\"71\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"73\",\"height\":\"502\",\"slat\":\"18\"},{\"slon\":\"59\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"76\",\"height\":\"502\",\"slat\":\"5\"},{\"slon\":\"67\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"61\",\"height\":\"500\",\"slat\":\"19\"},{\"slon\":\"40\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"40\",\"height\":\"498\",\"slat\":\"34\"},{\"slon\":\"71\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"57\",\"height\":\"500\",\"slat\":\"37\"},{\"slon\":\"41\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"15\",\"height\":\"498\",\"slat\":\"46\"},{\"slon\":\"-4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"13\",\"height\":\"502\",\"slat\":\"56\"},{\"slon\":\"-17\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"358\",\"height\":\"502\",\"slat\":\"82\"},{\"slon\":\"-6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"345\",\"height\":\"504\",\"slat\":\"75\"},{\"slon\":\"16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"6\",\"height\":\"499\",\"slat\":\"58\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"8\",\"height\":\"501\",\"slat\":\"46\"},{\"slon\":\"13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"2\",\"height\":\"502\",\"slat\":\"54\"},{\"slon\":\"-2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"0\",\"height\":\"502\",\"slat\":\"64\"},{\"slon\":\"-31\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"0\",\"height\":\"501\",\"slat\":\"79\"},{\"slon\":\"-13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"351\",\"height\":\"502\",\"slat\":\"68\"},{\"slon\":\"8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"7\",\"height\":\"502\",\"slat\":\"62\"},{\"slon\":\"-4\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"351\",\"height\":\"500\",\"slat\":\"47\"},{\"slon\":\"-2\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"358\",\"height\":\"503\",\"slat\":\"48\"},{\"slon\":\"-8\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"352\",\"height\":\"504\",\"slat\":\"46\"},{\"slon\":\"0\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"354\",\"height\":\"501\",\"slat\":\"61\"},{\"slon\":\"-85\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"291\",\"height\":\"501\",\"slat\":\"8\"},{\"slon\":\"-81\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"299\",\"height\":\"505\",\"slat\":\"17\"},{\"slon\":\"-54\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"307\",\"height\":\"506\",\"slat\":\"27\"},{\"slon\":\"-59\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"323\",\"height\":\"503\",\"slat\":\"37\"},{\"slon\":\"-24\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"330\",\"height\":\"506\",\"slat\":\"44\"},{\"slon\":\"-16\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"8\",\"height\":\"502\",\"slat\":\"53\"},{\"slon\":\"3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"7\",\"height\":\"509\",\"slat\":\"56\"},{\"slon\":\"9\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"22\",\"height\":\"508\",\"slat\":\"51\"},{\"slon\":\"37\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"31\",\"height\":\"506\",\"slat\":\"53\"},{\"slon\":\"32\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"61\",\"height\":\"503\",\"slat\":\"44\"},{\"slon\":\"52\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"46\",\"height\":\"502\",\"slat\":\"26\"},{\"slon\":\"63\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"63\",\"height\":\"503\",\"slat\":\"39\"},{\"slon\":\"73\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"60\",\"height\":\"503\",\"slat\":\"24\"},{\"slon\":\"40\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"36\",\"height\":\"500\",\"slat\":\"47\"},{\"slon\":\"25\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"22000\",\"orient\":\"20\",\"height\":\"502\",\"slat\":\"49\"},{\"slon\":\"6\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"122\",\"height\":\"499\",\"slat\":\"68\"},{\"slon\":\"-18\",\"speed\":\"0\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"122\",\"height\":\"499\",\"slat\":\"60\"},{\"slon\":\"-6\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"3\",\"height\":\"498\",\"slat\":\"73\"},{\"slon\":\"-10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"351\",\"height\":\"497\",\"slat\":\"46\"},{\"slon\":\"-13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"4000\",\"orient\":\"4\",\"height\":\"494\",\"slat\":\"62\"},{\"slon\":\"-3\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"355\",\"height\":\"493\",\"slat\":\"45\"},{\"slon\":\"-10\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"359\",\"height\":\"493\",\"slat\":\"71\"},{\"slon\":\"-17\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"6000\",\"orient\":\"355\",\"height\":\"496\",\"slat\":\"63\"},{\"slon\":\"5\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"8000\",\"orient\":\"4\",\"height\":\"498\",\"slat\":\"55\"},{\"slon\":\"13\",\"speed\":\"1\",\"state\":\"1\",\"addtime\":\"2000\",\"orient\":\"1\",\"height\":\"503\",\"slat\":\"59\"}]";
    runClass.statusIndex = @"[0,325,573,575]";
    runClass.mind = [NSNumber numberWithInt:1];
    runClass.runway = [NSNumber numberWithInt:1];
    runClass.distance = [NSNumber numberWithFloat:3590.169];
    runClass.utime = [NSNumber numberWithInt:3424];
    runClass.pspeed = [NSNumber numberWithFloat:955];
    runClass.remarks = @"今天走的很慢";
    runClass.ismatch = [NSNumber numberWithInt:0];
    runClass.stamp = [NSNumber numberWithLongLong:1411527691];
    runClass.score = [NSNumber numberWithInt:46];
    
    
    NSError *error = nil;
    if (![kApp.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@", error);
        abort();
    }
    NSLog(@"add success");
    
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
    }
    double total_distance = [[record_dic objectForKey:@"total_distance"]doubleValue];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    int total_score = [[record_dic objectForKey:@"total_score"]intValue];
    total_distance += 3590.169;
    total_count++;
    total_time += 3424;
    total_score += 46;
    [record_dic setObject:[NSString stringWithFormat:@"%f",total_distance] forKey:@"total_distance"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_count] forKey:@"total_count"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_time] forKey:@"total_time"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_score] forKey:@"total_score"];
    [record_dic writeToFile:filePath_record atomically:YES];
}
- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}
@end

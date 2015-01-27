//
//  CNAppDelegate.h
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNTestGEOS;
@class CNNetworkHandler;
@class CNLocationHandler;
@class CNGPSPoint4Match;
@class CNVoiceHandler;
@class CNRunManager;
@class CNCloudRecord;

@interface CNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) CNNetworkHandler* networkHandler;
@property (nonatomic, strong) CNLocationHandler* locationHandler;
@property (strong ,nonatomic) CNVoiceHandler* voiceHandler;
@property (strong ,nonatomic) CNRunManager* runManager;
@property (strong, nonatomic) CNCloudRecord* cloudManager;

@property (nonatomic, strong) NSString* pid;
@property (nonatomic, strong) NSString* ua;
@property (nonatomic, strong) NSString* mainurl;
@property (nonatomic, strong) NSString* imageurl;
@property (nonatomic, strong) NSString* showad;
@property (nonatomic, strong) NSString* showgame;
@property (nonatomic, assign) int score;//积分
//用户信息
@property (assign, nonatomic) int isLogin;//0-未登录，1-已经登录，2-正在登录
@property (strong, nonatomic) NSMutableDictionary* userInfoDic;
@property (nonatomic, strong) NSData* imageData;//保存用户头像
@property (nonatomic, assign) BOOL hasMessage;
@property (assign, nonatomic) int vcodeSecond;
@property (strong, nonatomic) NSTimer* vcodeTimer;
//运动相关
@property (assign, nonatomic) int isRunning;//是否在运动，为了判断如果没有在运动，则退到后台应该关掉gps
@property (strong, nonatomic) NSMutableArray* oneRunPointList;//一次运动的轨迹点记录，整个软件声明周期只有一个
@property (strong, nonatomic) NSTimer* timer_one_point;//运动时取点的定时器
@property (strong, nonatomic) NSTimer* timer_secondplusplus;//显示时间的timer
@property (assign, nonatomic) int run_second;//和timer_secondplusplus配合使用，每次加一
@property (assign, nonatomic) int runStatus;//运动状态：0——没在运动，1——正在运动，2——暂停运动
@property (strong, nonatomic) NSMutableArray* runStatusChangeIndex;//记录运动状态发生改变时数组的坐标-1
@property (assign, nonatomic) int voiceOn;//1-开启语音 0-关闭语音
@property (assign, nonatomic) int gpsLevel;//gps采用的等级
@property (assign, nonatomic) BOOL isInChina;//是否在中国
@property (assign, nonatomic) BOOL isKnowCountry;//是否已经判断了国家
//下面是一次运动的一些实时数据
@property (assign, nonatomic) float distance;//一次运动的累计距离
@property (assign, nonatomic) int perMileSecond;//一次运动的平均配速，用秒表示
@property (assign, nonatomic) int totalSecond;//一次运动的总时间
@property (assign, nonatomic) int alreadySecond;//之前已经跑了的时间，当有暂停时，和totalSecond将不相等
@property (assign, nonatomic) long long startTime;//为了算时间记录的起始时间，或者为0，或者为暂停后恢复的第一个点
@property (assign, nonatomic) int kmstartTime;//这公里开始的时间
@property (assign, nonatomic) int mood;//心情：1，2，3，4，5
@property (assign, nonatomic) int way;//跑道：1，2，3，4，5
@property (assign, nonatomic) int perHeart;//平均心率
@property (assign, nonatomic) int maxHeart;//最高心率
@property (assign, nonatomic) int weather;//天气code
@property (assign, nonatomic) int temp;//温度
@property (assign, nonatomic) float hspeed;
@property (strong, nonatomic) NSString* feel;//想说的话
@property (assign, nonatomic) int gpsSignal;//gps信号
@property (assign, nonatomic) int pauseCount;//暂停时点数组的大小

//coredata
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CNAppDelegate*)getApplicationDelegate;
+ (void)initRun;//初始化各种跑步参数
+ (void)makeTest;//构建一个测试数据


//-----------------------------------------比赛------------------------------------------
//静态数据
@property (strong, nonatomic) NSMutableDictionary* matchDic;//比赛数据
@property (assign, nonatomic) int isMatch;//0未报名，1报名
@property (assign, nonatomic) int isGroup;//0没组队，1组队
@property (assign, nonatomic) int isbaton;//是否持棒0没有持棒1持棒
@property (strong, nonatomic) CNTestGEOS* geosHandler;
@property (strong, nonatomic) NSString* match_track_line;
@property (strong, nonatomic) NSString* match_takeover_zone;
@property (strong, nonatomic) NSString* match_stringTrackZone;
@property (strong, nonatomic) NSString* match_stringStartZone;
@property (strong, nonatomic) NSString* uid;
@property (strong, nonatomic) NSString* gid;
@property (strong, nonatomic) NSString* mid;
@property (assign, nonatomic) int deltaTime;//与服务器相差的秒数，服务器-客户端


//动态数据
@property (assign ,nonatomic) int match_isLogin;//记录这次开机是否登录过，用户判断比赛之前是否和服务器通信过
@property (strong, nonatomic) NSMutableArray* match_pointList;//比赛用存点数组
//和单次跑有关
@property (assign, nonatomic) double match_startdis;//开始比赛，起跑时距离起点的距离
@property (assign, nonatomic) double match_currentLapDis;//已经跑过的距离（当前圈）
@property (assign, nonatomic) int match_countPass;//本次跑步已经经过了起点的次数
@property (assign, nonatomic) double match_historydis;//开启这次跑步时已经跑了的距离数，在显示距离的时候应该加上这个数
@property (assign, nonatomic) int match_historySecond;//已经跑了的时间，在现实时间的时候加上这个数
@property (assign, nonatomic) double match_totaldis;//本次一共跑得距离，如果上次崩溃了会加上上次的
@property (assign, nonatomic) int match_targetkm;//已第几公里为目标
@property (assign, nonatomic) double match_totalDisTeam;//整个跑队的公里数
@property (assign, nonatomic) int match_score;//比赛积分
@property (assign, nonatomic) int match_km_target_personal;//记录个人要跑向第几公里
@property (assign, nonatomic) int match_km_start_time;//这一公里开始跑时，记录下时间

@property (assign, nonatomic) long long match_time_last_in_track;//最后一次在赛道内的点的时间
@property (strong, nonatomic) NSTimer* match_timer_report;//上报timer
@property (strong, nonatomic) NSMutableDictionary* avatarDic;//记录下载过的各种头像，以后通过url访问

@property (strong, nonatomic) NSString* match_start_time;
@property (assign, nonatomic) long long match_before5min_timestamp;
@property (assign, nonatomic) long long match_start_timestamp;
@property (assign, nonatomic) long long match_end_timestamp;
@property (strong, nonatomic) NSTimer* match_timer_check_countdown;//如果比赛前进入软件，启动定时器判断何时开始比赛开始
@property (assign, nonatomic) BOOL canStartButNotInStartZone;//可以开始比赛但是由于没有进入出发区而不能开始
@property (assign, nonatomic) BOOL hasFinishTeamMatch;
@property (assign, nonatomic) BOOL match_inMatch;//在比赛中
@property (assign, nonatomic) BOOL hasCheckTimeFromServer;//已经和服务器同步时间

+ (void)finishThisRun;//结束这次跑步
+ (void)match_save2plist;//每隔几秒写plist
+ (void)ForceGoMatchPage:(NSString*)target;//强制跳转到某个界面
+ (void)whatShouldIdo;//启动手机后应该干嘛
+ (void)saveMatchToRecord;//把比赛记到记录里
+ (void)check_start_match;
+ (BOOL)isInStartZone;//判断是否在出发区



+ (void)popupWarningGPSOpen;//异常提示弹框
+ (void)popupWarningGPSWeak;
+ (void)popupWarningBackground;
+ (void)popupWarningNotInStartZone;
+ (void)popupWarningCheckTime;
+ (void)popupWarningCloud;

//用与测试
@property (assign, nonatomic) int testIndex;
@property (strong, nonatomic) NSMutableArray* array4Test;
@property (assign, nonatomic) int matchtestdatalength;
+ (void)makeMatchTest;
+ (CNGPSPoint4Match*)test_getOnePoint;
+ (void)saveRun;
@end

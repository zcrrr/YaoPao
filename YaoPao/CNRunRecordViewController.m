//
//  CNRunRecordViewController.m
//  YaoPao
//
//  Created by zc on 14-8-8.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunRecordViewController.h"
#import "RunClass.h"
#import "CNUtil.h"
#import "CNRecordDetailViewController.h"
#import "CNDistanceImageView.h"
#import "CNMainViewController.h"

@interface CNRunRecordViewController ()

@end

@implementation CNRunRecordViewController
@synthesize pageNumber;
@synthesize y_used;
@synthesize recordList;
@synthesize from;

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
    self.scrollview.delegate = self;
    self.scrollview.contentSize = CGSizeMake(960, 120);
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;
    
    self.pageControl.numberOfPages=3; //设置页数为3
    self.pageControl.currentPage=0; //初始页码为 0
    self.pageControl.userInteractionEnabled = NO;//pagecontroller不响应点击操作
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
    }
    float totaldistance = [[record_dic objectForKey:@"total_distance"]floatValue]/1000;
    [self setDisNumImage:totaldistance];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    [self setCountNumImage:total_count];
    int total_second = [[record_dic objectForKey:@"total_time"]intValue];
    [self setTimeNumImage:total_second];
    
    self.y_used = 0;
    [self lookup];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.pageControl.currentPage = offset.x/320; //计算当前的页码
        NSLog(@"current page is %i",self.pageControl.currentPage);
    }
}
- (void)lookup{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rid" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[kApp.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    self.recordList = mutableFetchResult;
    int i = 0;
    for(i = 0;i<[mutableFetchResult count];i++){
        RunClass *runClass = [mutableFetchResult objectAtIndex:i];
        NSLog(@"runClass is %@",runClass);
//        NSLog(@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",runClass.rid,runClass.stamp,runClass.runtar,runClass.runty,runClass.runtra,runClass.mind,runClass.runway,runClass.aheart,runClass.mheart,runClass.weather,runClass.temp,runClass.distance,runClass.utime,runClass.pspeed,runClass.hspeed,runClass.heat,runClass.remarks,runClass.statusIndex);
        
        NSLog(@"ctp is %@",runClass.ctp);
        UIView *view_one_record = [[UIView alloc]initWithFrame:CGRectMake(0, y_used, 320, 60)];
        //分割线
        UIView *view_line = [[UIView alloc]initWithFrame:CGRectMake(0, 59, 320, 1)];
        [view_line setBackgroundColor:[UIColor lightGrayColor]];
        [view_one_record addSubview:view_line];
        //运动类型
        UIImageView* image_type = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        int type = [runClass.runty intValue];
        image_type.image = [UIImage imageNamed:[self imageNameFromType:type]];
        [view_one_record addSubview:image_type];
        //时间
        long long stamp = [runClass.stamp longLongValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:stamp/1000];
        NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
        int weekday = [componets weekday];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"M月d日 周%@ HH:mm",[CNUtil weekday2chinese:weekday]]];
        NSString *strDate = [dateFormatter stringFromDate:date];
        
        UILabel* label_date = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 120, 20)];
        label_date.textAlignment = NSTextAlignmentLeft;
        label_date.font = [UIFont systemFontOfSize:12];
        label_date.text = [NSString stringWithFormat:@"%@",strDate];
        [view_one_record addSubview:label_date];
        //距离
        CNDistanceImageView* div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(37, 20, 130, 32)];
        div.distance = [runClass.distance floatValue]/1000;
        div.color = @"red";
        [div fitToSize];
        [view_one_record addSubview:div];
        UIImageView* image_km = [[UIImageView alloc]initWithFrame:CGRectMake(div.frame.origin.x+div.frame.size.width, 20,26, 32)];
        image_km.image = [UIImage imageNamed:@"redkm.png"];
        [view_one_record addSubview:image_km];
    
        //4张图片
        UIImageView* image_mood = [[UIImageView alloc]initWithFrame:CGRectMake(180, 10, 20, 20)];
        int mood = [runClass.mind intValue];
        NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_h.png",mood];
        image_mood.image = [UIImage imageNamed:img_name_mood];
        [view_one_record addSubview:image_mood];
        
        UIImageView* image_way = [[UIImageView alloc]initWithFrame:CGRectMake(210, 10, 20, 20)];
        int way = [runClass.runway intValue];
        NSString* img_name_way = [NSString stringWithFormat:@"way%i_h.png",way];
        image_way.image = [UIImage imageNamed:img_name_way];
        [view_one_record addSubview:image_way];
        
        UIImageView* image_photo = [[UIImageView alloc]initWithFrame:CGRectMake(240, 10, 20, 20)];
        int imagecount = [runClass.image_count intValue];
        if(imagecount!=0){
            //去沙盒读取图片
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:runClass.c120ips];;
            NSLog(@"filepath is %@",filePath);
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (blHave) {//图片存在
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                image_photo.image = [[UIImage alloc] initWithData:data];
            }
        }
        [view_one_record addSubview:image_photo];
        
        int ismatch = [runClass.ismatch intValue];
        if(ismatch == 1){
            UIImageView* image_match = [[UIImageView alloc]initWithFrame:CGRectMake(180, 10, 20, 20)];
            image_match.image = [UIImage imageNamed:@"matchicon.png"];
            [view_one_record addSubview:image_match];
        }
        
        
        
        //配速
        UIImageView* image_speed = [[UIImageView alloc]initWithFrame:CGRectMake(180, 35, 20, 20)];
        image_speed.image = [UIImage imageNamed:@"secondwatch.png"];
        [view_one_record addSubview:image_speed];
        
        UILabel* label_pspeed = [[UILabel alloc]initWithFrame:CGRectMake(200, 30, 50, 30)];
        label_pspeed.textAlignment = NSTextAlignmentLeft;
        label_pspeed.font = [UIFont systemFontOfSize:12];
        label_pspeed.text = [CNUtil pspeedStringFromSecond:[runClass.pspeed intValue]];
        [view_one_record addSubview:label_pspeed];
        //时间
        UIImageView* image_time = [[UIImageView alloc]initWithFrame:CGRectMake(250, 35, 20, 20)];
        image_time.image = [UIImage imageNamed:@"clock.png"];
        [view_one_record addSubview:image_time];
        
        UILabel* label_during = [[UILabel alloc]initWithFrame:CGRectMake(270, 30, 50, 30)];
        label_during.textAlignment = NSTextAlignmentLeft;
        label_during.font = [UIFont systemFontOfSize:12];
        int duringSecond = [runClass.utime intValue]/1000;
        int minute1 = duringSecond/60;
        int second1 = duringSecond%60;
        label_during.text = [NSString stringWithFormat:@"%02d:%02d",minute1,second1];
        [view_one_record addSubview:label_during];
        //按钮
        UIButton* button_goDetail = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_goDetail setTitle:@"" forState:UIControlStateNormal];
        [button_goDetail setFrame:CGRectMake(0, 0 , 320, 60)];
        button_goDetail.tag = i;
        [view_one_record addSubview:button_goDetail];
        [button_goDetail addTarget:self action:@selector(goDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollview_list addSubview:view_one_record];
        y_used += 60;
    }
    [self.scrollview_list setContentSize:CGSizeMake(320, y_used)];
}
- (void)goDetail:(id)sender{
    NSLog(@"tag is %i",[sender tag]);
    CNRecordDetailViewController* recordDetailVC = [[CNRecordDetailViewController alloc]init];
    recordDetailVC.oneRun = [self.recordList objectAtIndex:[sender tag]];
    [self.navigationController pushViewController:recordDetailVC animated:YES];
}
- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    if([self.from isEqual:@"match"]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        CNMainViewController* mainVC = [[CNMainViewController alloc]init];
        [self.navigationController pushViewController:mainVC animated:YES];
    }
    
    
}
- (NSString*)imageNameFromType:(int)type{
    NSString* img_name_type = @"runtype_run.png";
    switch (type) {
        case 0:
        {
            img_name_type = @"runtype_walk.png";
            break;
        }
        case 1:
        {
            img_name_type = @"runtype_run.png";
            break;
        } 
        case 2:
        {
            img_name_type = @"runtype_ride.png";
            break;
        }
        default:
            break;
    }
    return img_name_type;
}
- (void)setDisNumImage:(double)distance{
    int distance100 = distance*100;
    int dis1num = distance100/100000;
    distance100 = distance100 - dis1num*100000;
    int dis2num = distance100/10000;
    distance100 = distance100 - dis2num*10000;
    int dis3num = distance100/1000;
    distance100 = distance100 - dis3num*1000;
    int dis4num = distance100/100;
    distance100 = distance100 - dis4num*100;
    int dis5num = distance100/10;
    int dis6num = distance100%10;
    self.image_dis1.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis1num]];
    self.image_dis2.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis2num]];
    self.image_dis3.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis3num]];
    self.image_dis4.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis4num]];
    self.image_dis5.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis5num]];
    self.image_dis6.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis6num]];
    if(dis1num == 0){
        self.image_dis1.hidden = YES;
        [self offLeft];
        if(dis2num == 0){
            self.image_dis2.hidden = YES;
            [self offLeft];
            if(dis3num == 0){
                self.image_dis3.hidden = YES;
                [self offLeft];
            }
        }
    }
}
- (void)setCountNumImage:(int)count{
    int count1num = count/100;
    count = count-count1num*100;
    int count2num = count/10;
    int count3num = count%10;
    self.image_count1.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",count1num]];
    self.image_count2.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",count2num]];
    self.image_count3.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",count3num]];
    if(count1num == 0){
        self.image_count1.hidden = YES;
        [self offLeftCount];
        if(count2num == 0){
            self.image_count2.hidden = YES;
            [self offLeftCount];
        }
    }
}
- (void)setTimeNumImage:(int)second{
    NSString* timeString = [CNUtil duringTimeStringFromSecond:second];
    //    NSLog(@"timeString is %@",timeString);
    unichar char1 = [timeString characterAtIndex:0];
    unichar char2 = [timeString characterAtIndex:1];
    unichar char3 = [timeString characterAtIndex:3];
    unichar char4 = [timeString characterAtIndex:4];
    unichar char5 = [timeString characterAtIndex:6];
    unichar char6 = [timeString characterAtIndex:7];
    //    NSLog(@"char1:%c,char2:%c,char3:%c,char4:%c,char5:%c,char6:%c",char1,char2,char3,char4,char5,char6);
    self.image_time1.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char1]];
    self.image_time2.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char2]];
    self.image_time3.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char3]];
    self.image_time4.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char4]];
    self.image_time5.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char5]];
    self.image_time6.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char6]];
}
- (void)offLeft{
    //往左偏移width的一半，使居中
    int width = self.image_dis1.frame.size.width;
    CGRect newFrame = self.view_dis.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width/2, top);
    self.view_dis.frame = newFrame;
}
- (void)offLeftCount{
    //往左偏移width的一半，使居中
    int width = self.image_count1.frame.size.width;
    CGRect newFrame = self.view_count.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width/2, top);
    self.view_count.frame = newFrame;
}

@end

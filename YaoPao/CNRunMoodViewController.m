//
//  CNRunMoodViewController.m
//  YaoPao
//
//  Created by zc on 14-8-5.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMoodViewController.h"
#import "CNMainViewController.h"
#import "CNShareViewController.h"
#import "SBJson.h"
#import "CNGPSPoint.h"
#import "RunClass.h"
#import "CNUtil.h"
#import "UIImage+Rescale.h"
#import "CNRunRecordViewController.h"
#import "CNRunManager.h"


@interface CNRunMoodViewController ()

@end

@implementation CNRunMoodViewController
@synthesize image_small;
@synthesize hasPhoto;

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
    kApp.isRunning = 0;
    kApp.gpsLevel = 1;
    // Do any additional setup after loading the view from its nib.
    
    //测试代码
//    NSMutableString* trackRecord = [[NSMutableString alloc]initWithString:@""];
//    for(int i=0;i<[kApp.oneRunPointList count];i++){
//        CNGPSPoint* point = [kApp.oneRunPointList objectAtIndex:i];
//        [trackRecord appendString:[NSString stringWithFormat:@"%0.6f %0.6f,",point.lon,point.lat]];
//    }
//    NSLog(@"trackRecord is %@",trackRecord);
//    NSString* filename = [NSString stringWithFormat:@"%lli.plist",[CNUtil getNowTime]];
//    NSString* filePathTrackRecord = [CNPersistenceHandler getDocument:filename];
//    NSDictionary* trackdic = [[NSDictionary alloc]initWithObjectsAndKeys:trackRecord,@"track",nil];
//    [trackdic writeToFile:filePathTrackRecord atomically:YES];
    
    
    self.textfield_feel.delegate = self;
    [self.button_delete addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_save addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[CNUtil getNowTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M月d日"];
    NSString* strDate2 = [dateFormatter stringFromDate:date];
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
            typeDes = @"跑步";
            break;
        }
        case 2:
        {
            typeDes = @"自行车骑行";
            break;
        }
        default:
            break;
    }
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,typeDes];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_delete_clicked:(id)sender {
    self.button_delete.backgroundColor = [UIColor clearColor];
    [CNAppDelegate initRun];
    CNMainViewController* mainVC = [[CNMainViewController alloc]init];
    [self.navigationController pushViewController:mainVC animated:YES];
}
- (IBAction)button_mood_clicked:(id)sender {
    [self resetMoodButtonStatus];
    int tag = [sender tag];
    NSString* imageName = [NSString stringWithFormat:@"mood%i_h.png",tag];
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    kApp.runManager.feeling = tag;
}

- (IBAction)button_track_clicked:(id)sender {
    [self resetWayButtonStatus];
    int tag = [sender tag];
    NSString* imageName = [NSString stringWithFormat:@"way%i_h.png",tag];
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    kApp.runManager.way = tag;
}
- (void)resetMoodButtonStatus{
    [self.button_mood1 setBackgroundImage:[UIImage imageNamed:@"mood1.png"] forState:UIControlStateNormal];
    [self.button_mood2 setBackgroundImage:[UIImage imageNamed:@"mood2.png"] forState:UIControlStateNormal];
    [self.button_mood3 setBackgroundImage:[UIImage imageNamed:@"mood3.png"] forState:UIControlStateNormal];
    [self.button_mood4 setBackgroundImage:[UIImage imageNamed:@"mood4.png"] forState:UIControlStateNormal];
    [self.button_mood5 setBackgroundImage:[UIImage imageNamed:@"mood5.png"] forState:UIControlStateNormal];
}
- (void)resetWayButtonStatus{
    [self.button_way1 setBackgroundImage:[UIImage imageNamed:@"way1.png"] forState:UIControlStateNormal];
    [self.button_way2 setBackgroundImage:[UIImage imageNamed:@"way2.png"] forState:UIControlStateNormal];
    [self.button_way3 setBackgroundImage:[UIImage imageNamed:@"way3.png"] forState:UIControlStateNormal];
    [self.button_way4 setBackgroundImage:[UIImage imageNamed:@"way4.png"] forState:UIControlStateNormal];
    [self.button_way5 setBackgroundImage:[UIImage imageNamed:@"way5.png"] forState:UIControlStateNormal];
}
- (IBAction)button_photo_clicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选取来自" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"用户相册", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)button_save_clicked:(id)sender {
    self.button_save.backgroundColor = [UIColor clearColor];
    //先保存，然后跳转
    [self saveRun];
//    CNShareViewController* shareVC = [[CNShareViewController alloc]init];
//    shareVC.dataSource = @"this";
//    [self.navigationController pushViewController:shareVC animated:YES];
    CNRunRecordViewController* recordVC = [[CNRunRecordViewController alloc]init];
    [self.navigationController pushViewController:recordVC animated:YES];
}
- (void)saveRun{
    kApp.runManager.remark = self.textfield_feel.text;
    
    //通过plist获取运动类型等参数
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    NSMutableDictionary* runSettingDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    //通过全局变量获取运动属性等参数
    //存储到数据库
    RunClass * runClass  = [NSEntityDescription insertNewObjectForEntityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    runClass.rid = [NSString stringWithFormat:@"%lli",[CNUtil getNowTime]];
    runClass.runtar = [NSNumber numberWithInt:[[runSettingDic objectForKey:@"target"]intValue]];
    runClass.runty = [NSNumber numberWithInt:[[runSettingDic objectForKey:@"type"]intValue]];
    runClass.mind = [NSNumber numberWithInt:kApp.mood];
    runClass.runway = [NSNumber numberWithInt:kApp.way];
    runClass.aheart = [NSNumber numberWithInt:kApp.perHeart];
    runClass.mheart = [NSNumber numberWithInt:kApp.maxHeart];
    runClass.weather = [NSNumber numberWithInt:kApp.weather];
    runClass.temp = [NSNumber numberWithInt:kApp.temp];
    runClass.distance = [NSNumber numberWithFloat:kApp.distance];
    runClass.utime = [NSNumber numberWithInt:kApp.totalSecond];
    runClass.pspeed = [NSNumber numberWithFloat:kApp.perMileSecond];
    runClass.hspeed = [NSNumber numberWithFloat:kApp.hspeed];
    runClass.heat = [NSNumber numberWithInt:100];
    runClass.remarks = kApp.feel;
    runClass.ismatch = [NSNumber numberWithInt:0];
    CNGPSPoint* firstPoint = [kApp.oneRunPointList objectAtIndex:0];
    long long stamp = firstPoint.time;
    runClass.stamp = [NSNumber numberWithLongLong:stamp];
    runClass.score = [NSNumber numberWithInt:kApp.score];
    
    //如果有图片，存储到手机
    if(self.hasPhoto){
        NSLog(@"有图片");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath_big = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_big.jpg",runClass.rid]];   // 保存文件的名称
        NSString *filePath_small = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_small.jpg",runClass.rid]];
        if ([UIImagePNGRepresentation(self.imageview_photo.image) writeToFile: filePath_big atomically:YES]) {
            [UIImagePNGRepresentation(self.image_small) writeToFile: filePath_small atomically:YES];
            runClass.image_count = [NSNumber numberWithInt:1];
        }else{
            runClass.image_count = [NSNumber numberWithInt:0];
        }
    }else{
        NSLog(@"没有图片");
        runClass.image_count = [NSNumber numberWithInt:0];
    }
    
    NSError *error = nil;
    if (![kApp.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@", error);
        abort();
    }
    NSLog(@"add success");
    //更新plist中个人总记录：
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
    total_distance += kApp.distance;
    total_count++;
    total_time += kApp.totalSecond;
    total_score += kApp.score;
    [record_dic setObject:[NSString stringWithFormat:@"%f",total_distance] forKey:@"total_distance"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_count] forKey:@"total_count"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_time] forKey:@"total_time"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_score] forKey:@"total_score"];
    [record_dic writeToFile:filePath_record atomically:YES];
}
#pragma mark- textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self resetViewFrame];
    return YES;
}
- (void)keyboardWillShow:(NSNotification *)noti
{
    //键盘输入的界面调整
    //键盘的高度
    float height = 216.0;
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height);
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:frame];
    [UIView commitAnimations];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint point = [textField.superview convertPoint:textField.frame.origin toView:nil];
    int offset = point.y + 80 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}
- (void)resetViewFrame{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
}
- (NSMutableArray*)list2Increment{
    NSMutableArray* listIncrement = [[NSMutableArray alloc]init];
    int i = 0;
    CNGPSPoint* firstPoint = [kApp.oneRunPointList objectAtIndex:0];
    NSMutableDictionary* firstDic = [[NSMutableDictionary alloc]init];
    
    NSLog(@"time is %lli",firstPoint.time*1000);
    NSLog(@"%@",[NSString stringWithFormat:@"%lli",(firstPoint.time*1000)]);
    
    [firstDic setObject:[NSString stringWithFormat:@"%i",firstPoint.status] forKey:@"state"];
    [firstDic setObject:[NSString stringWithFormat:@"%lli",(firstPoint.time*1000)] forKey:@"addtime"];
    [firstDic setObject:[NSString stringWithFormat:@"%i",(int)(firstPoint.lon*1000000)] forKey:@"slon"];
    [firstDic setObject:[NSString stringWithFormat:@"%i",(int)(firstPoint.lat*1000000)] forKey:@"slat"];
    [firstDic setObject:[NSString stringWithFormat:@"%i",firstPoint.speed] forKey:@"speed"];
    [firstDic setObject:[NSString stringWithFormat:@"%i",firstPoint.course] forKey:@"orient"];
    [firstDic setObject:[NSString stringWithFormat:@"%i",firstPoint.altitude] forKey:@"height"];
    [listIncrement addObject:firstDic];
    int count = [kApp.oneRunPointList count];
    for(i = 1;i<count;i++){
        CNGPSPoint* beforePoint = [kApp.oneRunPointList objectAtIndex:(i-1)];
        CNGPSPoint* thisPoint = [kApp.oneRunPointList objectAtIndex:i];
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSString stringWithFormat:@"%i",thisPoint.status] forKey:@"state"];
        [dic setObject:[NSString stringWithFormat:@"%lli",(thisPoint.time*1000-beforePoint.time*1000)] forKey:@"addtime"];
        [dic setObject:[NSString stringWithFormat:@"%i",((int)(thisPoint.lon*1000000)-(int)(beforePoint.lon*1000000))] forKey:@"slon"];
        [dic setObject:[NSString stringWithFormat:@"%i",((int)(thisPoint.lat*1000000)-(int)(beforePoint.lat*1000000))] forKey:@"slat"];
        [dic setObject:[NSString stringWithFormat:@"%i",thisPoint.speed] forKey:@"speed"];
        [dic setObject:[NSString stringWithFormat:@"%i",thisPoint.course] forKey:@"orient"];
        [dic setObject:[NSString stringWithFormat:@"%i",thisPoint.altitude] forKey:@"height"];
        [listIncrement addObject:dic];
    }
    return listIncrement;
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController* pickC = [[UIImagePickerController alloc]init];
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
            pickC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickC.allowsEditing = YES;
            pickC.delegate = self;
            [self presentViewController:pickC animated:YES completion:^{
                
            }];
            break;
        }
        case 1:
        {
            NSLog(@"相册");
            pickC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickC.allowsEditing = YES;
            pickC.delegate = self;
            [self presentViewController:pickC animated:YES completion:^{
            }];
            break;
        }
        default:
            break;
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    UIImage* image_compressed = [image rescaleImageToSize:CGSizeMake(640, 640)];
    self.image_small = [image rescaleImageToSize:CGSizeMake(100, 100)];
    self.imageview_photo.image = image_compressed;
    self.imageview_photo.contentMode = UIViewContentModeScaleAspectFill;
    self.hasPhoto = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.button_takephoto.hidden = YES;
}

@end

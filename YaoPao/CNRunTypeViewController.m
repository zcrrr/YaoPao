//
//  CNRunTypeViewController.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunTypeViewController.h"

@interface CNRunTypeViewController ()

@end

@implementation CNRunTypeViewController
@synthesize selectedIndex;
@synthesize runSettingDic;

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
    int type = [[runSettingDic objectForKey:@"type"]intValue];
    [self selectType:type];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_choose_clicked:(id)sender {
    [self selectType:[sender tag]];
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.runSettingDic setObject:[NSString stringWithFormat:@"%i",self.selectedIndex] forKey:@"type"];
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    [self.runSettingDic writeToFile:filePath atomically:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)selectType:(int)type{
    self.selectedIndex = type;
    self.image_choose1.hidden = YES;
    self.image_choose2.hidden = YES;
    self.image_choose3.hidden = YES;
    switch (type) {
        case 0:
        {
            self.image_choose1.hidden = NO;
            break;
        }
        case 1:
        {
            self.image_choose2.hidden = NO;
            break;
        }
        case 2:
        {
            self.image_choose3.hidden = NO;
            break;
        }
        default:
            break;
    }
}
@end

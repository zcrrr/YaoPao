//
//  CNWarningCloudingViewController.m
//  YaoPao
//
//  Created by zc on 15-1-26.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNWarningCloudingViewController.h"
#import "CNCloudRecord.h"
#import "CNNetworkHandler.h"


@interface CNWarningCloudingViewController ()

@end

@implementation CNWarningCloudingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [kApp.cloudManager startCloud];
    [self.progress setProgress:0];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [kApp.cloudManager addObserver:self forKeyPath:@"stepDes" options:NSKeyValueObservingOptionNew context:nil];
    [kApp.networkHandler addObserver:self forKeyPath:@"newprogress" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [kApp.cloudManager removeObserver:self forKeyPath:@"stepDes"];
    [kApp.networkHandler removeObserver:self forKeyPath:@"newprogress"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"close");}];
    kApp.cloudManager.userCancel = YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"stepDes"]){
        self.label_step.text = kApp.cloudManager.stepDes;
        NSLog(@"stepDes is %@",kApp.cloudManager.stepDes);
    }else if([keyPath isEqualToString:@"newprogress"]){
        [self.progress setProgress:kApp.networkHandler.newprogress];
    }
    
}
@end

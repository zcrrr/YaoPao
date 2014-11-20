//
//  CNLoginPhoneViewController.m
//  YaoPao
//
//  Created by zc on 14-7-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNLoginPhoneViewController.h"
#import "CNNetworkHandler.h"
#import "CNMainViewController.h"
#import "CNForgetPwdViewController.h"
#import "CNUserinfoViewController.h"
#import "CNServiceViewController.h"
#import "Toast+UIView.h"
#import "CNRegisterPhoneViewController.h"

@interface CNLoginPhoneViewController ()

@end

@implementation CNLoginPhoneViewController
@synthesize agree;

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
    self.agree = 1;
    self.textfield_pwd.delegate = self;
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_goFindPwdPage addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_goRegister addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    
    
    [self.button_login addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:{
            self.button_back.backgroundColor = [UIColor clearColor];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            self.button_login.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            //登录
            [self resignAllText];
            if ([self checkPhoneNO]) {
                if ([self checkPwd]) {
                    if(self.agree == 1){
                        //登录
                        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                        [params setObject:self.textfield_phone.text forKey:@"phone"];
                        [params setObject:self.textfield_pwd.text forKey:@"passwd"];
                        kApp.networkHandler.delegate_loginPhone = self;
                        [kApp.networkHandler doRequest_loginPhone:params];
                        [self displayLoading];
                    }else{
                        [kApp.window makeToast:@"您需要同意要跑服务协议才能进行后续操作"];
                    }
                    
                }
            }
            break;
        }
        case 2:
        {
            self.button_goFindPwdPage.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
            CNForgetPwdViewController* forgetPwdVC = [[CNForgetPwdViewController alloc]init];
            [self.navigationController pushViewController:forgetPwdVC animated:YES];
            break;
        }
        case 3:
        {
            CNServiceViewController* serviceVC = [[CNServiceViewController alloc]init];
            [self.navigationController pushViewController:serviceVC animated:YES];
            break;
        }
        case 4:
        {
            self.button_goRegister.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
            CNRegisterPhoneViewController* registerVC = [[CNRegisterPhoneViewController alloc]init];
            [self.navigationController pushViewController:registerVC animated:YES];
            break;
        }

        default:
            break;
    }
}

- (IBAction)button_checkbox_clicked:(id)sender {
    if(self.agree == 0){
        self.agree = 1;
        [self.button_checkbox setBackgroundImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateNormal];
    }else{
        self.agree = 0;
        [self.button_checkbox setBackgroundImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)view_touched:(id)sender {
    [self resignAllText];
}
- (void)resignAllText{
    [self.textfield_phone resignFirstResponder];
    [self.textfield_pwd resignFirstResponder];
}
#pragma mark- textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)checkPhoneNO{
    NSString* string_alert = @"";
    BOOL result = NO;
    if (self.textfield_phone.text != nil && ![self.textfield_phone.text isEqualToString:@""])
    {
        if ([self.textfield_phone.text length] != 11)
        {
            string_alert = @"手机号码不符合规范，应为11位的数字";
        }
        else
        {
            for (int i = 0; i < [self.textfield_phone.text length]; i++)
            {
                char c = [self.textfield_phone.text characterAtIndex:i];
                if (c <'0' || c >'9')
                {
                    string_alert = @"手机号码不符合规范，应为11位的数字";
                    break;
                }
            }
        }
    }else{
        string_alert = @"手机号不能为空";
    }
    if (![string_alert isEqualToString:@""])
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:string_alert delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        result = NO;
    }else{
        result = YES;
    }
    return result;
}
- (BOOL)checkPwd{
    NSString* string_alert = @"";
    BOOL result = NO;
    if (self.textfield_pwd.text != nil && ![self.textfield_pwd.text isEqualToString:@""])
    {
        
        for (int i = 0; i < [self.textfield_pwd.text length]; i++)
        {
            char c = [self.textfield_pwd.text characterAtIndex:i];
            if (('a' <= c && 'z' >= c) || ('A' <= c && 'Z' >= c) || ('0' <= c && '9' >= c))
            {
                
            }
            else
            {
                string_alert = @"密码不符合规范，应为6-16位字母、数字、符号组成，区分大小写。";
                break;
            }
        }
        
        if ([self.textfield_pwd.text length] < 6 || [self.textfield_pwd.text length] > 16)
        {
            string_alert = @"密码不符合规范，应为6-16位字母、数字、符号组成，区分大小写。";
        }
    }else{
        string_alert = @"密码不能为空";
    }
    if (![string_alert isEqualToString:@""])
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:string_alert delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        result = NO;
    }else{
        result = YES;
    }
    return result;
}
- (void)loginPhoneDidSuccess:(NSDictionary *)resultDic{
    //测试账号：18611101410
    if([self.textfield_phone.text isEqualToString:@"18611101410"]){
        [CNAppDelegate saveRun];
    }
    [self hideLoading];
    //登录、注册之后的一系列操作
    CNMainViewController* mainVC = [[CNMainViewController alloc]init];
    [self.navigationController pushViewController:mainVC animated:YES];
    
//    CNUserinfoViewController* userInfoVC = [[CNUserinfoViewController alloc]init];
//    [self.navigationController pushViewController:userInfoVC animated:YES];
}
- (void)loginPhoneDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
}
@end

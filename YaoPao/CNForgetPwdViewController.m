//
//  CNForgetPwdViewController.m
//  YaoPao
//
//  Created by zc on 14-7-28.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNForgetPwdViewController.h"
#import "CNNetworkHandler.h"
#import "CNMainViewController.h"

@interface CNForgetPwdViewController ()

@end

@implementation CNForgetPwdViewController

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
    self.textfield_pwd.delegate = self;
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_ok addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_vcode addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            self.button_back.backgroundColor = [UIColor clearColor];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            self.button_vcode.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            if ([self checkPhoneNO]) {
                NSLog(@"获取验证码");
                [kApp.networkHandler doRequest_findPwdVCode:self.textfield_phone.text];
            }
            break;
        }
        case 2:
        {
            self.button_ok.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            if([self checkPhoneNO]){
                if([self checkPwd]){
                    if ([self checkVcode]) {
                        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                        [params setObject:self.textfield_phone.text forKey:@"phone"];
                        [params setObject:self.textfield_pwd.text forKey:@"passwd"];
                        [params setObject:self.textfield_vcode.text forKey:@"vcode"];
                        kApp.networkHandler.delegate_findPwd = self;
                        [kApp.networkHandler doRequest_findPwd:params];
                    }
                }
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)view_touched:(id)sender {
    [self.textfield_phone resignFirstResponder];
    [self.textfield_pwd resignFirstResponder];
    [self.textfield_vcode resignFirstResponder];
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
- (BOOL)checkVcode{
    NSString* string_alert = @"";
    BOOL result = NO;
    if (self.textfield_vcode.text != nil && ![self.textfield_vcode.text isEqualToString:@""])
    {
        if ([self.textfield_vcode.text length] != 6)
        {
            string_alert = @"验证码不符合规范，应为6位的数字";
        }
        else
        {
            for (int i = 0; i < [self.textfield_vcode.text length]; i++)
            {
                char c = [self.textfield_vcode.text characterAtIndex:i];
                if (c <'0' || c >'9')
                {
                    string_alert = @"验证码不符合规范，应为6位的数字";
                    break;
                }
            }
        }
    }else{
        string_alert = @"验证码不能为空";
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
#pragma mark- textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark- find pwd delegate
- (void)findPwdDidSuccess:(NSDictionary *)resultDic{
    //登录、注册之后的一系列操作
    CNMainViewController* mainVC = [[CNMainViewController alloc]init];
    [self.navigationController pushViewController:mainVC animated:YES];
}
- (void)findPwdDidFailed:(NSString *)mes{
    
}
@end

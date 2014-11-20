//
//  CNRegisterPhoneViewController.m
//  YaoPao
//
//  Created by zc on 14-7-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRegisterPhoneViewController.h"
#import "CNLoginPhoneViewController.h"
#import "CNNetworkHandler.h"
#import "CNUserinfoViewController.h"
#import "CNServiceViewController.h"
#import "Toast+UIView.h"

@interface CNRegisterPhoneViewController ()

@end

@implementation CNRegisterPhoneViewController

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
    self.agree = 1;
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_reg addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_vcode addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    
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

- (IBAction)view_touched:(id)sender {
    [self resignAllText];
}
- (void)resignAllText{
    [self.textfield_phone resignFirstResponder];
    [self.textfield_pwd resignFirstResponder];
    [self.textfield_vcode resignFirstResponder];
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

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:{
            self.button_back.backgroundColor = [UIColor clearColor];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            //获取验证码
            self.button_vcode.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            if ([self checkPhoneNO]) {
                NSLog(@"获取验证码");
                [kApp.networkHandler doRequest_verifyCode:self.textfield_phone.text];
            }
            break;
        }
        case 2:
        {
            [self resignAllText];
            self.button_reg.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            if([self checkPhoneNO]){
                if([self checkPwd]){
                    if ([self checkVcode]) {
                        if(self.agree == 1){
                            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                            [params setObject:self.textfield_phone.text forKey:@"phone"];
                            [params setObject:self.textfield_pwd.text forKey:@"passwd"];
                            [params setObject:self.textfield_vcode.text forKey:@"vcode"];
                            kApp.networkHandler.delegate_registerPhone = self;
                            [kApp.networkHandler doRequest_registerPhone:params];
                            [self displayLoading];
                        }else{
                            [kApp.window makeToast:@"您需要同意要跑服务协议才能进行后续操作"];
                        }
                    }
                }
            }
            break;
        }
        case 3:
        {
            CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
            [self.navigationController pushViewController:loginVC animated:YES];
            break;
        }
        case 4:
        {
            CNServiceViewController* serviceVC = [[CNServiceViewController alloc]init];
            [self.navigationController pushViewController:serviceVC animated:YES];
            break;
        }
        default:
            break;
    }
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
        [self showAlert:string_alert];
        result = NO;
    }else{
        result = YES;
    }
    return result;
}
#pragma mark- register delegate
- (void)registerPhoneDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    [self showAlert:@"注册成功"];
    
    CNUserinfoViewController* userInfoVC = [[CNUserinfoViewController alloc]init];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}
- (void)registerPhoneDidFailed:(NSString *)mes{
    [self hideLoading];
    [self showAlert:mes];
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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

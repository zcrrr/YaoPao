//
//  CNLoginPhoneViewController.h
//  YaoPao
//
//  Created by zc on 14-7-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"

@interface CNLoginPhoneViewController : UIViewController<UITextFieldDelegate,loginPhoneDelegate>
@property (assign, nonatomic) int agree;
@property (strong, nonatomic) IBOutlet UITextField *textfield_phone;
@property (strong, nonatomic) IBOutlet UITextField *textfield_pwd;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@property (strong, nonatomic) IBOutlet UIButton *button_login;
@property (strong, nonatomic) IBOutlet UIButton *button_goFindPwdPage;
@property (strong, nonatomic) IBOutlet UIButton *button_goRegister;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_checkbox;
- (IBAction)button_checkbox_clicked:(id)sender;


- (IBAction)view_touched:(id)sender;

@end
